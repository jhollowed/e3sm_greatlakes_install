# E3SM Great Lakes installation instructions

## Configure the environment

#### 1. 
Clone version 2 of the E3SM model (change `~` in the following steps to your desired install location):

```
cd ~
git clone -b v2.0.0 --recursive git@github.com:sandialabs/CLDERA-E3SM.git
```
    
#### 2. 
Clone this repository
  
```
cd ~
git clone git@github.com:jhollowed/e3sm_greatlakes_install.git
```
    
#### 3. 
Source `e3sm_setup.sh` in your `bashrc`:
    
``` 
source ~/e3sm_greatlakes_install/e3sm_setup.sh
```
    
This should replace any content in your `.bashrc` or other sources setup files relevant to CESM or any other installs.
 
#### 4. 
Restart terminal

#### 5. 
You will get compilation errors without a valid Switch installation at some location in your Perl @ICN. Apparently the default Great Lakes Perl installation does not have this, so let's install the module locally. This will also require us to install all the Perl modules required by E3SM that may have been in the default configuration. Run the following to get perl to install locally
```
cpan App::cpanminus
``` 
Next, run
```
cpanm LWP
```
Per Owen: Then for every module listed in `CLDERA_E3SM/cime/scripts/Tools/e3sm_check_enve3`, run `cpanm {MODULENAME}`. For our purposes, this is: 
```
cpanm XML::LibXML
cpanm XML::SAX
cpanm XML::SAX::Exception
cpanm Switch
```
You may need to read error messages to determine what dependencies are, because perl is terrible.

#### 6. 
Finally, we need the GreatLakes machine configuration details to be known to CIME (in other words, CIME needs to be [ported](https://esmci.github.io/cime/versions/master/html/users_guide/porting-cime.html)). We could edit `$CIMEROOT/config/$model/machines/config_machines.xml` and add an appropriate section for the machine, or we can use your CIME user config directory at `$HOME/.cime`. The latter method is arguably cleaner, and the one that these instructions endorse. Backup any existing contents of `.cime` that you have, and then
```
cp -r e3sm_greatlakes_install/.cime.e3sm ~/.cime
```
And be sure to rename all relevant paths to your own in `~/.cime/bash.source` 

If you'd like to keep several versions of `.cime` around (e.g. for using CESM), retaining multiple versions with name modifiers (e.g. `.cime.e3sm`) and linking to `.cime` when needed is an easy solution.

&nbsp; 

&nbsp; 

## Try to compile something

#### 7. 
We can compile some test cases in increasing complexity, to make sure things are working.

#### Dead compset
 First, attempt to create and compile a case with the compset 'X' (all components are DEAD):
```
CLDERA-E3SM/cime/scripts/create_newcase --case X_case --compset X --res f19_g16 --mach greatlakes
cd X_case
./case.setup
./case.build
```

#### Stub compset
Next, attempt to create and compile a case with the compset 'S' (all components are STUB):
```
CLDERA-E3SM/cime/scripts/create_newcase --case S_case --compset S --res f19_g16 --mach greatlakes
cd S_case
./case.setup
./case.build
```

#### 8. 
Now, adding complexity and building components. First, try building a simple aquaplanet case on a coarse grid (compset 'F-EAM-AQP1' on grid 'ne4pg2_ne4pg2'). The `run_e3sm.template.sh` has been edited for this purpose. All edits (with respect to the original version of the script provided by DOE) have been marked with a comment beginning with `JH` in `run_e3sm.template.greatlakes.sh`. Some leftover hard-coded paths, such as `RUN_REFDIR`, point to locations on Chrysalis; these are not used at any time and don't need to be changed. Edit the script so that the following paths reflect your own:
```
CODE_ROOT="/home/hollowed/E3SM/CLDERA-E3SM"
CASE_ROOT="/scratch/cjablono_root/cjablono1/hollowed/E3SM/E3SMv2/${CASE_NAME}"
```
and then run the script
```
cd ~
./e3sm_greatlakes_install/run_e3sm.template.greatlakes.sh
```

This step is currently crashing on compilation of `kokkos`. The referenced log file will report an error
```
C++14-compliant compiler detected, but unable to compile C++14 or later
program.  Verify that Intel:18.0.5.20180823 is set up correctly (e.g.,
check that correct library headers are being used).
```


## Attempt at a fix

From Owen Hughes:

My best guess about what is causing problems:
Note the following github issue: https://github.com/trilinos/Trilinos/issues/8720

This issue lays out that the E3SM dependency Kokkos is unable to compile c++14 code because the referenced version of gcc (and associated std headers) does not have support for standard features of C++14. Intel compilers such as icpc can compile with a different gcc by specifying `-gcc-name=/path/to/gcc` at compile time. Because Kokkos is the main source of problems, we have to force Kokkos (as well as the rest of E3SM) to use a more recent version of GCC.

Note: the exact invocation that causes kokkos to fail to build is
`mpicc /home/owhughes/E3SM/CLDERA-E3SM/externals/kokkos/cmake/compile_tests/cplusplus14.cpp -std=c++14`, and this succeeds if you do `mpicc /home/owhughes/E3SM/CLDERA-E3SM/externals/kokkos/cmake/compile_tests/cplusplus14.cpp -std=c++14 -gcc-name=/sw/arcts/centos7/gcc/8.2.0/bin/gcc`.

If you have followed this repository's instructions up to step 8, and customized your `bash.source` file, then you can get Kokkos to succuessfully compile by adding 

    <KOKKOS_OPTIONS>--cxxflags="-gcc-name=/sw/arcts/centos7/gcc/8.2.0/bin/gcc"</KOKKOS_OPTIONS> 
    
to `e3sm_greatlakes_install/.cime.e3sm` under the intel compiler tag (near line `53`), and then repeat step (6) above (pushing the changes to `~/.cime`). 

The compile failure should then migrate a bit further along, and occur when building E3SM proper, with a deluge of error messages that indicate that E3SM is not building against the right version of gcc either.

This indicates that if you can ensure that the entire cime infrastructure for E3SM searches first for gcc binaries, headers, and libraries from a more recent gcc version, it may build successfully.
