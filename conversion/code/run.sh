#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

main() {
	if [[ ! -f "../ICs/dm_ic.hdf5" ]]; then
		echo "dm_ic.hdf5 does not exist, something went wrong with the GalIC run."
	fi

	# Make environment folders
	mkdir --mode=744 -p ../build
	mkdir --mode=744 -p ../output

	chmod -R 744 ../code

    # Load modules
    if [[ "${HOSTNAME::-2}" = "raven" ]]; then
        module purge
        module --silent load hwloc
        module --silent load gcc/15
        module --silent load openmpi/5.0
        module --silent load fftw-mpi
        module --silent load hdf5-mpi
        module --silent load gsl
    elif [[ "${HOSTNAME::-2}" = "freya" ]]; then
        module purge
        module --silent load hwloc
        module --silent load gcc/11
        module --silent load openmpi/4
        module --silent load fftw-mpi
        module --silent load hdf5-mpi
        module --silent load gsl
    elif [[ "${HOSTNAME::-2}" = "viper" ]]; then
        module purge
        module --silent load hwloc
        module --silent load gcc/15
        module --silent load openmpi/5.0
        module --silent load fftw-mpi
        module --silent load hdf5-mpi
        module --silent load gsl
    elif [[ "${HOSTNAME::-2}" = "snmgt" ]]; then
        module purge
        module --quiet load hwloc
        module --quiet load gnu
        module --quiet load openmpi4
        module --quiet load fftw
        module --quiet load hdf5/1.10.8
        module --quiet load gsl
        module --quiet load gmp
    else
        echo "I could not recognize the hostname: ${HOSTNAME::-2}"
        exit
    fi

    # Set the variable for system type variable, and the running command
    if [[ "${HOSTNAME::-2}" = "raven" ]]; then
        export SYSTYPE=RAVEN
        sed -i "s&mpiexec -np \"\${SLURM_NPROCS}\"&srun&" ./slurm_job.sh
    elif [[ "${HOSTNAME::-2}" = "freya" ]]; then
        export SYSTYPE=FREYA
        sed -i "s&srun&mpiexec -np \"\${SLURM_NPROCS}\"&" ./slurm_job.sh
    elif [[ "${HOSTNAME::-2}" = "viper" ]]; then
        export SYSTYPE=VIPER
        sed -i "s&mpiexec -np \"\${SLURM_NPROCS}\"&srun&" ./slurm_job.sh
    elif [[ "${HOSTNAME::-2}" = "snmgt" ]]; then
        export SYSTYPE=CLEMENTINA
        sed -i "s&srun&mpiexec -np \"\${SLURM_NPROCS}\"&" ./slurm_job.sh
    else
        echo "I could not recognize the hostname: ${HOSTNAME::-2}"
        exit
    fi

	# Compile the code
	make -j6 CONFIG=./Config.sh BUILD_DIR=../build EXEC=../build/Arepo

	# Send the job to the cluster
	if [[ $? -eq 0 ]]; then
		sbatch ./slurm_job.sh "$1"
	fi
}

main "$@"