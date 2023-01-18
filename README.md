# Initial conditions generator

## Folders

- GalIC_1.0: Version 1.0 of GalIC [Yurin et al. (2014)](https://doi.org/10.1093/mnras/stu1421), available to download [here](https://www.h-its.org/2014/11/05/galic-code/).
- GalIC_1.1: Version 1.1 of GalIC from [this repo](https://github.com/denisyurin/GALIC).
- conversion: Public version [Arepo](https://gitlab.mpcdf.mpg.de/vrs/arepo) configured to transform ICs files to the Arepo format, and to add gas particles.

## Procedure

- To generate the dark matter only ICs:

```bash
cd GalIC_1.0/code # or `cd GalIC_1.1/code` depending on which version you want
./send.sh N
cd ../..
```

where N is the number of particles in one dimension (i.e. `send 32` will produce $32^3$ dark matter particles).

- To convert the DM only ICs to the Arepo format, and to add gas cells:

```bash
cd conversion/code
./send.sh final_name
```

where `final_name` is the name of the resulting HDF5 file.

## Notes

- The final IC file will have $N^3$ dark matter particles, and $ > N^3$ gas cells (the extra ones are for the background, with a negligible density).

- After both runs the folders should've been cleaned of intermediate files, and in the `output` folder there should be three new files: the final IC file with gas cells and dark matter particles, the standard output from the conversion process, and the dark matter only IC file generated by GalIC.
