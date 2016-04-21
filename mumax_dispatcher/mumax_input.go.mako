//--------------------------------------------------------------------------//
// Parameters
//--------------------------------------------------------------------------//
nsteps := ${nsteps}

// Step dimensions
Lx := 20e-9
Ly := ${Ly}
overlap := ${overlap}

// Cell dimensions
a := ${a}
cx := a
cy := a
cz := a


//--------------------------------------------------------------------------//
// Define universe
//--------------------------------------------------------------------------//
xtrans := Lx
ytrans := (1 - overlap) * Ly
print(ytrans)
Lx_total := Lx * nsteps
Ly_total := Ly + ytrans * (nsteps - 1)
Lz := Lx_total

Nx := floor(Lx_total/cx)
Ny := floor(Ly_total/cy)
Nz := Nx
print(Lx_total)
print(Ly_total)
print(Nx)
print(Ny)
print(Nz)

SetGridsize(Nx, Ny, Nz)
SetCellsize(cx, cy, cz)


//--------------------------------------------------------------------------//
// Create a stepped geometry
//--------------------------------------------------------------------------//
xtr0 := -0.5 * (Lx_total - Lx)
ytr0 := -0.5 * (Ly_total - Ly)
s := cuboid(Lx, Ly, Lz).Transl(xtr0, ytr0, 0)

for i:=1; i<nsteps; i++{
    xtr := xtr0 + i * xtrans
      ytr := ytr0 + i * ytrans
        snew := cuboid(Lx, Ly, Lz).Transl(xtr, ytr, 0)
          s = s.add(snew)
}

setgeom(s.intersect(cylinder(Lx_total, inf).RotX(90*pi/180)))


//--------------------------------------------------------------------------//
// Define Co magnetic properties
//--------------------------------------------------------------------------//
Msat  = 1400e3
Aex   = 18e-12


//--------------------------------------------------------------------------//
// B field ramp parameters
//--------------------------------------------------------------------------//
Bmax   := ${Bmax}
Bstep  := ${Bstep}
Bdelta :=  2 * pi / 180.0 
Btheta :=  ${theta} * pi / 180.0 + Bdelta
Bphi   :=  ${phi} * pi / 180.0 + Bdelta


alph1 := sin(Btheta) * cos(Bphi)
alph2 := sin(Btheta) * sin(Bphi)
alph3 := cos(Btheta)


//--------------------------------------------------------------------------//
// Set initial magnetization
//--------------------------------------------------------------------------//
m = uniform(0, 0, 1)
// m = RandomMag()
// relax()


//--------------------------------------------------------------------------//
// Setup output
//--------------------------------------------------------------------------//
saveas(B_demag, "B_demag")
saveas(m, "m")

MinimizerStop = 1e-6
TableAdd(B_ext)


//--------------------------------------------------------------------------//
// Run
//--------------------------------------------------------------------------//

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

