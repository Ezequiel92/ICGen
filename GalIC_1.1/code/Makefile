#/*******************************************************************************
# * This file is part of the GALIC code developed by D. Yurin and V. Springel.
# *
# * Copyright (c) 2014
# * Denis Yurin (denis.yurin@h-its.org) 
# * Volker Springel (volker.springel@h-its.org)
# *******************************************************************************/

EXEC      = GalIC
CONFIG    = Config.sh
BUILD_DIR = build
SRC_DIR   = src

###################
#determine SYSTYPE#
###################

ifdef SYSTYPE
SYSTYPE := "$(SYSTYPE)"
-include Makefile.systype
else
include Makefile.systype
endif

MAKEFILES = Makefile config-makefile
ifeq ($(wildcard Makefile.systype), Makefile.systype)
MAKEFILES += Makefile.systype
endif

PERL	 = /usr/bin/perl
RESULT     := $(shell CONFIG=$(CONFIG) PERL=$(PERL) BUILD_DIR=$(BUILD_DIR) make -f config-makefile)
CONFIGVARS := $(shell cat $(BUILD_DIR)/galicconfig.h)

MPICHLIB = -lmpich
GMPLIB   = -lgmp
GSLLIB   = -lgsl -lgslcblas
MATHLIB  = -lm

# RAVEN
ifeq ($(SYSTYPE),"RAVEN")
CC        = mpicc -std=c11 -Wall
CC       += -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-variable -Wno-unknown-pragmas
CC       += -Wno-stringop-truncation -Wno-restrict -Wno-maybe-uninitialized -Wno-format-overflow -Wno-array-parameter
OPTIMIZE  = -O2 -march=icelake-server -mtune=icelake-server

MPICHLIB  = -lmpi
GSL_INCL  = -I$(GSL_HOME)/include
GSL_LIBS  = -L$(GSL_HOME)/lib -Wl,-rpath,$(GSL_HOME)/lib
FFTW_INCL = -I$(FFTW_HOME)/include
FFTW_LIBS = -L$(FFTW_HOME)/lib -lfftw3 -Wl,-rpath,$(FFTW_HOME)/lib
HDF5INCL  = -I$(HDF5_HOME)/include -DH5_USE_16_API
HDF5LIB   = -L$(HDF5_HOME)/lib -lhdf5 -lz -Wl,-rpath,$(HDF5_HOME)/lib
endif
# end of RAVEN

# FREYA
ifeq ($(SYSTYPE),"FREYA")
CC        = mpicc -std=c11 -Wall
CC       += -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-variable -Wno-unknown-pragmas
CC       += -Wno-stringop-truncation -Wno-restrict -Wno-maybe-uninitialized -Wno-format-overflow -Wno-array-parameter
OPTIMIZE  = -O2 -march=skylake-avx512 -mtune=skylake-avx512

MPICHLIB  = -lmpi
GSL_INCL  = -I$(GSL_HOME)/include
GSL_LIBS  = -L$(GSL_HOME)/lib -Wl,-rpath,$(GSL_HOME)/lib
FFTW_INCL = -I$(FFTW_HOME)/include
FFTW_LIB  = -L$(FFTW_HOME)/lib -lfftw3 -Wl,-rpath,$(FFTW_HOME)/lib
HDF5INCL  = -I$(HDF5_HOME)/include -DH5_USE_16_API
HDF5LIB   = -L$(HDF5_HOME)/lib -lhdf5 -lz -Wl,-rpath,$(HDF5_HOME)/lib
endif
# end of FREYA

# COBRA
ifeq ($(SYSTYPE),"COBRA")
CC         = mpicc -std=c11 -Wall
CC        += -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-variable -Wno-unknown-pragmas
CC        += -Wno-stringop-truncation -Wno-restrict -Wno-maybe-uninitialized -Wno-format-overflow -Wno-array-parameter
OPTIMIZE   = -O2 -march=skylake-avx512 -mtune=skylake-avx512

MPICHLIB  = -lmpi
GSL_INCL  = -I$(GSL_HOME)/include
GSL_LIBS  = -L$(GSL_HOME)/lib -Wl,-rpath,$(GSL_HOME)/lib
FFTW_INCL = -I$(FFTW_HOME)/include
FFTW_LIBS = -L$(FFTW_HOME)/lib -lfftw3 -Wl,-rpath,$(FFTW_HOME)/lib
HDF5INCL  = -I$(HDF5_HOME)/include -DH5_USE_16_API
HDF5LIB   = -L$(HDF5_HOME)/lib -lhdf5 -lz -Wl,-rpath,$(HDF5_HOME)/lib
endif
# end of COBRA

ifndef LINKER
LINKER = $(CC)
endif

##########################################
#determine the needed object/header files#
##########################################

SUBDIRS = . 

OBJS =   main.o allocate.o  allvars.o  disk.o   grid.o  bulge.o  set_particles.o parallel_sort.o \
	     halo.o  init.o  io.o  mymalloc.o  orbit_response.o  parameters.o  structure.o  system.o  disp_fields.o \
	     forcetree/gravtree.o forcetree/forcetree.o forcetree/forcetree_walk.o domain/peano.o domain/pqueue.o \
	     domain/domain.o domain/domain_balance.o domain/domain_counttogo.o  domain/domain_exchange.o \
	     domain/domain_rearrange.o domain/domain_sort_kernels.o domain/domain_toplevel.o domain/domain_vars.o domain/domain_box.o


INCL += allvars.h proto.h

SUBDIRS += forcetree domain

################################
#determine the needed libraries#
################################

ifneq (HAVE_HDF5,$(findstring HAVE_HDF5,$(CONFIGVARS)))
HDF5LIB  = 
endif

ifeq (NUM_THREADS,$(findstring NUM_THREADS,$(CONFIGVARS)))
THREAD_LIB = 
endif

##########################
#combine compiler options#
##########################

CFLAGS = $(OPTIMIZE) $(OPT) $(HDF5INCL) $(GSL_INCL) $(FFTW_INCL) $(ODE_INCL) $(GMP_INCL) $(MKL_INCL) $(CUDA_INCL) -I$(BUILD_DIR)

CFLAGS_CUDA = $(CUDA_OPTIMIZE) $(OPT) $(GSL_INCL) $(FFTW_INCL) $(HDF5INCL) $(ODE_INCL) $(GMP_INCL) $(MKL_INCL) $(CUDA_INCL) -I$(BUILD_DIR)

LIBS = $(MATHLIB) $(HDF5LIB) $(MPICHLIB) $(GSL_LIBS) $(GSLLIB) $(FFTW_LIB) $(GMP_LIBS) $(GMPLIB) $(ODE_LIB) $(MKL_LIBS) $(THREAD_LIB) $(CUDA_LIBS)


SUBDIRS := $(addprefix $(BUILD_DIR)/,$(SUBDIRS))
OBJS := $(addprefix $(BUILD_DIR)/,$(OBJS)) $(BUILD_DIR)/compile_time_info.o
INCL := $(addprefix $(SRC_DIR)/,$(INCL)) $(BUILD_DIR)/galicconfig.h

################
#create subdirs#
################

RESULT := $(shell mkdir -p $(SUBDIRS))

#############
#build rules#
#############

all: $(EXEC)

$(EXEC): $(OBJS)
	$(LINKER) $(OPTIMIZE) $(OBJS) $(LIBS) -o $(EXEC)

clean:
	rm -f $(OBJS) $(EXEC) lib$(LIBRARY).a
	rm -f $(BUILD_DIR)/compile_time_info.c $(BUILD_DIR)/galicconfig.h

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(INCL) $(MAKEFILES)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/compile_time_info.o: $(BUILD_DIR)/compile_time_info.c $(MAKEFILES)
	$(CC) $(CFLAGS) -c $< -o $@
 