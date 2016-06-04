%num = number of images in reference set
% t = average time per image to analyse 10 images
% lt = load time for the all the images in the reference set
% st = average standard deviation of noise in the image (averaged over the
%       number in the set)

%Conclusion: for 20 - 50 images in the set the quality increases linearly
%            though the time to analyse increases exponentially! 
%            So the optimum is to take around 30 images into consideration.

num = [10:10:50];
t = [0.598 0.675 1.08 2.54 2.85];
lt = [1.65 3.07 5.3 8.02 10.7];
st = [0.0524 0.0465 0.0453 0.0442 0.0432];

figure(1)
plot(t,st)

