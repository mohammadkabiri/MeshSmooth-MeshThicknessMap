
clc;
clear
close all

[x,y,z] = peaks(25);
CO(:,:,1) = zeros(25); % red
CO(:,:,2) = ones(25).*linspace(0.5,0.6,25); % green
CO(:,:,3) = ones(25).*linspace(0,1,25); % blue

x=x+rand(size(x))*0.12;
y=y+rand(size(y))*0.05;
z=z+rand(size(z))*0.85;

subplot(121)
 surf(x,y,z,CO)
 title('main')
view(35,28)

% [p3do,mesh,mesh2]=msmooth(p3d,n,step,idp)
% -------- Inputs
% p3d=[x,y,z] Nx3 double
% n=[0:1] 0:no smoothing 1x1 double
% step=interpolation step on surf 1x1 int
% idp=axis number to smooth, 1:x,2:y,z:3 1x1 int
% -------- Outputs
% p3do:smoothed points Nx3 double
% mesh:quad mesh with the same points
% mesh2:quad mesh on regular base points regular base mesh:(min:step:max)
% patch(mesh{1},mesh{2},mesh{3},mesh{4},'FaceColor','interp');


 p3d=[x(:),y(:),z(:)];
 n=0.1
 step=0.25
 idp=3 %z
 
[p3ds,mesh,mesh2]=msmooth(p3d,n,step,idp);
subplot(122)
patch(mesh{1},mesh{2},mesh{3},mesh{4},'FaceColor','interp');
title('smoothed')
view(35,28)
grid on


