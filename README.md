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
Very early stages, totally non functional  
* In simulation the T11 CPU can execute instructions  
* Audio non existent, needs to be coded  

Output of simulation of video circuit with RAMs preloaded with data dumped from MAME  
Only PlayField (PF) and AlphaNumerics (AN) data rendered for now,  MotionObjects (MO) is being worked on.  
[![Frame from Simulation](doc/F1.AL.PF.gif)](doc/F1.AL.PF.gif) 

# Thanks
Many thanks to Colin Davies (ColinD - UKVAC) for supporting the preservation of old arcades and dumping the contents of the 82S131 PROM from the Atari Championship Sprint arcade video board. This allowed the video circuit to properly display the Motion Objects (sprites). 
