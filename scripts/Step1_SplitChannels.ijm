//ImageJ Channel Saver for Krissy
//Rebecca Senft
//Sep 14 2020
// 
/*
 * Instructions:
 * 
 * PLEASE READ
 * 
 * Upon running, ImageJ will ask you to select the location to store output images. 
 * Then user selects a single image that is currently open. 
 * It doesn't matter what file type they are (e.g. tif, czi, nd2, lsm will all work). 
 * 
 * 
 * This macro will take a user-selected channel and save that output into a separate folder for Cell Profiler to use
 * 
 * Please report any errors or crashes you get to Rebecca Senft (senft@g.harvard.edu)
 */

//***********************************************	
//Step 1. Select directory to save images and produce list of open images to process
//***********************************************	
setBatchMode(true); 
//get date information for naming the output folder
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (dayOfMonth<10) {dayOfMonth = "0"+dayOfMonth;}
month=month+1;
if (month<10) {month = "0"+month;}
date=toString(year)+toString(month)+toString(dayOfMonth);
//get directory with images and create the output directory
saveType="Tiff";
dir= getDirectory("Choose a Directory with your Images");
dirSave=dir + "CP_images/";
File.makeDirectory(dirSave);

//Get all the images from the folder selected by the user
list=getFileList(dir);
files=newArray(0);

for (i=0;i<list.length; i++){
	//print(list[i]);
	if((endsWith(list[i],".czi"))||(endsWith(list[i],".tif"))||(endsWith(list[i],".lsm"))||(endsWith(list[i],".nd2"))||(endsWith(list[i],".tiff"))){
	files=Array.concat(files,list[i]);
}
}
//***********************************************	
//Step 2 Open image and save selected channel
//***********************************************	
for (j=0;j<files.length; j++){
	run("Bio-Formats Windowless Importer", "open=["+dir+files[j]+"]");
  	getDimensions(dummy, dummy, channels, sliceCount, dummy); //extract the number of channels
 	name=getTitle();
  	saveName=File.nameWithoutExtension;
  	if (sliceCount>1){ 
		run("Z Project...", "projection=[Max Intensity]");
		selectWindow(name);
		rename("stack");
		selectWindow("MAX_"+name);
		rename(name);
	}
	run("Split Channels");
	for(i=0;i<channels; i++){
		ch=i+1;
		selectWindow("C"+ch+"-"+name);
		saveAs(saveType, dirSave+saveName+"_C"+ch);
	}
	run("Close All");
}