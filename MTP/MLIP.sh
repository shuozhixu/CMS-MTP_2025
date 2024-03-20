#!/usr/bin/bash

rm -rf lammps-mtp
module load intelmpi/2021.3.0-intel2021.3.0
module load gcc/10.2.0 python/3.8.6 cuda/11.7.1
mkdir lammps-mtp
cd lammps-mtp
git clone https://gitlab.com/ashapeev/mlip-2.git
cd mlip-2
./configure
make mlp
make libinterface
cd ..
mkdir interface-lammps-mlip-2
cd interface-lammps-mlip-2
git clone https://gitlab.com/ashapeev/interface-lammps-mlip-2.git .
cp ../mlip-2/lib/lib_mlip_interface.a .
cd ..
wget --no-check-certificate https://download.lammps.org/tars/lammps-22Dec2022.tar.gz
tar -xf lammps-22Dec2022.tar.gz
cd lammps-22Dec2022/src
make yes-manybody
make yes-extra-compute
make yes-mc
make yes-misc
cd ../../interface-lammps-mlip-2
./install.sh ../lammps-22Dec2022 intel_cpu_intelmpi
