%ACES new camera image reader

[header, data, gains, offsets] = readImgFile("trial_2/trial2_vib_set3.img");
b = [];



frameset = data(10,312,:);


for i = 1:length(frameset)
    
    imshow(data(:,:,i),'InitialMagnification',1000)
    colormap bone
    pause(.001)
end

ims_set = cell(length(frameset), 1);

for u = 1:length(frameset)
    im1 = (data(:,:,u));
    imwrite(double(im1), 'image.png')
    ims_set{u} = imread('image.png');
end



% Prepare the new file.
writerObj = VideoWriter('trial2_set3.avi');
writerObj.FrameRate = 0.01;
open(writerObj);

% Create an animation.
% write the frames to the video
for v=1:length(frameset)
    % convert the image to a frame
    frame = im2frame(ims_set{v});
    writeVideo(vidObj, frame);
end
% Close the file.
close(vidObj);