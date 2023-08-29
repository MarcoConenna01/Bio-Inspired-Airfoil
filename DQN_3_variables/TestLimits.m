clc
close all
clear variables
%% Cruise parameters

u = 22; %[m/s]
ni = 1.3324E-5; %[m^2s^-1]
c = 1; %[m]
Re = u*c/ni;

x = linspace(0,c,100);
xplus = zeros(1,length(x));
xminus = zeros(1,length(x));
yplus = zeros(1,length(x));
yminus = zeros(1,length(x));

m = 0.001;
p = 0.4;
t = 0.12;
j=50;
for i = 1:10000
m = m + i/10000;
af = naca4gen(m,p,t,j,1,0);
coords = [af.x(10:j) af.z(10:j);af.x(j+2:end-9) af.z(j+2:end-9)];
plot(coords(:,1),coords(:,2))
[pol,foil] =xfoil(coords,m,0,Re,0.1);
pol.CL/pol.CD
if pol.warning == 1
    pointer(j) = i;
    break
end
end
