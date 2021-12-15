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
Per Owen: Then for every module listed in `CLDERA_E3SM/cime/scripts/Tools/e3sm_check_enve3`, run `cpanm {MODULENAME}`. You may need to read error messages to determine what dependencies are, because perl is terrible.
```
cpanm XML::LibXML
cpanm XML::SAX
cpanm XML::SAX::Exception
cpanm Switch
```

#### 6. 
Finally, we need the GreatLakes machine configuration details to be known to CIME (in other words, CIME needs to be [ported](https://esmci.github.io/cime/versions/master/html/users_guide/porting-cime.html)). We could edit `$CIMEROOT/config/$model/machines/config_machines.xml` and add an appropriate section for the machine, or we can use your CIME user config directory at `$HOME/.cime`. The latter method is arguably cleaner, and the one that these instructions endorse. Backup any existing contents of `.cime` that you have, and then
```
cp -r e3sm_greatlakes_install/.cime.e3sm ~/.cime
```
And be sure to rename all relevant paths to your own in `~/.cime/bash.source` 

If you'd like to keep several versions of `.cime` around (e.g. for using CESM), retaining multiple versions with name modifiers (e.g. `.cime.e3sm`) and linking to `.cime` when needed is an easy solution.

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
Now, adding complexity and building components. First, try building a simple aquaplanet case on a coarse grid (compset 'F-EAM-AQP1' on grid 'ne4pg2_ne4pg2'). The `run_e3sm.template.sh` has been edited for this purpose. All edits have been marked with a comment beginning with `JH` in `run_e3sm.template.greatlakes.sh`. Edit the script so that the following paths reflect your own:
```
CODE_ROOT="/home/hollowed/E3SM/CLDERA-E3SM"
CASE_ROOT="/scratch/cjablono_root/cjablono1/hollowed/E3SM/E3SMv2/${CASE_NAME}"
```
and then run the script
```
cd ~
./e3sm_greatlakes_install/run_e3sm.template.greatlakes.sh
```

This step is currently crashing on compilation of `kokkos`, with an error
```
C++14-compliant compiler detected, but unable to compile C++14 or later
program.  Verify that Intel:18.0.5.20180823 is set up correctly (e.g.,
check that correct library headers are being used).
```
