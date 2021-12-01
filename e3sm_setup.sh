#!/bin/bash

#--------------------------------------------------------
#
# setup for running E3SM on GreatLakes (call in .bashrc)
#
#--------------------------------------------------------


# ---------- from Christiane's CESM installation instructions ---------
module load ncview
module load ncl
module load nco
module load ghostscript
module load intel/18.0.5
module load openmpi/3.1.4
module load hdf5/1.8.21 cmake
module load netcdf-c/4.6.2 netcdf-fortran/4.4.5

# from Owen's instructions
# https://open-lab-notebook.glitch.me/posts/installing-homme/
eval "$(perl -I$HOME/util/perl5/lib/perl5 -Mlocal::lib=$HOME/util/perl5)"; export PERL5LIB=$HOME/util/perl5:$PERL5LIB
