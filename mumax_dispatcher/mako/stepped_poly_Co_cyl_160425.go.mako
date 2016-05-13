//--------------------------------------------------------------------------//
// Parameters
//--------------------------------------------------------------------------//
nsteps := 4

// Step dimensions
Lx := 20e-9
Lz := 2e-9
overlap := ${overlap}

// Cell dimensions
a := 0.5e-9
cx := a
cy := a
cz := a

// grains
grain_size := ${gs}
rand_seed := 156346
max_region := 255

// Field
Bmax   := 200.0e-3
Bstep  :=  4.0e-3
Bdelta :=  2 * pi / 180.0
Btheta :=  90 * pi / 180.0 + Bdelta
Bphi   :=  0 * pi / 180.0 + Bdelta

//  Magnet properties
Msat  = 1400e3
Aex   = 18e-12

//--------------------------------------------------------------------------//
// Define universe
//--------------------------------------------------------------------------//
xtrans := Lx
ztrans := (1 - overlap) * Lz
print(ztrans)
Lx_total := Lx * nsteps
Ly := Lx_total
Lz_total := Lz + ztrans * (nsteps - 1)

Nx := floor(Lx_total/cx)
Ny := Nx
Nz := floor(Lz_total/cz)
print(Lx_total)
print(Lz_total)
print(Nx)
print(Ny)
print(Nz)

SetGridsize(Nx, Ny, Nz)
SetCellsize(cx, cy, cz)


//--------------------------------------------------------------------------//
// Create a stepped geometry
//--------------------------------------------------------------------------//
xtr0 := -0.5 * (Lx_total - Lx)
ztr0 := -0.5 * (Lz_total - Lz)
s := cuboid(Lx, Ly, Lz).Transl(xtr0, 0, ztr0,)

for i:=1; i<nsteps; i++{
	xtr := xtr0 + i * xtrans
	ztr := ztr0 + i * ztrans
	snew := cuboid(Lx, Ly, Lz).Transl(xtr, 0, ztr)
	s = s.add(snew)
}

setgeom(s.intersect(cylinder(Lx_total, inf)))

//--------------------------------------------------------------------------//
// Create grain structure
//--------------------------------------------------------------------------//

ext_makegrains(grain_size, max_region, rand_seed)

// set random parameters per region
for i:=0; i<max_region; i++{
	// random cubic anisotropy direction
	axis1  := vector(randNorm(), randNorm(), randNorm())
	helper := vector(randNorm(), randNorm(), randNorm())
	axis2  := axis1.cross(helper)  // perpendicular to axis1
	AnisC1.SetRegion(i, axis1)     // axes need not be normalized
	AnisC2.SetRegion(i, axis2)

	// random 10% anisotropy variation
	K := 450e3
	Kc1.SetRegion(i, K + randNorm() * 0.1 * K)
}

for i:=0; i<max_region; i++{
	for j:=i+1; j<max_region; j++{
		ext_ScaleExchange(i, j, 0.9)
	}
}


//--------------------------------------------------------------------------//
// Set initial magnetization
//--------------------------------------------------------------------------//
m = uniform(0, 1, 0)
// m = RandomMag()
// relax()


//--------------------------------------------------------------------------//
// Setup output
//--------------------------------------------------------------------------//
saveas(B_demag, "B_demag")
saveas(m, "m")
save(regions)
save(Kc1)
save(AnisC1)
save(AnisC2)

MinimizerStop = 1e-6
TableAdd(B_ext)


//--------------------------------------------------------------------------//
// Run
//--------------------------------------------------------------------------//

alph1 := sin(Btheta) * cos(Bphi)
alph2 := sin(Btheta) * sin(Bphi)
alph3 := cos(Btheta)

for B:=0.0; B<=Bmax; B+=Bstep{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()
    tablesave()
}

for B:=Bmax; B>=-Bmax; B-=Bstep{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()
    tablesave()
}

for B:=-Bmax; B<=Bmax; B+=Bstep{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()
    tablesave()
}
