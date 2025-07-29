# Atari System-II Arcade

## About  
FPGA implementation of Atari System 2 arcade platform from 1985.  
Based on the SP-275, SP-290, SP-292, SP-294 SP-308 schematics  

System-2 supported game cartridges according to MAME  
* Accelerator (unreleased prototype)
* Gremlins (unreleased prototype)

* Paperboy (1985)
* Super Sprint (1986)
* Championship Sprint (1986)
* 720 degrees (1986)
* APB: All Points Bulletin (1987)

# WORK IN PROGRESS  
Early stages, totally non functional  
* In simulation the T11 CPU can execute instructions  
* Audio non existent, needs to be coded  
* Video section appears fully working in simulation when RAMs are preloaded with data dumped from MAME  
#### Paperboy Title screen  
[![Frame from Simulation](doc/paperboy1.gif)](doc/paperboy1.gif) 
#### Paperboy in game  
[![Frame from Simulation](doc/paperboy2.gif)](doc/paperboy2.gif) 
#### Championship Sprint in game  
[![Frame from Simulation](doc/csprint.gif)](doc/csprint.gif) 

# Thanks
Many thanks to Colin Davies (ColinD - UKVAC) for supporting the preservation of old arcades and dumping the contents of the 82S131 PROM from the Atari Championship Sprint arcade video board. This allowed the video circuit to properly display the Motion Objects (sprites). 
