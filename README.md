# <div align="center"> WSIMIR (Whole Slide Imaging, Mutual Information Registration) </div>
#### <div align="center"> Perform multi-modality/multi-channel whole slide to whole slide pathology image registration</div>
#### <div align="center">Correspondence to: bgreen42@jhu.edu</div>

## 1. Description
This code was designed to automated whole slide registration for pathology images across multiple modalities with varying numbers of channels (e.g., IHC with three-channel RGB vs. mIF with *n* spectral channels). Unlike traditional approaches that rely on grayscale conversion or single-channel registration (e.g., DAPI in IF), this method employs self-information to automatically identify and select the most informative channels for registration. Next we leverage a multivariate solution for mutual information as the registration criterion using the identified channels.

Here, multiple modalities refer to both differences in microscopy techniques (e.g., brightfield vs. fluorescence) and staining methods (e.g., IHC/H&E vs. mIF). The approach is particularly well-suited for multi-modality slide-to-slide registration, where standard grayscale-based methods may be suboptimal due to the complexity of multi-channel data.

To handle gigapixel-scale whole-slide images, the algorithm is fully parallelized, efficiently distributing computational workloads across multiple cores. This enables the processing of high-resolution tissue images in a scalable and reasonably time-efficient manner without compromising pixel-level accuracy.

IDuring processing, one image remains fixed while the other is rotated and transformed to align with the fixed image’s coordinate space. We refer to these as the fixed image and moving image, respectively. In this version of the code, the fixed image must be a set of image tiles at 20x magnification, where the tiles are named using the format: `<slideid>_*[<XCoord>, <YCoord>]*.tif`, where `<slideid>`, `<XCoord>`, and `<YCoord>` are replaced with the repsective values.  We also assume that the moving image is an image pyramid where one of the layers is a 20x magnification image which is indicated in the image meta data 'ImageDescription' field. In principle our mutual information solution could be applied to all resolutions and images from any microscope, further development is ongoing in this space.

Please use the following citation when referencing this work:

<div align="center"> Doyle J*, Green BF*, Eminizer M, Jimenez-Sanchez D, Lu S, Engle EL, Xu H, Ogurtsova A, Lai J, Soto-Diaz S, Roskes JS, Deutsch JS, Taube JM, Sunshine JC*, Szalay AS*. Whole Slide Imaging, Mutual Information Registration (WSIMIR) For Multiplex Immunohistochemistry and Immunofluorescence. Lab Invest. 2023 May 15:100175. doi: 10.1016/j.labinv.2023.100175.</div> 
<div align="center">* These authors contributed equally to this work.</div> 

## 2. Instructions

Download \ checkout the repository. In MATLAB, add the folder to sourced directories. Use the command `wsimir` to start the code, inputs are defined below.
```
[fixed_image, moving_image, meta] = wsimir(fixed_image_path, moving_image_path, varagin)
```
- `fixed_image_path`: input file folder of image tiles
- `moving_image_path`: input file path of a whole slide image

The default output returns MATLAB structs: fixed_image, moving_image, and meta. The code also defaults to save tiles or hpfs of the `moving_image` regions corresponding to the `fixed_image` tile inputs in a *HPFs* folder in the same directory as the `moving_image_path`, tiles are labeled with the corresponding names to the `fixed_image` tiles. `<slideid>_*[<XCoord>, <YCoord>].tif`.
- `moving_image`: data structure used for processing the `moving_image`. Contains multiple fields depending on the input options will contain the moving image from different steps 
- `fixed_image`:  data structure used for processing the `fixed_image`. Contains multiple fields depending on the input options will contain the moving image from different steps 
- `meta`: data structure used for processing. contains `opts` the run options and input / output data from the original images (step 1), the rough regstration (step 2), the initial transformation (step 3), the high resolution transformation (step 4), and the tiling stage (step 5). The mutual information map for each step is stored in the output objects. *Steps 3 & 4 are the longest running steps and may take upwards of 10-20 minutes to complete depending on the size of the images, number of separate tissue islands, and compute resources available.*
 
The rest of the variable inputs should be added as comma separated pairs after the fixed and moving image inputs (ex. `wsimir(fixed_image_path, moving_image_path, 'test', true)`).
- `nbands`: The number of channels to use in the rough registration for the IF image. Defaults to `1` which will just use the first channel (typically `DAPI`). In most cases adding additional channels for this step does not typically improve the registration but does significantly impact run time. The downstream steps always use the 2 channels with the most self information from each image respectively.
- `numcores`: Number of cores and workers to use in the code (defaults to minimum of `16` or number of cores available to `MATLAB`).
- `[run_all, <run_step_1, run_step_2, run_step_3, run_step_4, run_step_5>]`: Set of logical switches to optionally run all or part of the registration pipeline. Setting `run_all` overrides other input, otherwise processing will be run up to the step designated (defaults to `true` which runs all steps). Step 1 just reads images and meta data, step 2 performs the intial rough registration, step 3 performs the intial affine transform, step 4 performs the final high resolution transformation, and step 5 writes out image tiles from the moving image for the corresponding fixed image tiles.
- `[output_dir, <output_filename_step_2, output_filename_step_3, output_filename_step_4>]`: Single file outputs are stored in the `output_dir` under a "wsimir_registration_data" folder with the corresponding filename and the tiled images under a separate "HPFs" folder. (`output_dir` defaults to the `moving_image_path` and the filenames default to the following respectively: `step_2_rotated_moving_image.tif`, `step_3_initial_transformed_moving_image.tif`, `step_4_registered_moving_image.tif`).
- `[save_overlay_all, <save_overlay_step_1, save_overlay_step_2, save_overlay_step_3, save_overlay_step_4, save_overlay_step_5>]`:  Set of logical switches to optionally output overlaid figures for QC at various stages, uses the `output_filename` arguments, removing "_moving" and appending "_overlay" to the name. By default `save_overlay_all` is set to `true`.
- `[write_all, <write_step_1, write_step_2, write_step_3, write_step_4, write_step_5>]`:  Set of logical switches to optionally output at various stages. Step 5 will also write out a "registration_parameters.csv" to the "wsimir_registration_data" folder (see `output_dir` option). By default only *step 5* is set to `true` which writes out the tiles rather than the full image.
- `[show_all, <show_step_1, show_step_2, show_step_3, show_step_4, show_step_5>]`: Set of logical switches to optionally show figures for all or part of the registration pipeline. Setting `show_all` overrides other input (defaults to `false` which shows nothing).
- `[keep_all, <keep_step_1, keep_step_2, keep_step_3, keep_step_4, keep_step_5>]`: Set of logical switches to optionally keep images at various stages of processing which will then be stored in the respective output data structures. To reduce overhead nothing is kept by default (defaults to `false`). The `keep_all` arguments overide downstream arguments.
- `log_level`: Level at which logs will be shown, levels options in their priority order are the following; `DEBUG`, `INFO`, [`START` OR `FINISH`], `WARN`, `ERROR` (defaults to `INFO`).
- `log_no_start_stop`: Do not write start and finish log messages regardless of `log_level`.
- `format_log`: Whether or not to add log formatting when displaying message or just print them as is (fprintf is used for the logging so that the output messages can be capture in stdout when running matlab from the command line).
- `test`: test flag returns after initializing step 1, is overridden by `run_step_*` options below (defaults to `false`).
