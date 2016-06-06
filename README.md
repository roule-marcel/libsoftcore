# libsoftcore
A HDL resources library for building softcores

This project contains external sources, such as the openMSP430 MCU from opencores.org.

## Get the openmsp430 sources
The sources are already available in the directory named ./opencores/openmsp430/

    svn export --username $USER http://opencores.org/ocsvn/openmsp430/openmsp430/trunk/ openmsp430

with $USER the name of your account on http://opencores.org/

## Organization of the lib
* opencores/
    * contains the svn repositories of the sources from opencores
* sim/
    * contains the modelsim simulation resources
* src/
    * contains the various sources

## HowTo install Quartus and Modelsim
You may need a version of Modelsim to simulate the stuff in this library.
The modelsim version used in the ModelSim-Altera Starter Edition which you can get for free with Quartus.
### Installation:
    wget http://download.altera.com/akdlm/software/acdsinst/15.1/185/ib_tar/Quartus-lite-15.1.0.185-linux.tar

(To compile stuff for the DE1, you need Quartus 13.0sp1. No documentation because it's temporary™.)

    tar xvf Quartus-lite-15.1.0.185-linux.tar
    ./setup

    sudo apt-get install libxft2:i386 #We're in 2016 yo!

Add the following line in ~/.bashrc:
    export PATH=$PATH:/opt/altera_lite/15.1/modelsim_ase/bin

### Launch Quartus:
    $QUARTUS_INSTALL_PATH/15.1/nios2eds/nios2_command_shell.sh #To deal with multiple installs
    quartus
