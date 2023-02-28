# Dymecki-neurons
Pipelines and files for segmentation of Tph2 neurons in mouse brain tissue sections


## Steps to reproduce this analysis: 

### Ready images with Fiji
1. Put all .nd2 images (or any image type openable with Fiji) in a folder. This analysis assumes each image has two channels: 1) DAPI (nuclei) and 2) Tph2 (cells)
2. Drag and drop Step1_SplitChannels.ijm into Fiji
3. Select "Run" in the script window to run the script. Select a folder to save your images in. This will split each nd2 into separate channels and save them out with names ending in "C1", "C2", etc. 
   - :label: Note that this is not strictly necessary. You can configure CellProfiler to work directly with nd2 images, but since CellProfiler can sometimes be slow or have issues extracting metadata from image file headers, this way is recommended.

### Analyze images with CellProfiler
4. Install CellProfiler from source. This is currently necessary to run cellpose inside CellProfiler
5. Open CellProfiler and load the pipeline "20221017_Batch3_assaydev_newmodel_withProcessesShort.cppipe"
6. Drag your images into the Images module
7. Go to the runCellpose module and make sure the Location of the pre-trained model is set to the location of "CP_tph2_nuc_405"
8. Make sure the "Output Settings" are set to save to the folder you want to save results in
9. Run the pipeline. This will take some time depending on the number of images. Running on a computer with a GPU is recommended. 

### Expected output
10. Examine the output: 
    - :file_cabinet: **DefaultDB.db** - a database file containing all measurements
    - :1234: **Labels_cells** - a folder containing label matrices for all images for all cells
    - :1234: **Labels_cells_with_nuclei** - a folder containing label matrices for all images for all cells that have nuclei
    - :1234: **Labels_nuclei** - a folder containing label matrices for all images for all nuclei 
    - :framed_picture: **Outlines_cells** - a folder containing original Tph2 images with outlines for cells (cyan) and nuclei (yellow)
    - :framed_picture: **Outlines_cells_with_nuclei** - folder containing original Tph2 images with outlines for cells that have nuclei (pink) and nuclei (yellow)
    - :framed_picture: **Outlines_cells_with_processes** - folder containing original Tph2 images with outlines for cells (cyan), their processes (magenta) and nuclei (yellow)
    
### Data analysis 
11. Process the output. Open the data base file with [DB Browser](https://sqlitebrowser.org/dl/) or another program that can open sqlite files. 
12. Select File > Export > Table(s) as csv and select the tables you want to save
13. Select the location you want to save the csvs in and select Save.
   
