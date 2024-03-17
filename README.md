# Unstable stacking fault energies in refractory random alloys

## Foreword

The purpose of this project is to calculate the unstable stacking fault energies (USFEs) of 10 ternaries and 990 binaries. All alloys have a body-centered cubic (BCC) lattice. For each alloy, we need to run 20 LAMMPS simulations. Therefore, in total 20,000 LAMMPS simulations are needed. Then we can try training a machine learning model to predict these energies from chemical compositions. It would also be interesting to check how the USFE gradually varies with the composition in each set of binaries.

The 10 ternaries are listed in Table 1 of [this paper](https://doi.org/10.1016/j.jallcom.2023.170556).

The 990 binaries include

- 99 binaries based on Mo<sub>_1-x_</sub>Nb<sub>_x_</sub>, where _x_ varies from 0.01 to 0.99
- other combinations of metals, including MoTa, MoV, MoW, NbTa, NbV, NbW, TaV, TaW, and VW

Please read the journal articles in the reference list to understand how the generalized stacking fault energy (GSFE) curves and their peak values (i.e., USFEs) can be calculated in BCC metals and alloys.

Note: Pay attention to the amount of data in your \$HOME. They can build up quickly. Once the data exceeds 20 GB, you won't be able to run anything. In addition, it may be wise to figure out how to run those high-throughput simulations automatically, e.g., using [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)), as opposed to manually making changes to the files.

Note: Our collaborators in this project will be [Dr. Xiang-Guo Li](https://scholar.google.com/citations?user=_lTAEWgAAAAJ&hl=en) and his student Tianyi Wang at the Sun Yat-sen University in China. They have graciously shared with us their unpublished ML-based interatomic potential and have calculated the USFEs in one quinary MoNbTaVW and five quaternaries: MoNbTaV, MoNbTaW, MoNbVW, MoTaVW, and NbTaVW. We can include their data when training our ML model.

## LAMMPS

LAMMPS on [OSCER](http://www.ou.edu/oscer.html) likely does not come with many packages. To finish this project, the [MLIP](https://mlip.skoltech.ru) package is needed.

To install LAMMPS with MLIP, use the file `MLIP.sh` in the `MTP/` directory in this GitHub repository. First, cd to any directory on OSCER, e.g., \$HOME, then

	sh MLIP.sh

Note that the second command in `MLIP.sh` will load a module. If you cannot load it, try `module purge` first.

Once the `sh` run is finished, you should find a file `lmp_intel_cpu_intelmpi` in the `lammps-mtp/interface-lammps-mlip-2/` directory. And that is the LAMMPS executable with MLIP.

In practice, with 4 CPU cores, each lattice parametr calculation and GSFE calculation takes about 15 mins and 1 min, respectively.

Each time we run a new type of simulation, create a new directory.

## Ternaries

All 10 ternaries are equal-molar.

### MoNbTa

#### Lattice parameter

Run a LAMMPS simulation with files `lmp_0K.in`, `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first two files can be found in the `ternary/lat_para/` directory in this GitHub repository. The other two files can be found in the `MTP/` directory in this GitHub repository. Submit the job by

	sbatch lmp.batch

Once it is finished, we will find a new file `a_E`. The first column is the ratio of the trial lattice parameter to 3.3, the second column is the trial lattice parameter itself, in units of Angstrom, the thrid column is the cohesive energy, in units of eV. If we plot a curve with the second column as the _x_ axis and the third column as the _y_ axis, the curve should look like the ones in Figure 1(a) of [this paper](http://dx.doi.org/10.1016/j.commatsci.2021.110942).

Then run `sh min.sh` to find out the trial lattice parameter corresponding to the lowest cohesive energy (i.e., the minimum on that curve), and that would be the actual lattice parameter. Specifically, we will see three numbers on the screen. The second number is the actual lattice parameter of MoNbTa. Let's call it $a_0$.

#### GSFE

##### Plane 1

The simulation requires files 
`lmp_gsfe.in`, `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first two files can be found in the `ternary/gsfe/` directory in this GitHub repository.

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

### Other eight ternaries

Follow the same procedures, we can calculate the lattice parameters and mean USFE values in other eight ternaries. Don't forget to modify the LAMMPS input files accordingly for each alloy.

## Binaries

The 990 binaries consist of 10 equal-molar alloys and 980 non-equal-molar alloys.

The files in the `binary/` directory in this GitHub repository are for Mo<sub>0.99</sub>Nb<sub>0.01</sub>, because of these two lines:

	create_atoms 2 box
	set type 2 type/ratio 4 0.99 134

For the next binary, Mo<sub>0.98</sub>Nb<sub>0.02</sub>, those two lines should be modified to

	create_atoms 2 box
	set type 2 type/ratio 4 0.98 134

Follow the same procedures, we can calculate the lattice parameters and mean USFE values in all other binaries. Don't forget to modify the LAMMPS input files accordingly for each alloy.

## References

If you use any files from this GitHub repository, please cite

- Xiaowang Wang, Shuozhi Xu, Wu-Rong Jian, Xiang-Guo Li, Yanqing Su, Irene J. Beyerlein, [Generalized stacking fault energies and Peierls stresses in refractory body-centered cubic metals from machine learning-based interatomic potentials](http://dx.doi.org/10.1016/j.commatsci.2021.110364), Comput. Mater. Sci. 192 (2021) 110364
- Rebecca A. Romero, Shuozhi Xu, Wu-Rong Jian, Irene J. Beyerlein, C.V. Ramana, [Atomistic calculations of the local slip resistances in four refractory multi-principal element alloys](http://dx.doi.org/10.1016/j.ijplas.2021.103157), Int. J. Plast. 149 (2022) 103157
- Shuozhi Xu, Wu-Rong Jian, Irene J. Beyerlein, [Ideal simple shear strengths of two HfNbTaTi-based quinary refractory multi-principal element alloys](http://dx.doi.org/10.1063/5.0116898), APL Mater. 10 (2022) 111107