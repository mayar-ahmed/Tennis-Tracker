filename= 'v17.mp4';
%concatenate file names for input and output
input=strcat('input/',filename);
output=strcat('output/',filename);
outimage=strcat('output/',filename,'.png');
outimage2=strcat('output/',filename,'2.png');

%initialize video writer and reader objects
v= VideoReader(input);
writer = VideoWriter(output);
writer.FrameRate = 8; %setting frame rate of the output video to see it clearly

se = strel('square', 6); %structuring element used in dilation operation

%initialize blob analysis object with minimum area of 1300 and make it return centroids and bounding boxes
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 1300);

%read first frame of the video
f=readFrame(v);
sum = double(f); %accumulator for frames to get the average and extract the court
prevframe  = rgb2gray(f); %previous frame to subtract from

[s1, s2] = size(prevframe);
diff=prevframe; %difference between each two frames
c=zeros(1,2); %used to save centroids
i=1;
j=2;
open(writer);
while hasFrame(v)
    frame =  readFrame(v);
    curr_frame=rgb2gray(frame);
    
    if mod(i,3)==0
        diff = curr_frame-prevframe; %subtract current frame from previous frame
        prevframe=curr_frame; %set the new frame as the previous for next subtraction
        m1 = max(diff(:));
        m2=min(diff(:));
        %threshold the difference and convert it to a binary image
        diff(diff> (m1-m2)*0.15)=255;
        diff(diff< (m1-m2)*0.15)=0;
        %remove objects with number of pixels less than 30
        bw= bwareaopen(diff, 30);
        %apply morphological operations on image
        bw1 = imdilate(bw,se);
        bw2 = bwmorph(bw1,'thicken',15);
        bw2 = bwmorph(bw2,'bridge',500);
        %get number of connected components in the image, if it's more than two skip the frame
        cc = bwconncomp(bw2);
        if cc.NumObjects >2
            writeVideo(writer,frame);
            imshow(frame);
            i=i+2;
            continue;
        end
        %accumulate 130 frames to get average frame from them
        if i<130
            sum=sum+double(frame);
            j=j+1;
        end
        
        %if there are 2 objects, run blob analysis and get their centroids and bounding boxes
        [centroid, bbox] = step(blobAnalysis, bw2);
        
        s = ones(size(centroid,1),1);
        s=s+2;
        
        %insert centroid and bounding box into image and display it
        result = insertShape(frame, 'Rectangle', bbox, 'Color', 'red', 'linewidth', 3);
        result=insertShape(result,'Rectangle' ,[centroid s s],'Color','green','linewidth', 3);
        writeVideo(writer,result);
        imshow(result);
        
        %save last detected centroids
        c = [c ;centroid];
    end
    
    
    i=i+1;
    
end

close(writer);
x1=sortrows(c,2); %sort centroids based on their y dimension
r1=size(c,1);
x1= x1((0.43*r1):r1, :); %filter points to get only centroids in the first half of the court
im=sum/j; %get average of frames
im=uint8(im);
figure;
imshow(im);
hold on;
plot(x1(:,1),x1(:,2),'r.' ,'markersize',5); %plot centroids on top of the court
axis auto;
print(outimage,'-dpng')
hold off;

figure;
%get position of service line and baseline using hough liness
[ay]=Hough(rgb2gray(im));
baseline=ay(1,3);
serviceline=ay(2,3);
basex=200;
imshow(im);
hold on;
plot(basex, serviceline, 'rx');
plot( basex, baseline, 'bx');
behind=0;
between=0;
%get centroids that are behind baseline and that are between service line and baseline 
for k=1:size(x1,1)
    if x1(k,2)>baseline
        plot(x1(k,1),x1(k,2),'g.' ,'markersize',5);
        behind=behind+1;
    end
    
    if (x1(k,2)<baseline && x1(k,2)>serviceline) ||( x1(k,2)<serviceline)
         plot(x1(k,1),x1(k,2),'r.' ,'markersize',5);
         between=between+1;
    end
end
%calculate oercentage of points in each region and display it
per1 = (behind/size(x1,1)) *100;
per2 = (between/size(x1,1)) *100;
strings = {strcat(num2str(per1), '%'),strcat(num2str(per2), '%') };
t1=text([basex,basex],[baseline+4,serviceline+4],strings);

t1(1).Color = 'black';
t1(1).FontSize = 14;
t1(2).Color = 'black';
t1(2).FontSize = 14;
print(outimage2,'-dpng')
hold off;



