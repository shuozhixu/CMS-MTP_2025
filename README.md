# Unstable stacking fault energies in refractory medium entropy alloys

## Foreword

The purpose of this project is to calculate the unstable stacking fault energies (USFE) of four equal-molar body-centered cubic (BCC) refractory medium element alloys (MEAs). The effect of chemical short-range order (CSRO) will be considered.

In [a previous project](https://github.com/shuozhixu/Modelling_2024), we calculated the USFEs in MoNbTa, HfMoNbTaTi, and HfNbTaTiZr, respectively; it was found that the CSRO lowers the USFE in MoNbTa but increases the USFEs in the other two alloys. In the meantime, [another work](https://doi.org/10.1038/s41524-023-01046-z) in MoNbTi and NbTaTi showed that the CSRO increases the USFEs, see [Supplementary Figure 10](https://static-content.springer.com/esm/art%3A10.1038%2Fs41524-023-01046-z/MediaObjects/41524_2023_1046_MOESM1_ESM.pdf). 

Through this project, we aim to answer the following question:

- How does CSRO affect USFEs across MEAs?

Here, we will investigate four MEAs, including MoNbTa, MoNbV, NbTaV, and NbVW. These MEAs were chosen for their stable BCC structures. The USFEs of the four MEAs have been calculated using their random structures, as

- MoNbTa
	- [DFT](https://doi.org/10.3390/modelling5010019): 1055 mJ/m<sup>2</sup>
	- MTP: 
- MoNbV
	- [DFT](https://doi.org/10.1063/5.0157728): 1046 mJ/m<sup>2</sup>
	- MTP: 
- NbTaV
	- [DFT](https://doi.org/10.1016/j.commatsci.2024.112886): 644 mJ/m<sup>2</sup>
	- MTP:
- NbVW
	- [DFT](https://doi.org/10.1063/5.0157728): 1008 mJ/m<sup>2</sup>
	- MTP:

[The MTP calculations are being performed by another student, who will have all data ready by April 20th]

Therefore, in this project, we will calculate the USFEs of these four MEAs in their CSRO structures.

## LAMMPS

LAMMPS on [Bridges-2](https://www.psc.edu/resources/bridges-2/user-guide/) likely does not come with many packages. To finish this project, the [MLIP](https://mlip.skoltech.ru) package is needed.

To install LAMMPS with MLIP, use the file `MLIP.sh` in the `MTP/` directory in this GitHub repository. First, cd to any directory on OSCER, e.g., \$HOME, then

	sh MLIP.sh

Note that the second command in `MLIP.sh` will load two modules. If you cannot load them, try `module purge` first.

Once the `sh` run is finished, you should find a file `lmp_intel_cpu_intelmpi` in the `lammps-mtp/interface-lammps-mlip-2/` directory. And that is the LAMMPS executable with MLIP.

## Ternaries

All four ternaries are equal-molar.

Cliff Hirt

- MoNbTa and MoNbV

Richard Brinlee

- NbVW and NbTaV

The file `lmp_psc.batch` can be used to submit a LAMMPS simulation. Remember to use the correct LAMMPS input file at the end of line 33.

### MoNbTa

#### Build the CSRO structure

The first step is to build the CSRO MoNbTa structure using a a hybrid molecular dynamics (MD) / Monte Carlo (MC) simulation. For that, we run a LAMMPS simulation using `data.random`, `lmp_MoNbTa.in`, `lmp_psc.batch`, `fitted.mtp`, and `mlip.ini`. All five files can be found in this GitHub repository. The first two files can be found in the `csro/` directory while the last two in the `MTP/` directory.

Once the simulation is finished, we will find a file `data.MoNbTa`, which will used later.

#### Calculate the lattice parameter

Run a LAMMPS simulation with files `lmp_0K.in`, `data.MoNbTa`, `lmp_sgc.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `lat_para/` directory in this GitHub repository.

Once the simulation is finished, we will find a new file `a_E`. Then run `sh min.sh`. We will see three numbers on the screen. The second number is the actual lattice parameter; let's call it $a_0$. The first number is the ratio of the actual lattice parameter to the trail lattice parameter; let's call it $r_0$.

#### Generalized stacking fault energy (GSFE)

##### Plane 1

The simulation requires files 
`lmp_gsfe.in`, `data.MoNbTa`, `lmp_sgc.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `gsfe/` directory in this GitHub repository.

Modify `lmp_gsfe.in`:

- line 36, replace the number `0.99` by $r_0$
- line 38, replace the number `3.3` by $a_0$

Then run the simulation. Once it is finished, we will find a new file `gsfe_ori`. Run

	sh gsfe_curve.sh

which would yield a new file `gsfe`. The first column is the displacement along the $\left<111\right>$ direction while the second column is the GSFE value, in units of mJ/m<sup>2</sup>. The USFE is the peak GSFE value.

##### Other planes

According to [this paper](http://dx.doi.org/10.1016/j.intermet.2020.106844), in an alloy, multiple GSFE curves should be calculated. Hence, we need to make one more change to `lmp_gsfe.in`:

- line 68, replace the number `1` by `2`

Then run the simulation and obtain another USFE value.

We can then replace that number by `3`, `4`, `5`, ..., `20`, respectively. It follows that we run 18 more simulations. Eventually, we obtain 20 USFE values in total. We then calculate the mean USFE value for MoNbTa.

### NbVW

Follow the same procedures, we can calculate the lattice parameter and mean USFE value in NbVW. The following changes should be made:

- To build the CSRO structure, we use `lmp_NbVW.in`; the simulation will generate a file `data.NbVW`
- In calculating the lattice parameter, we use the file `data.NbVW` and write the correct file name in line 22 of the file `lmp_0K.in`
- In calculating the GSFEs, we use the file `data.NbVW` and write the correct file name in line 28 of the file `lmp_gsfe.in`

### Other two ternaries

Follow the same procedures, we can calculate the lattice parameters and mean USFE values in the other two ternaries. Don't forget to modify the LAMMPS input files accordingly for each alloy.

## References

If you use any files from this GitHub repository, please cite

- Xiaowang Wang, Shuozhi Xu, Wu-Rong Jian, Xiang-Guo Li, Yanqing Su, Irene J. Beyerlein, [Generalized stacking fault energies and Peierls stresses in refractory body-centered cubic metals from machine learning-based interatomic potentials](http://dx.doi.org/10.1016/j.commatsci.2021.110364), Comput. Mater. Sci. 192 (2021) 110364
- Rebecca A. Romero, Shuozhi Xu, Wu-Rong Jian, Irene J. Beyerlein, C.V. Ramana, [Atomistic calculations of the local slip resistances in four refractory multi-principal element alloys](http://dx.doi.org/10.1016/j.ijplas.2021.103157), Int. J. Plast. 149 (2022) 103157
- Shuozhi Xu, Wu-Rong Jian, Irene J. Beyerlein, [Ideal simple shear strengths of two HfNbTaTi-based quinary refractory multi-principal element alloys](http://dx.doi.org/10.1063/5.0116898), APL Mater. 10 (2022) 111107