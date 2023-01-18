#!/usr/bin/env bash

#SBATCH --job-name=Conversion
#SBATCH --output=../output/stdout_%j
#SBATCH --error=../output/stderr_%j
#SBATCH --mail-user=lozano.ez@gmail.com
#SBATCH --mail-type=ALL,TIME_LIMIT_90
#SBATCH --time=01:00:00
#SBATCH --no-requeue

# Number of MPI tasks per node
#SBATCH --ntasks=1

# Memory per node
#SBATCH --mem=90G

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

main() {
	mpiexec -np "${SLURM_NPROCS}" ../build/Arepo param.txt

	# Move output files to the correct folder and clean everything else
	if [[ $? -eq 0 ]]; then

		if [[ $# -eq 0 ]]; then
			mv -f ../ICs/dm_ic-with-grid.hdf5 ../../output/ic.hdf5
			mv -f ../ICs/dm_ic.hdf5 ../../output/ic_dm.hdf5
			mv -f ../ICs/dm_ic_stdout.txt ../../output/dm_ic_stdout.txt
			mv -f ../output/stdout_* ../../output/ic_stdout.txt
		else
			mv -f ../ICs/dm_ic-with-grid.hdf5 ../../output/"${1}".hdf5
			mv -f ../ICs/dm_ic.hdf5 ../../output/"${1}"_dm.hdf5
			mv -f ../ICs/dm_ic_stdout.txt ../../output/"${1}"_dm_stdout.txt
			mv -f ../output/stdout_* ../../output/"${1}"_stdout.txt
		fi

		rm -rf ./param.txt-usedvalues ./WARNINGS ./uses-machines.txt ../ICs ../output ../build
		
	fi
}

main "$@"
