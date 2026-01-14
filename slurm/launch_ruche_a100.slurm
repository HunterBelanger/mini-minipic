#!/bin/bash
#SBATCH --job-name=mini-minipic
#SBATCH --output ruche_a100.%J.out
#SBATCH --error  ruche_a100.%J.err
#SBATCH --nodes=1
#SBATCH --time=00:15:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
##SBATCH -p gpu_test
##SBATCH -p gpu
#SBATCH -p gpua100
#SBATCH --gres=gpu:1
#SBATCH --reservation prouveurc_178

set -e

# Modules

module purge
module load "gcc/13.2.0/gcc-4.8.5"
module load "cuda/12.8.0/gcc-13.2.0"
module load "cmake/3.28.3/gcc-11.2.0"
module load "python-nospack/3.12.4/gcc-11.2.0"

# Python env

if [[ -d ./venv ]]
then
    source ./venv/bin/activate
fi

# Launch the test
# Maybe remove thermal or --save-timers one day ?
#export KOKKOS_TOOLS_LIBS=$HOME/builds/build/kokkos-tools/profiling/simple-kernel-timer/libkp_kernel_timer.so
#export KOKKOS_TOOLS_LIBS=$HOME/builds/build/kokkos-tools/profiling/memory-events/libkp_memory_events.so
opts="--parallel 16 --save-timers "
opts="--parallel 16"
mini-run --prefix "nsys profile" $opts --build-dir gpu-a100 -g gpu-a100 -s thermal,antenna,beam
