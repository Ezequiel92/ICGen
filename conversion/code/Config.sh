####################################################################################################
#                                       Compile-time options                                       #
####################################################################################################

#-------------------------------------- Basic operation mode
ADDBACKGROUNDGRID=32                    # Re-grid hydrodynamics quantities on a Oct-tree AMR grid.

#-------------------------------------- Gravity
GRAVITY_NOT_PERIODIC                    # Gravity is not treated periodically.

#-------------------------------------- Gravity softening
NSOFTTYPES=2                            # Number of different softening values to which particle types can be mapped.

#-------------------------------------- Input options
GENERATE_GAS_IN_ICS                     # Generates gas from dark matter only ICs.

#-------------------------------------- Output options
HAVE_HDF5                               # The code will be compiled with support for input and output in the HDF5 format.
HDF5_FILTERS                            # Activate snapshot compression and checksum for HDF5 output.
