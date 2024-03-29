<div align="center">
    <h1>🏭 Galactic ICs generator</h1>
</div>

Scripts to generate isolated disk galaxy ICs for simulations using [Arepo](https://arepo-code.org/).

## Folders

- GalIC_1.0 (recommended): Version 1.0 of GalIC [Yurin et al. (2014)](https://doi.org/10.1093/mnras/stu1421), available to download [here](https://www.h-its.org/2014/11/05/galic-code/).
- GalIC_1.1: Version 1.1 of GalIC from [this repo](https://github.com/denisyurin/GALIC).
- conversion: Public version of [AREPO](https://gitlab.mpcdf.mpg.de/vrs/arepo) configured to transform ICs files to the Arepo format, and to add gas cells.

## Procedure

- To generate the dark matter (DM) only ICs, do:

```bash
cd GalIC_1.0/code # or `cd GalIC_1.1/code` depending on which version you want
./run.sh N
cd ../..
```

where N is the number of particles in one dimension (i.e. `send 32` will produce $32^3$ DM particles).

- To convert the DM only ICs to the AREPO format, and to add gas cells, do:

```bash
cd conversion/code
./run.sh out_filename
```

where `out_filename` is the name of the resulting HDF5 file.

## Notes

- The final IC file will have $N^3$ DM particles and $> N^3$ gas cells (the extra ones are the background cells with negligible density).

- After both runs all intermediate files should've been removed, and the `output` folder should have three new files: 

  - The final IC file with gas cells and DM particles.
  - The standard output from the conversion process.
  - The DM only IC file generated by GalIC.
