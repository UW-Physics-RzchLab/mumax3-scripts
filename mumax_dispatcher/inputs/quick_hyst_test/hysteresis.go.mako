SetGridsize(32, 32, 1)
SetCellsize(4e-9, 4e-9, 30e-9)

Msat  = 800e3
Aex = ${Aex}

m = randomMag()
relax()         // high-energy states best minimized by relax()


Bmax  := 100.0e-3
Bstep :=  1.0e-3
MinimizerStop = 1e-6
TableAdd(B_ext)

for B:=0.0; B<=Bmax; B+=Bstep{
    B_ext = vector(B, 0, 0)
    minimize()   // small changes best minimized by minimize()
    tablesave()
}

for B:=Bmax; B>=-Bmax; B-=Bstep{
    B_ext = vector(B, 0, 0)
    minimize()   // small changes best minimized by minimize()
    tablesave()
}

for B:=-Bmax; B<=Bmax; B+=Bstep{
    B_ext = vector(B, 0, 0)
    minimize()   // small changes best minimized by minimize()
    tablesave()
}
