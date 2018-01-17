N := ${gridN}
c := 4e-9
d := 20e-9
setgridsize(N, N, 1)
setcellsize(c, c, d)

setGeom(circle(N*c))

// define grains with region number 0-255
grainSize  := 30e-9  // m
randomSeed := 123455
maxRegion  := 255
ext_makegrains(grainSize, maxRegion, randomSeed)

defregion(256, circle(N*c).inverse()) // region 256 is outside, not really needed

alpha = 3
Kc1 = 1000
Aex   = 13e-12
Msat  = 800e3

// set random parameters per region
for i:=0; i<maxRegion; i++{
	// random cubic anisotropy direction
	axis1  := vector(randNorm(), randNorm(), randNorm())
	helper := vector(randNorm(), randNorm(), randNorm())
	axis2  := axis1.cross(helper)  // perpendicular to axis1
	AnisC1.SetRegion(i, axis1)     // axes need not be normalized
	AnisC2.SetRegion(i, axis2)

	// random 15% anisotropy variation
	K := 1e3
	Kc1.SetRegion(i, K + randNorm() * 0.15 * K)

  // Set Ku
  Ku1.SetRegion(i, ${Ku1})
  anisU.SetRegion(i, vector(1, 0, 0))
}

// reduce exchange coupling between grains by 20%
for i:=0; i<maxRegion; i++{
	for j:=i+1; j<maxRegion; j++{
		ext_ScaleExchange(i, j, 0.8)
	}
}

// Applied field
  Bmax   :=  ${Bmax}
	Bfast  := ${Bfast}
	Bslow  := ${Bslow}
  Bstep  :=  ${Bstep}
  Bdelta :=  ${Bdelta} * pi / 180.0
  Btheta :=  ${Btheta} * pi / 180.0 + Bdelta
  Bphi   :=  ${Bphi} * pi / 180.0 + Bdelta

// Compute field direction
  alph1 := sin(Btheta) * cos(Bphi)
  alph2 := sin(Btheta) * sin(Bphi)
  alph3 := cos(Btheta)

m = 	Uniform(alph1, alph2, alph3)
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

for B:=Bmax; B>=-Bmax; B-=Bstep{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
}

for B:=-Bmax; B<=Bmax; B+=Bstep{
    B_ext = vector(B * alph1, B * alph2, B * alph3)
    minimize()   // small changes best minimized by minimize()
    tablesave()
  }
