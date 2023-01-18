#!/usr/bin/env bash

#SBATCH --job-name=GalIC_1.0
#SBATCH --output=../output/stdout_%j    
#SBATCH --error=../output/stderr_%j    
#SBATCH --mail-user=lozano.ez@gmail.com
#SBATCH --mail-type=ALL,TIME_LIMIT_90
#SBATCH --time=12:00:00
#SBATCH --no-requeue

# Total number of threads = nodes * ntasks-per-node

# Number of nodes
#SBATCH --nodes=2

# Number of MPI tasks per node
#SBATCH --ntasks-per-node=40

# Memory per node
#SBATCH --mem=180G

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

main() {
	mpiexec -np "${SLURM_NPROCS}" ../build/GalIC param.txt

	# Move the output file to the correct folder and clean everything else
	if [[ $? -eq 0 ]]; then
		mv -f ../output/dm_ic_010.hdf5 ../../conversion/ICs/dm_ic.hdf5
		mv -f ../output/stdout_* ../../conversion/ICs/dm_ic_stdout.txt
		rm -rf ./param.txt-usedvalues ./WARNINGS ./uses-machines.txt  ./forcetest.dat ../output ../build	
	fi
}

main "$@"
