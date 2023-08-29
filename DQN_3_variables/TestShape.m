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

m = 0.074;
p = 0.4;
t = 0.12;


af = naca4gen(m,p,t,50,1,1);
coords = [af.x(10:50) af.z(10:50);af.x(52:end-9) af.z(52:end-9)];
% %% Airfoils geometry generation
% 
% for i = 1:length(x)
% 
%     yt(i) = 5*maxthick*c*(0.2969*sqrt(x(i)/c)-0.1260*x(i)/c-0.3516*(x(i)/c)^2+0.2843*(x(i)/c)^3-0.1036*(x(i)/c)^4);
% 
%     if x(i) < p*c        
%         yc(i) = m*x(i)/p^2*(2*p-x(i)/c);
%         dycdx = 2*m/p^2*(p-x(i)/c);
%     else
%         yc(i) = m*(c-x(i))/(1-p)^2*(1+x(i)/c-2*p);
%         dycdx = 2*m/(1-p)^2*(p-x(i)/c);  
%     end
% 
%     theta = atan(dycdx);
%     xplus(i) = x(i) - yt(i)*sin(theta);
%     xminus(i) = x(i) + yt(i)*sin(theta);
%     yplus(i) = yc(i) + yt(i)*cos(theta);
%     yminus(i) = yc(i) - yt(i)*cos(theta);
% end
% 
% bottomcoord = [xminus' yminus'];
% upcoord = [xplus' yplus'];
% 
% test = [flip(xplus) xminus ; flip(yplus) yminus]';

% plot(test(:,1),test(:,2))
% hold on
% plot(x,yc)
% hold on
% plot(x,yt)

 [pol,foil] =xfoil(coords,m,0,Re,0.1);
 pol.CL/pol.CD