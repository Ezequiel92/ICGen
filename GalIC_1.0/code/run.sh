#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

main() {
	# Make environment folders
	mkdir --mode=744 -p ../build 
	mkdir --mode=744 -p ../output
	mkdir --mode=744 -p ../../output
	mkdir --mode=744 -p ../../conversion/ICs

	# Make code executable
	chmod -R 744 ../../../ic_gen

    # Load modules
    if [[ "${HOSTNAME::-2}" = "raven" ]] || [[ "${HOSTNAME::-2}" = "cobra" ]]; then
        module purge
        module --silent load hwloc
        module --silent load gcc/12
        module --silent load openmpi/4
        module --silent load gsl
        module --silent load fftw-mpi
        module --silent load hdf5-mpi
    elif [[ "${HOSTNAME::-2}" = "freya" ]]; then
        module purge
        module --silent load hwloc
        module --silent load gcc/11
        module --silent load openmpi/4
        module --silent load gsl
        module --silent load fftw-mpi
        module --silent load hdf5-mpi
    fi

    # Set the system type variable and the correct running command
    if [[ "${HOSTNAME::-2}" = "raven" ]]; then
        export SYSTYPE=RAVEN
        sed -i "s&mpiexec -np \"\${SLURM_NPROCS}\"&srun&" ./slurm_job.sh
    elif [[ "${HOSTNAME::-2}" = "freya" ]]; then
        export SYSTYPE=FREYA
        sed -i "s&srun&mpiexec -np \"\${SLURM_NPROCS}\"&" ./slurm_job.sh
    elif [[ "${HOSTNAME::-2}" = "cobra" ]]; then
        export SYSTYPE=COBRA
        sed -i "s&srun&mpiexec -np \"\${SLURM_NPROCS}\"&" ./slurm_job.sh
    fi

	# Set the correct number of particles and the softening lengths
	if [[ $# -eq 0 ]]; then
		NUMBER="32768"
		HSML="0.3"
	else
		NUMBER=$(( ${1}**3 ))
		SCALE=$(( ${1}/32 ))
		if [[ $SCALE -eq 1 ]]; then
			HSML="0.3"
		elif [[ $SCALE -eq 2 ]];then
			HSML="0.15"
		elif [[ $SCALE -eq 4 ]];then
			HSML="0.075"
		elif [[ $SCALE -eq 8 ]];then
			HSML="0.0375"
		else
			echo "Only the resolutions 32, 64, 128 and 256 are allow!"
			exit 1
		fi
	fi

	# Set the correct softening lengths
	sed -i "s&^N_HALO.*&N_HALO \t\t $NUMBER \t % Number of particles in dark halo.&" ./param.txt
	sed -i "s&^SofteningComovingType0.*&SofteningComovingType0 \t\t $HSML&" ../../conversion/code/param.txt
	sed -i "s&^SofteningComovingType1.*&SofteningComovingType1 \t\t $HSML&" ../../conversion/code/param.txt
	sed -i "s&^SofteningMaxPhysType0.*&SofteningMaxPhysType0 \t\t $HSML&" ../../conversion/code/param.txt
	sed -i "s&^SofteningMaxPhysType1.*&SofteningMaxPhysType1 \t\t $HSML&" ../../conversion/code/param.txt

	# Compile the code
	make -j8 CONFIG=./Config.sh BUILD_DIR=../build EXEC=../build/GalIC

	# Send the job to the cluster
	if [[ $? -eq 0 ]]; then
		sbatch ./slurm_job.sh
	fi
}

main "$@"
