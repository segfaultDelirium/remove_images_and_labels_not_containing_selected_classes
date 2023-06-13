The program was created to process COCO dataset for purpose of using it with YOLOv5 model. 
We have selected 19 classes that we want the dataset to contain and discard other classes. 
The program will read label files and image files and remove files which does not contain at least one of the 19 classes. 

how to use it?

iex -S mix

then  in the iex shell

RemoveFilesNotContainingClassFrom19.main

You will find result in the output directory
