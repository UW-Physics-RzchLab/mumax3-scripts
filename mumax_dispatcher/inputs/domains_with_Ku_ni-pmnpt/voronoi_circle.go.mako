N := ${gridN}
c := 10e-9 // was 4e-9
d := 10e-9 // was 20e-9
setgridsize(N, N, 1)
setcellsize(c, c, d)

setGeom(circle(N*c))


// define grains with region number 0-255
grainSize  := 40e-9  // m
// randomSeed := 123455
randomSeed := 283634
maxRegion  := 255
ext_makegrains(grainSize, maxRegion, randomSeed)
defregion(256, circle(N*c).inverse()) // region 256 is outside, not really needed


alpha = 1
Kc1 = 1000
Aex   = 8.2e-12
Msat  = 493e3
enabledemag=${enable_demag}

// Kc1
K := ${Kc1}

// set random parameters per region
for i:=0; i<maxRegion; i++{
	// random cubic anisotropy direction
	axis1  := vector(randNorm(), randNorm(), randNorm())
	helper := vector(randNorm(), randNorm(), randNorm())
	axis2  := axis1.cross(helper)  // perpendicular to axis1
	AnisC1.SetRegion(i, axis1)     // axes need not be normalized
	AnisC2.SetRegion(i, axis2)

	// random 15% anisotropy variation
	Kc1.SetRegion(i, K + randNorm() * ${Kc1_varfrac} * K)

  // Set Ku
  Ku1.SetRegion(i, ${Ku1})
  anisU.SetRegion(i, vector(1, 0, 0))


	m.setRegion(i, uniform(randNorm(), randNorm(), randNorm()))
}

// reduce exchange coupling between grains by 20%
for i:=0; i<maxRegion; i++{
	for j:=i+1; j<maxRegion; j++{
		ext_ScaleExchange(i, j, ${grain_coupling})
	}
}

Kc1.SetRegion(50, K  * ${pinmult})
Kc1.SetRegion(100, K * ${pinmult})
Kc1.SetRegion(202, K * ${pinmult})
Kc1.SetRegion(34, K  * ${pinmult})
Kc1.SetRegion(64, K  * ${pinmult})
Kc1.SetRegion(51, K  * ${pinmult})
Kc1.SetRegion(111, K * ${pinmult})
Kc1.SetRegion(212, K * ${pinmult})
Kc1.SetRegion(35, K  * ${pinmult})
Kc1.SetRegion(65, K  * ${pinmult})

// Applied field
  Bmax   :=  ${Bmax}
	Bfastup  := ${Bfastup}
	Bfastdn  := ${Bfastdn}
	Bstep_fast := ${Bstep_fast}
  Bstep  :=  ${Bstep}
  Bdelta :=  ${Bdelta} * pi / 180.0
  Btheta :=  ${Btheta} * pi / 180.0 + Bdelta
  Bphi   :=  ${Bphi} * pi / 180.0 + Bdelta

// Compute field direction
  alph1 := sin(Btheta) * cos(Bphi)
  alph2 := sin(Btheta) * sin(Bphi)
  alph3 := cos(Btheta)

// m =	Uniform(alph1, alph2, alph3)
// m = RandomMag()
// m = Vortex(1,-1).Add(0.1, randomMag())
B_ext = vector(Bmax * alph1, Bmax * alph2, Bmax * alph3)
relax()
// run(.1e-9)

save(regions)
save(Kc1)
save(AnisC1)
save(AnisC2)
save(m)
save(exchCoupling)

MinimizerStop = 1e-6
TableAdd(B_ext)

dsq := 20
i0sq := N / 4 + dsq
i1sq :=  3 * N / 4 - dsq
mcenter := Crop(m, i0sq, i1sq, i0sq, i1sq, 0, 1)
save(mcenter)
TableAdd(mcenter)

out_counter := 0

for B:=Bmax; B>=Bfastdn; B-=Bstep_fast{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
		if Mod(out_counter, 2) == 1 {
			save(m)
		}
		out_counter = out_counter + 1
}

for B:=Bfastdn; B>=-Bfastup; B-=Bstep{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
		save(m)
		out_counter = out_counter + 1
}

for B:=-Bfastup; B>=-Bmax; B-=Bstep_fast{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
		if Mod(out_counter, 2) == 1 {
			save(m)
		}
		out_counter = out_counter + 1
}

for B:=-Bmax; B<=-Bfastdn; B+=Bstep_fast{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
		if Mod(out_counter, 2) == 1 {
			save(m)
		}
		out_counter = out_counter + 1
}

for B:=-Bfastdn; B<=Bfastup; B+=Bstep{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
		save(m)
		out_counter = out_counter + 1
}

for B:=Bfastup; B<=Bmax; B+=Bstep_fast{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
		if Mod(out_counter, 2) == 1 {
			save(m)
		}
		out_counter = out_counter + 1
}
