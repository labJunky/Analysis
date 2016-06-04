image = imread('120709_1751_28 FR_2.tif');

t = Tiff('myFile.tif','w');

tagstruct.ImageLength = size(image,1);
tagstruct.ImageWidth = size(image,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = 'MATLAB';
t.setTag(tagstruct);

t.setTag('ImageDescription','This is my test string');
t.write(image);

t.close();