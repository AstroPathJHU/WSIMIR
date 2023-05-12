# <div align="center"> WSIMIR (Whole Slide Mutal Information Registration) </div>
#### <div align="center"> Perform multi-modality whole slide to whole slide pathology image registration</div>
#### <div align="center">Correspondence to: bgreen42@jhu.edu</div>

## 1. Description
This code was designed based on a method to automated pathology whole slide registration from multiple modalities using a multivariate solution to mutual information as the registration criterion. Here multiple modalities refers to both microscope and stain techniques used. Typically when slide regstration is performed the images are either first converted to greyscale or a single image channel (typically DAPI in IF) is used for registration.  This method is an intriguing option for slide to slide registration specifically in the field of immunofluorescence where slides have multiple channels and a one to one greyscale registration may not provide the best registration result. Furthermore, we use self-information of the images to select the optimal channels for slide registration. 

In the processing, one of the images remains fixed and the other is rotated and transformed to the fixed image coordinates, we call these images fixed and moving images respectively. In this version of the code the fixed image must be a set of image tiles at 20x magnification where the tiles are named `<slideid>_*[<XCoord>, <YCoord>]*.tif`, replacing the `<slideid>`, `<XCoord>`, and `<YCoord>` with the repsective values.  We also assume that the moving image is an image pyramid where one of the layers is a 20x magnification image which is indicated in the image meta data 'ImageDescription' field. In theory our mutual information solution could be applied to all resolutions and images from any microscope, further development is ongoing in this space.

## 2. Instructions

Download \ checkout the repository. In MATLAB, add the folder to sourced directories. Use the command `wsimir` to start the code. `wsimir` inputs are added below.
```
[moving_image, fixed_image, meta] = wsimir(fixed_image_path, moving_image_path, varagin)
```
- `fixed_image_path`: input file folder of image tiles
- `moving_image_path`: input file path of a whole slide image

The default output returns MATLAB structs: moving_image, fixed_image, and meta. The code also defaults to save tiles or hpfs of the `moving_image` regions corresponding to the `fixed_image` tile inputs in a *HPFs* folder in the same directory as the `moving_image_path`, tiles are labeled with the corresponding names to the `fixed_image` tiles. `<slideid>_*[<XCoord>, <YCoord>].tif`.
- `moving_image`: data structure used for processing the `moving_image`. Contains multiple fields depending on the input options will contain the moving image from different steps 
- `fixed_image`:  data structure used for processing the `fixed_image`. Contains multiple fields depending on the input options will contain the moving image from different steps 
- `meta`: data structure used for processing. contains `opts` the run options and input / output data from the rough regstration (step 2), the initial transformation (step 3), and the affine transformation (step 4). The mutual information map for each step is stored in the output objects.
 
The rest of the variable inputs should be added as comma separated pairs after the fixed and moving image inputs (ex. wsimir(fixed_image_path, moving_image_path, 'test', 1)). Most options are typically only used during testing. 
- `nbands`: the number of channels to use in the rough registration
  - DEFAULT: 1 
- `numcores`: number of cores and workers to use in the code
  - DEFAULT: 16 
- `test`: test flag returns after initializing step 1, is overridden by `run_step_*` options below
  - DEFAULT: FALSE 
- `run_all`: Run all steps of the processing pipeline
  - DEFAULT: TRUE 
- `run_step_1`: Run step 1 of the processing which just reads the images in and gathers the image meta data
  - DEFAULT: TRUE 
- `run_step_2`: Run up to step 2 of the processing which performs the initial rough registration and rotation of the moving image
  - DEFAULT: TRUE 
- `run_step_3`: Run up to step 3 of the processing which performs the initial transformation of the moving image
  - DEFAULT: TRUE 
- `run_step_4`: Run up to step 4 of the processing which performs the final affine transformation of the moving image
  - DEFAULT: TRUE 
- `keep_moving_original`: keep the original moving image stored in the `moving_image` ouput data struct
  - DEFAULT: FALSE 
- `keep_moving_rotated`: keep the rotated moving image after the rough registration from step 2 stored in the `moving_image` ouput data struct
  - DEFAULT: FALSE 
- `keep_moving_initial_transformed`: keep the initial transformed moving image from step 3 stored in the `moving_image` ouput data struct
  - DEFAULT: FALSE 
- `keep_moving_affine_transformed`: keep the affine transformed moving image from step 4 stored in the `moving_image` ouput data struct
  - DEFAULT: FALSE 
- `keep_all_moving`: keep all moving image steps in the `moving_image` ouput data struct
  - DEFAULT: FALSE 
- `keep_all_fixed`: keep all fixed image steps in the `fixed_image` ouput data struct
  - DEFAULT: FALSE 
- `keep_all`: keep all moving and fixed image steps in the respective ouput data structs
  - DEFAULT: FALSE 
- `output_dir`: the output directory for any images written out, the *HPFs* folder for tiles will be added one directory higher
  - DEFAULT:  `moving_image_path\wsimir_registration'
- `write_moving_image_tiles`: write out the moving image tiles that correspond to the fixed image tiles
  - DEFAULT: TRUE 
- `write_registered_moving_image_wsi`: write out the final affine transformed image 
  - DEFAULT: FALSE 
- `write_step2_rotated_moving_image_wsi`: write out the rotated moving image from step 2
  - DEFAULT: FALSE 
- `write_step3_initial_transformed_moving_image_wsi`: write out the initial transformed image from step 3
  - DEFAULT: FALSE 
- `step2_out_filename`: name to use when writing out the rotated moving image from step 2
  - DEFAULT: 'step2_rotated_moving_image_wsi.tif'
- `step3_out_filename`: name to use when writing out the initial moving image from step 3
  - DEFAULT: 'step3_initial_transformed_moving_image_wsi.tif'
- `registered_moving_image_wsi`:  name to use when writing out the whole slide final registered image
  - DEFAULT: 'registered_moving_image_wsi.tif'
