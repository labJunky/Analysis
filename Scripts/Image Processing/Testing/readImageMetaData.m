image = Tiff('myFile.tif');
description = image.getTag('ImageDescription');
image.close();