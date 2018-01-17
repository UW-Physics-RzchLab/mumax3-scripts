# mumax-dispatcher

## Templating

  - Use the syntax ${key} instead of a float somewhere in your mumax input files.
  
  - Then make a toml file with the dead simple sytax
      key1 = 1.0
      key2 = 2.0
      key3 = (1.0, 2.0, 3.0)
	  
  - This runs three simulations. Key1 and key2 will be constant, but loop over key3.



## Running the Dispatcher




### Ni PMN-PT Simulations Late 2017 - Early 2018

Open Anaconda Propmt in C:\Users\rzchlab\mumax3-scripts\mumax-dispatcher

  - 180110 Simulation #17

python mumax_dispatcher.py^
 "C:\Users\rzchlab\github\mumax3-scripts\mumax_dispatcher\inputs\domains_with_Ku_ni-pmnpt\voronoi_circle.go.mako"^
 "C:\Users\rzchlab\github\mumax3-scripts\mumax_dispatcher\inputs\domains_with_Ku_ni-pmnpt\run_params.toml"^
 Ku=${Ku1}_pinmult=${pinmult} ^
 "G:\box\jjirwin\Box Sync\mumax3_output\julian_irwin\save\Ni_pmn-pt_simulations_171214\17_vary_Ku_pinmult=200_10sites"^
 -m "C:\Users\rzchlab\mumax"^
 -r


