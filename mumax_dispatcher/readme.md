# mumax-dispatcher

## Templating

  - Use the syntax ${key} instead of a float somewhere in your mumax input files.
  
  - Then make a toml file with the dead simple sytax
      key1 = 1.0
	  key2 = 2.0
	  key3 = (1.0, 2.0, 3.0)
	  
  - This runs three simulations. Key1 and key2 will be constant, but loop over key3.
  
  