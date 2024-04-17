# Refractory medium entropy alloys: Moment tensor potential

## Foreword

In this project, we will build the chemical short-range order (CSRO) structures of four equal-molar body-centered cubic (BCC) refractory medium element alloys (MEAs): MoNbTa, MoNbV, NbVW, and NbTaV.

[Another project](https://github.com/shuozhixu/CMS_2025) discussed two ways by which CSRO structures can be built. In this project, we will use the second method. We aim to answer the following question:

- How does the CSRO affect GSFEs across MEAs?

The peak value of a $\left<111\right>$ GSFE curve in a BCC crystal is the unstable stacking fault energy (USFE). The USFEs of the four MEAs have been calculated in their random structures, as

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

[The MTP calculations are being performed by [another student](https://github.com/shuozhixu/USFE_2025), who will have all data ready by April 20th]

Therefore, in this project, we will calculate the USFEs of the four MEAs in their CSRO structures using MTP.

## LAMMPS

LAMMPS on [Bridges-2](https://www.psc.edu/resources/bridges-2/user-guide/) likely does not come with many packages. To finish this project, the [MLIP](https://mlip.skoltech.ru) package is needed.

To install LAMMPS with MLIP, use the file `MLIP.sh` in the `MTP/` directory in this GitHub repository. First, cd to any directory on Bridges-2, e.g., \$HOME, then

	sh MLIP.sh

Note that the second command in `MLIP.sh` will load four modules. If one cannot load them, try `module purge` first.

Once the `sh` run is finished, we will find a file `lmp_intel_cpu_intelmpi` in the `lammps-mtp/interface-lammps-mlip-2/` directory. And that is the LAMMPS executable with MLIP.

## Simulations

Cliff Hirt

- MoNbTa and MoNbV

Richard Brinlee

- NbVW and NbTaV

The file `lmp_psc.batch` can be used to submit a LAMMPS simulation. Remember to use the correct LAMMPS input file at the end of line 33.

### MoNbTa

#### Build the CSRO structure

Here, we build the CSRO MoNbTa structure using a hybrid molecular dynamics / Monte Carlo simulation using `data.random`, `lmp_MoNbTa.in`, `lmp_psc.batch`, `fitted.mtp`, and `mlip.ini`. All five files can be found in this GitHub repository. The last two files were retrieved from [another GitHub repository](https://github.com/ucsdlxg/MoNbTaVW-ML-interatomic-potential-and-CRSS-ML-model). The first two files can be found in the `csro_second/` directory while the last two in the `MTP/` directory.

Once the simulation is finished, we will find a file `data.MoNbTa_CSRO`, which will be used later.

#### Lattice parameter

The lattice parameter of MoNbTa can be calculated by

	(lx/(10*sqrt(6.))+ly/(46*sqrt(3.)/2.)+lz/(14*sqrt(2.)))/3.
	
where

	lx = xhi - xlo
	ly = yhi - ylo
	lz = zhi - zlo

where `lx`, `ly`, and `lz` can be found in the first few lines of the data file `data.MoNbTa_CSRO`.

Let's denote the lattice parameter as $a_0$.

#### Generalized stacking fault energy (GSFE)

##### Plane 1

The simulation requires files 
`lmp_gsfe.in`, `data.MoNbTa_CSRO`, `lmp_sgc.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `gsfe/` directory in this GitHub repository.

Modify `lmp_gsfe.in`:

- line 24, replace the number `3.3` with $a_0$

Then run the simulation. Once it is finished, we will find a new file `gsfe_ori`. Run

	sh gsfe_curve.sh

which would yield a new file `gsfe`. The first column is the displacement along the $\left<111\right>$ direction while the second column is the GSFE value, in units of mJ/m<sup>2</sup>. The USFE is the peak GSFE value.

##### Other planes

According to [this paper](http://dx.doi.org/10.1016/j.intermet.2020.106844), in an alloy, multiple GSFE curves should be calculated. Hence, we need to make one more change to `lmp_gsfe.in`:

- line 54, replace the number `1` with `2`

Then run the simulation and obtain another USFE value.

We can then replace that number with `3`, `4`, `5`, ..., `20`, respectively. It follows that we run 18 more simulations. Eventually, we obtain 20 USFE values in total. We then calculate the mean USFE value for MoNbTa.

### NbVW

Follow the same procedures, we can calculate the lattice parameter and mean USFE value in NbVW. The following changes should be made:

- To build the CSRO structure, we use the input file `lmp_NbVW.in`; the simulation will generate a file `data.NbVW_CSRO`
- In calculating the lattice parameter, we use the data file `data.NbVW_CSRO`
- In calculating the GSFEs, we use the data file `data.NbVW_CSRO` and write the correct file name in line 16 of the file `lmp_gsfe.in`, whose line 24 should involve the lattice parameter of NbVW

### Other two ternaries

Follow the same procedures, we can calculate the lattice parameters and mean USFE values in the other two ternaries. Remember to modify files accordingly for each alloy.

## Submission

Once all simulations are finished, for the two MEAs assigned to you, please upload the following to Canvas by mid-night April 25:

- The lattice parameters of the two MEAs
- Files `data.MoNbTa_CSRO`, `data.MoNbV_CSRO`, `data.NbTaV_CSRO`, and/or `data.NbVW_CSRO`
- All 20 `gsfe` files for each of the two MEAs
- The mean USFEs of the two MEAs
- Slides used in your in-class presentation

## References

If you use any files from this GitHub repository, please cite

- Shuozhi Xu, Wu-Rong Jian, Irene J. Beyerlein, [Ideal simple shear strengths of two HfNbTaTi-based quinary refractory multi-principal element alloys](http://dx.doi.org/10.1063/5.0116898), APL Mater. 10 (2022) 111107