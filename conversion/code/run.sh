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

	# Compile the code
	make -j8 CONFIG=./Config.sh BUILD_DIR=../build EXEC=../build/Arepo

	# Send the job to the cluster
	if [[ $? -eq 0 ]]; then
		sbatch ./slurm_job.sh "$1"
	fi
}

main "$@"