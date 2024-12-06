# Non-dilute random alloys: Moment tensor potential

## Foreword

In this repository, we will study the effect of the chemical short-range order (CSRO) on lattice parameter and unstable stacking fault energy (USFE) in four equal-molar body-centered cubic (BCC) refractory medium element alloys (MEAs): MoNbTa, MoNbV, NbVW, and NbTaV.

[Another GitHub repository](https://github.com/shuozhixu/CMS-EAM_2025) answered two questions while using the embedded-atom method potential. This repository aims to assess if those answers depend on the interatomic potential. Specifically, we will employ [a moment tensor potential (MTP)](https://github.com/ucsdlxg/MoNbTaVW-ML-interatomic-potential-and-CRSS-ML-model) developed by [Wang et al.](https://doi.org/10.1038/s41524-024-01330-6)

The peak value of a $\left<111\right>$ generalized stacking fault energy (GSFE) curve in a BCC crystal is the USFE. The lattice parameters and USFEs of the four MEAs have been calculated in their random structures, as

- MoNbTa
	- [DFT](https://doi.org/10.3390/modelling5010019): 3.26 &#8491;, 1055 mJ/m<sup>2</sup>
	- MTP: 3.2637 &#8491;, 1252.88 mJ/m<sup>2</sup>
- MoNbV
	- [DFT](https://doi.org/10.1063/5.0157728): 3.156 &#8491;, 1046 mJ/m<sup>2</sup>
	- MTP: 3.1693 &#8491;, 1207.54 mJ/m<sup>2</sup>
- NbTaV
	- DFT: [3.222 &#8491;](https://doi.org/10.1016/j.msea.2023.145841), [644 mJ/m<sup>2</sup>](https://doi.org/10.1016/j.commatsci.2024.112886)
	- MTP: 3.2307 &#8491;, 769.61 mJ/m<sup>2</sup>
- NbVW
	- [DFT](https://doi.org/10.1063/5.0157728): 3.164 &#8491;, 1008 mJ/m<sup>2</sup>
	- MTP: 3.1769 &#8491;, 1267.01 mJ/m<sup>2</sup> 

The MTP calculations were done in [another project](https://github.com/shuozhixu/USFE_2025).

Therefore, here, we will build CSRO structures for the four MEAs and calculate their USFEs using MTP.

## LAMMPS

LAMMPS on [Bridges-2](https://www.psc.edu/resources/bridges-2/user-guide/) likely does not come with many packages. To finish tasks in this repository, the [MLIP](https://mlip.skoltech.ru) package is needed.

To install LAMMPS with MLIP, use the file `MLIP.sh` in the `MTP/` directory in this GitHub repository. First, cd to any directory on Bridges-2, e.g., \$HOME, then

	sh MLIP.sh

Note that the second command in `MLIP.sh` will load four modules. If one cannot load them, try `module purge` first.

Once the `sh` run is finished, we will find a file `lmp_intel_cpu_intelmpi` in the `lammps-mtp/interface-lammps-mlip-2/` directory. And that is the LAMMPS executable with MLIP.

## MoNbTa

### Build the CSRO structure

Here, we build the CSRO MoNbTa structure using a hybrid molecular dynamics / Monte Carlo simulation using `data.random`, `lmp_MoNbTa.in`, `lmp_psc.batch`, `fitted.mtp`, and `mlip.ini`. All five files can be found in this GitHub repository. The first two files can be found in the `csro/` directory while the last two in the `MTP/` directory. The last two files were retrieved from [another GitHub repository](https://github.com/ucsdlxg/MoNbTaVW-ML-interatomic-potential-and-CRSS-ML-model). 

Once the simulation is finished, we will find a file `data.MoNbTa_CSRO`, which will be used later.

### Lattice parameter

The lattice parameter of MoNbTa can be calculated by

	(lx/(10*sqrt(6.))+ly/(46*sqrt(3.)/2.)+lz/(14*sqrt(2.)))/3.
	
where

	lx = xhi - xlo
	ly = yhi - ylo
	lz = zhi - zlo

where `lx`, `ly`, and `lz` can be found in the first few lines of the data file `data.MoNbTa_CSRO`.

Let's denote the lattice parameter as $a_0$.

### GSFE

#### Plane 1

The simulation requires files 
`lmp_gsfe.in`, `data.MoNbTa_CSRO`, `lmp_psc.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `gsfe/` directory in this GitHub repository.

Modify `lmp_gsfe.in`:

- line 24, replace the number `3.3` with $a_0$

Then run the simulation. Once it is finished, we will find a new file `gsfe_ori`. Run

	sh gsfe_curve.sh

which would yield a new file `gsfe`. The first column is the displacement along the $\left<111\right>$ direction while the second column is the GSFE value, in units of mJ/m<sup>2</sup>. The USFE is the peak GSFE value.

#### Other planes

According to [this paper](http://dx.doi.org/10.1016/j.intermet.2020.106844), in an alloy, multiple GSFE curves should be calculated. Hence, we need to make one more change to `lmp_gsfe.in`:

- line 54, replace the number `1` with `2`

Then run the simulation and obtain another USFE value.

We can then replace that number with `3`, `4`, `5`, ..., `20`, respectively. It follows that we run 18 more simulations. Eventually, we obtain 20 USFE values in total. We then calculate the mean USFE value for MoNbTa.

## NbVW

Follow the same procedures, we can calculate the lattice parameter and mean USFE value in NbVW. The following changes should be made:

- To build the CSRO structure, we use the input file `lmp_NbVW.in`; the simulation will generate a file `data.NbVW_CSRO`
- In calculating the lattice parameter, we use the data file `data.NbVW_CSRO`
- In calculating the GSFEs, we use the data file `data.NbVW_CSRO` and write the correct file name in line 16 of the file `lmp_gsfe.in`, whose line 24 should involve the lattice parameter of NbVW

## Other two ternaries

Follow the same procedures, we can calculate the lattice parameters and mean USFE values in the other two ternaries. Remember to modify files accordingly for each alloy.

## Results

Results based on CSRO structures are as follows

- MoNbTa
	- MTP: 3.263 &#8491;, 1328.71 mJ/m<sup>2</sup>
- MoNbV
	- MTP: 3.167 &#8491;, 1235.99 mJ/m<sup>2</sup>
- NbTaV
	- MTP: 3.225 &#8491;, 895.1036 mJ/m<sup>2</sup>
- NbVW
	- MTP: 3.172 &#8491;, 1294.256 mJ/m<sup>2</sup>

## Contributors

Main contributors are Cliff Hirt and Richard Brinlee, who ran simulations for the final project in Dr. Shuozhi Xu's [Computational Materials Science course in Spring 2024](https://shuozhixu.github.io/teaching/spring-2024/AME4970-5970-Syllabus.pdf) at the University of Oklahoma.

## Reference

If you use any files from this GitHub repository, please cite

- Subah Mubassira, Mahshad Fani, Anshu Raj, Cliff Hirt, Richard S. Brinlee, Amin Poozesh, Wu-Rong Jian, Saeed Zare Chavoshi, Chanho Lee, Shuozhi Xu, [Chemical short-range order and its influence on selected properties of non-dilute random alloys](https://doi.org/10.1016/j.commatsci.2024.113587), Comput. Mater. Sci. 248 (2025) 113587