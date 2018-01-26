# Tennis-Tracker
A program for tracking players in a tennis match using blob analysis in matlab 

- There are two files: tennis_tracker, tracker_with_percent
- The first one outputs motion tracking results in a video file and a plot of the player movements
- The second one generates the same output in addition to a plot with the percentage of movement in areas of the court
but the detection of the tennis court is not accurate
- They both take the input from the input folder and generate the output in the output folder
-There are multiple videos with their results in the input and output folders .to run any of them just specify the video name you want to run in the first line of code
example : filename= 'v1.mp4' , it will get it from the input folder and produce the corresponding output
-player_extraction.m shows the oprations applied on the video before detection.


The algorithm steps are the following: 
1- Frame differencing
2- Noise removal
3- Morphological operations
4- Blob Analysis
5- Detecting players
6- Visualize moving pattern


Output examples: 
![Alt text](/media/mayar/not_fun/year 3/semester 1/projects/Image Processing team 13/tracker/s1.png?raw=true)
![Alt text](/media/mayar/not_fun/year 3/semester 1/projects/Image Processing team 13/tracker/s2.png?raw=true)
![Alt text](/media/mayar/not_fun/year 3/semester 1/projects/Image Processing team 13/tracker/s3.png?raw=true)

the complete details of the project can be found on Report.docx