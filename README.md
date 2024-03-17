# Unstable stacking fault energies in refractory medium entropy alloys

## Foreword

The purpose of this project is to calculate the unstable stacking fault energies (USFE) of four equal-molar body-centered cubic (BCC) refractory medium element alloys (MEAs). The effect of chemical short-range order (CSRO) will be considered.

In [a previous project](https://github.com/shuozhixu/Modelling_2024), we calculated the USFEs in MoNbTa, HfMoNbTaTi, and HfNbTaTiZr, respectively; it was found that the CSRO lowers the USFE in MoNbTa but increases the USFEs in the other two alloys. In the meantime, [another work](https://doi.org/10.1038/s41524-023-01046-z) in MoNbTi and NbTaTi showed that the CSRO increases the USFEs, see [Supplementary Figure 10](https://static-content.springer.com/esm/art%3A10.1038%2Fs41524-023-01046-z/MediaObjects/41524_2023_1046_MOESM1_ESM.pdf). 

Through this project, we aim to answer the following two questions:

- How does CSRO affect USFEs across MEAs?
- In each MEA, are the two chemical potential differences unique?

Here, we will investigate four MEAs, including MoNbTa, MoNbV, NbTaV, and NbVW. These MEAs were chosen for their stable BCC structures. The USFEs of the four MEAs have been calculated using their random structures, as

- MoNbTa
	- [DFT](https://doi.org/10.3390/modelling5010019): 1055 mJ/m<sup>2</sup>
	- MTP: 
- [MoNbV](https://doi.org/10.1063/5.0157728): 1046 mJ/m<sup>2</sup>
- [NbTaV](https://doi.org/10.1016/j.commatsci.2024.112886): 644 mJ/m<sup>2</sup>
- [NbVW](https://doi.org/10.1063/5.0157728): 1008 mJ/m<sup>2</sup>

Therefore, in this project, we will calculate the USFEs of these four MEAs in their CSRO structures.

Note: it may be wise to figure out how to run those high-throughput simulations automatically, e.g., using [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)), as opposed to manually making changes to the files.

## LAMMPS

LAMMPS on [Bridges-2](https://www.psc.edu/resources/bridges-2/user-guide/) likely does not come with many packages. To finish this project, the [MLIP](https://mlip.skoltech.ru) package is needed.

To install LAMMPS with MLIP, use the file `MLIP.sh` in the `MTP/` directory in this GitHub repository. First, cd to any directory on OSCER, e.g., \$HOME, then

	sh MLIP.sh

Note that the second command in `MLIP.sh` will load two modules. If you cannot load them, try `module purge` first.

Once the `sh` run is finished, you should find a file `lmp_intel_cpu_intelmpi` in the `lammps-mtp/interface-lammps-mlip-2/` directory. And that is the LAMMPS executable with MLIP.

In practice, with 4 CPU cores, each lattice parametr calculation and GSFE calculation takes about 15 mins and 1 min, respectively.

## Ternaries

All four ternaries are equal-molar.

Richard Brinlee

- MoNbTa and MoNbV

Cliff Hirt

- NbVW and NbTaV

### MoNbTa

#### Build the CSRO structure

##### Semi-grand canonical ensemble

The first step is to determine the chemical potential difference between Mo and Nb, and that between Mo and Ta, respectively. To this end, run a hybrid molecular dynamics (MD) / Monte Carlo (MC) simulation in a semi-grand canonical (SGC) ensemble using `lmp_sgc.in`, `lmp_psc.batch`, `fitted.mtp`, and `mlip.ini`. All four files can be found in this GitHub repository. The first file can be found in the `csro/` directory while the last two files in the `MTP/` directory.

Once the simulation is finished, we will find a file `statistics.dat`, which should contain one line similar to

	-0.021 0.32 0 0.0005  0.9995

The first two numbers are the two chemical potential differences we provided in lines 10 and 11 of `lmp_sgc.in`, while the last three numbers are the concentrations of Mo, Nb, and Ta, respectively. Since they are not close to equal-molar, modify the two numbers in lines 10 and 11 of `lmp_sgc.in`, and run the simulation again. We can make the modification in the same folder and a new line will be appended to `statistics.dat` once the new simulation is finished. Therefore, no need to delete the file `statistics.dat` each time we submit a new job. Iteratively adjust the two numbers until the material is almost equal-molar, meaning that the three concentrations should be between 3.18 and 3.48 simultaneously. The procedure is similar to what is described in Section B.2 of [this paper](https://doi.org/10.1016/j.actamat.2019.12.031).

Note: either chemical potential difference should not have a too small absolute value; otherwise the next step will not work properly. 

##### Variance constrained semi-grand canonical ensemble

Once the two chemical potential differences are identified, change the two chemical potential differences in lines 10 and 11 in file `lmp_vcsgc.in` to the correct values. Then run the atomsk script, `atomsk_Mo.sh` to build a Mo structure named `data.Mo`.

Next, make two changes to `data.Mo`:

- Line 4. Change the first number `1` to `3`
- Line 12 contains the atomic atomic mass (also known as atomic weight) of Nb. Add two lines after it, i.e.,

		Masses
		
		1   95.96000000    # Mo
		2   92.90638000    # Nb
		3   180.94788000   # Ta
		
		Atoms # atomic

Use [this page](https://en.wikipedia.org/wiki/List_of_chemical_elements) to find out the atomic mass of an element.

Next, run a hybrid MD/MC simulation in variance constrained semi-grand canonical (VC-SGC) ensemble using `lmp_vcsgc.in`, `data.Mo`, `fitted.mtp`, and `mlip.ini`.

Once the simulation is finished, we will find a file `data.MoNbTa_CSRO`, which is the CSRO structure annealed at 300 K, and a file `cn.out`.

#### Lattice parameter

Run a LAMMPS simulation with files `lmp_0K.in`, `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `lat_para/` directory in this GitHub repository. Submit the job by

	sbatch lmp.batch

Once it is finished, we will find a new file `a_E`. Then run `sh min.sh` to find out the trial lattice parameter corresponding to the lowest cohesive energy (i.e., the minimum on that curve), and that would be the actual lattice parameter. Specifically, we will see three numbers on the screen. The second number is the actual lattice parameter of MoNbTa. Let's call it $a_0$.

#### Generalized stacking fault energy (GSFE)

##### Plane 1

The simulation requires files 
`lmp_gsfe.in`, `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `ternary/gsfe/` directory in this GitHub repository.

Modify `lmp_gsfe.in`:

- line 16, replace the number `3.3` by $a_0$

Then run the simulation. Once it is finished, we will find a new file `gsfe_ori`. Run

	sh gsfe_curve.sh

which would yield a new file `gsfe`. The first column is the displacement along the $\left<111\right>$ direction while the second column is the GSFE value, in units of mJ/m<sup>2</sup>. The USFE is the peak GSFE value.

##### Other planes

According to [this paper](http://dx.doi.org/10.1016/j.intermet.2020.106844), in an alloy, multiple GSFE curves should be calculated. Hence, we need to make three changes to `lmp_gsfe.in`:

- line 16, replace the number `3.3` by $a_0$
- line 37, change the number `134` to any other integer
- line 38, change the number `384` to any other integer

Then run the simulation and obtain another USFE value.

Modifying the two integers in `lmp_gsfe.in` again and we will have another USFE. Repeat the step many times until we have 20 USFE values. Then calculate the mean USFE value.

### MoNbV

The MTP files used here specify the five elements for each type:

	type 1: Ta
	type 2: Nb
	type 3: V
	type 4: Mo
	type 5: W

In `lmp_0K.in` and `lmp_gsfe.in` for MoNbTa, there are three lines:

	create_atoms 1 box
	set type 1 type/ratio 2 0.3333 134
	set type 1 type/ratio 4 0.5 384

The first line fill the box with all Ta atoms. The second line randomly changes 1/3 of Ta atoms (type 1) to Nb atoms (type 2). The third line randomly changes 1/2 of remaining Ta atoms (type 1) to Mo atoms (type 4). As a result, the three elements are equal-molar.

Therefore, to study MoNbV, in BOTH input files, we need to modify those three lines to

	create_atoms 2 box
	set type 2 type/ratio 3 0.3333 134
	set type 2 type/ratio 4 0.5 384

Alternatively, we can change them to

	create_atoms 3 box
	set type 3 type/ratio 2 0.3333 134
	set type 3 type/ratio 4 0.5 384

or

	create_atoms 4 box
	set type 4 type/ratio 2 0.3333 134
	set type 4 type/ratio 3 0.5 384

Then follow the same procedures for MoNbTa to calculate the lattice parameter and mean USFE value for MoNbV.

### Other two ternaries

Follow the same procedures, we can calculate the lattice parameters and mean USFE values in other eight ternaries. Don't forget to modify the LAMMPS input files accordingly for each alloy.

## References

If you use any files from this GitHub repository, please cite

- Xiaowang Wang, Shuozhi Xu, Wu-Rong Jian, Xiang-Guo Li, Yanqing Su, Irene J. Beyerlein, [Generalized stacking fault energies and Peierls stresses in refractory body-centered cubic metals from machine learning-based interatomic potentials](http://dx.doi.org/10.1016/j.commatsci.2021.110364), Comput. Mater. Sci. 192 (2021) 110364
- Rebecca A. Romero, Shuozhi Xu, Wu-Rong Jian, Irene J. Beyerlein, C.V. Ramana, [Atomistic calculations of the local slip resistances in four refractory multi-principal element alloys](http://dx.doi.org/10.1016/j.ijplas.2021.103157), Int. J. Plast. 149 (2022) 103157
- Shuozhi Xu, Wu-Rong Jian, Irene J. Beyerlein, [Ideal simple shear strengths of two HfNbTaTi-based quinary refractory multi-principal element alloys](http://dx.doi.org/10.1063/5.0116898), APL Mater. 10 (2022) 111107