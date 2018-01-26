filename= 'v7.mp4';
%concatenate file names for input and output
input=strcat('input/',filename);
v= VideoReader(filename);

se = strel('square', 5);
i=1;
pframe  = rgb2gray(readFrame(v));

diff=pframe;

 while hasFrame(v)
    singleframe = readFrame(v); 
    singleframe=rgb2gray(singleframe);


        if mod(i,2)==0
            diff = singleframe-pframe;
            pframe=singleframe;
            m = max(diff(:));
            m2=min(diff(:));
            diff(diff> (m-m2)*0.15)=255;
            diff(diff< (m-m2)*0.15)=0;
            bw= bwareaopen(diff, 30);
            filteredForeground = imdilate(bw,se);
            bw2 = bwmorph(filteredForeground,'thicken',15);
            bw2 = bwmorph(bw2,'bridge',200);
            cc = bwconncomp(bw2);
            if cc.NumObjects >3
                imshow(frame);
                 i=i+2;
                continue;
               
            end
            imshow( bw2);
        end

   
    i=i+1;

 end


