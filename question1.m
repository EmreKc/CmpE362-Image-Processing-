img = imread("jokerimage.png");
img = uint8(img);
hFig = figure;
hFig.WindowState = 'maximized';

% generate blur matrix using filter method
kernel = [1 1 1;1 1 1;1 1 1];
blur = filter(img, kernel, 9);
subplot(2, 2, 1);
imshow(blur);
title('Blurred', 'FontSize', 20);

% generate sharpenned matrix using filter method
kernel = [0 -1 0;-1 5 -1;0 -1 0];
sharpen = filter(blur, kernel, 1);
subplot(2, 2, 2);
imshow(sharpen);
title('Sharpen', 'FontSize', 20);

% generate matrix for edges using filter method
kernel = [-1 -1 -1;-1 8 -1;-1 -1 -1];
edges = filter(img, kernel, -1);
subplot(2, 2, 3);
imshow(edges);
title('Edges', 'FontSize', 20);

% generate embossed matrix using filter method
kernel = [-2 -1 0;-1 1 1;0 1 2];
embossed = filter(img, kernel, 1);
subplot(2, 2, 4);
imshow(embossed);
title('Embossed', 'FontSize', 20);

function output = filter(img, kernel, divisor)
    [rows, columns] = size(img);
    output = img;
    kernel_dim = size(kernel);
    % loop all colums and rows for 3 color 
    for mat = 1 : 3
        for col = 1 : (columns/3 - kernel_dim + 1)
            for row = 1 : (rows - kernel_dim + 1)
                % rot90(kernel, 2) = flipud(fliplr(kernel))
                a = rot90(kernel, 2);
                % 3x3 part of the img
                b = img(col:col+kernel_dim - 1, row:row+kernel_dim - 1, mat);
                % calculate the central pixel's value
                value = transpose(reshape(double(b), [], 1)) * reshape(a, [], 1) / divisor;
                % assign central pixel value
                output(col+1, row+1, mat) = value;
            end
        end
    end
    output = uint8(output);
end