%Read the reference image containing the object of interest.
boxImage = imread('cigarette.jpeg');
figure;
imshow(boxImage);
title('Image of a Box');

%Read the target image containing a cluttered scene.
sceneImage = imread('jokerimage.png');
hFig = figure;
hFig.WindowState = 'maximized';
imshow(sceneImage);
title('Image of a Cluttered Scene');

%Detect feature points in both images.
boxPoints = detectSURFFeatures(rgb2gray(boxImage));
scenePoints = detectSURFFeatures(rgb2gray(sceneImage));

% Visualize the strongest feature points found in the reference image.
figure;
imshow(boxImage);
title('100 Strongest Feature Points from Box Image');
hold on;
plot(selectStrongest(boxPoints, 100));

% Visualize the strongest feature points found in the target image.
figure;
imshow(sceneImage);
title('300 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(scenePoints, 300));

%Extract feature descriptors at the interest points in both images.
[boxFeatures, boxPoints] = extractFeatures(rgb2gray(boxImage), boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(rgb2gray(sceneImage), scenePoints);

%Match the features using their descriptors.
boxPairs = matchFeatures(boxFeatures, sceneFeatures);

% Display putatively matched features.
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
figure;
showMatchedFeatures(boxImage, sceneImage, matchedBoxPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');

%Display putatively matched features.
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);


% estimateGeometricTransform calculates the transformation relating the matched points, while eliminating outliers. 
% This transformation allows us to localize the object in the scene.
[tform, inlierBoxPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');

% Display the matching point pairs with the outliers removed
figure;
showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');

%Get the bounding polygon of the reference image.
boxPolygon = [1, 1;...                           % top-left
        size(boxImage, 2), 1;...                 % top-right
        size(boxImage, 2), size(boxImage, 1);... % bottom-right
        1, size(boxImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
    
%Transform the polygon into the coordinate system of the target image. 
%The transformed polygon indicates the location of the object in the scene.
newBoxPolygon = transformPointsForward(tform, boxPolygon);

% Display the detected object.
figure;
imshow(sceneImage);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');

% image(), which permits us to pass data coordinates for lower left and upper right.
% Note that the coordinates are for the centers of pixels.
% coordinates of left side of detected part of image
x = newBoxPolygon(1);
y = newBoxPolygon(6);

% replace our image with the detected part of the original image
papatya = imread('papatya.png');
hold on;
image([x x], [y y], papatya, 'CDataMapping', 'scaled'); colormap(gray(64));
