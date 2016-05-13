/*
	Frozen spins in half the geometry
*/

//--------------------------------------------------------------------------//
//  Parameters
//--------------------------------------------------------------------------//

// Mesh
  N := 128
  a := 4.0e-9

// Grains
  grain_size := 20e-9
  rand_seed := 153464
  max_region := 254

// Cobalt overlayer
  CoMsat := 800e3
  CoAex := 13e-12
	K := 450e3

// AFM underlayer
  RegionBFO := 255
	BFOMsat := 800e3
	BFOAex := 13e-12
  layer_exch_scale := ${exch_scale}

// Applied field
  Bmax   := 400.0e-3
  Bstep  :=  4.0e-3
  Bdelta :=  2 * pi / 180.0
  Btheta :=  90 * pi / 180.0 + Bdelta
  Bphi   :=  0 * pi / 180.0 + Bdelta


//--------------------------------------------------------------------------//
// Setup
//--------------------------------------------------------------------------//

// geometry
  setgridsize(N, N, 2)
  setcellsize(a, a, a)
  setGeom(circle(N*a))


// grains and regions
  ext_makegrains(grain_size, max_region, rand_seed)
  defregion(RegionBFO, zrange(-inf, 0))
  frozenspins.setRegion(RegionBFO, 1)
  defregion(254, circle(N*a).inverse())


// Overlayer
for i:=0; i<max_region; i++{
	// random cubic anisotropy direction
	axis1  := vector(randNorm(), randNorm(), randNorm())
	helper := vector(randNorm(), randNorm(), randNorm())
	axis2  := axis1.cross(helper)  // perpendicular to axis1
	AnisC1.SetRegion(i, axis1)     // axes need not be normalized
	AnisC2.SetRegion(i, axis2)
	Msat.SetRegion(i, CoMsat)
	Aex.SetRegion(i, CoAex)
  m.setRegion(i, uniform(randNorm(), randNorm(), randNorm()))

	// random 10% anisotropy variation
	Kc1.SetRegion(i, K + randNorm() * 0.1 * K)
}

// reduce exchange coupling between grains by
for i:=0; i<max_region; i++{
  ext_ScaleExchange(i, RegionBFO, layer_exch_scale)
	for j:=i+1; j<max_region; j++{
		ext_ScaleExchange(i, j, 0.9)
	}
}

// AFM substrate
  Msat.SetRegion(RegionBFO, CoMsat)
  Aex.SetRegion(RegionBFO, CoAex)
  m.SetRegion(RegionBFO, uniform(-1, 0, 0))


// output
  saveas(B_demag, "B_demag")
  saveas(m, "m")
  save(regions)
  save(Kc1)
  save(AnisC1)
  save(AnisC2)

  MinimizerStop = 1e-6
  TableAdd(B_ext)

// Compute field direction
  alph1 := sin(Btheta) * cos(Bphi)
  alph2 := sin(Btheta) * sin(Bphi)
  alph3 := cos(Btheta)


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
