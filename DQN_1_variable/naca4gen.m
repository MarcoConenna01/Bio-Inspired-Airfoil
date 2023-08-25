function af = naca4gen(m,p,t,n,HalfCosineSpacing,is_finiteTE)
%
% "naca4gen" Generates the NACA 4 digit airfoil coordinates with desired no.
% of panels (line elements) on it.
%      Author : Divahar Jayaraman (j.divahar@yahoo.com)
% 
% INPUTS-------------------------------------------------------------------
%       designation = NACA 4 digit designation (eg. '2412') - STRING !
%                 n = no of panels (line elements) PER SIDE (upper/lower)
% HalfCosineSpacing = 1 for "half cosine x-spacing" 
%                       = 0 to give "uniform x-spacing"
%          wantFile = 1 for creating airfoil data file (eg. 'naca2412.dat')
%                       = 0 to suppress writing into a file
%       datFilePath = Path where the data  file has to be created
%                         (eg. 'af_data_folder/naca4digitAF/') 
%                         use only forward slash '/' (Just for OS portability)
% 
% OUTPUTS------------------------------------------------------------------
% Data:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%       af.x = x cordinate (nx1 array)
%       af.z = z cordinate (nx1 array)
%      af.xU = x cordinate of upper surface (nx1 array)
%      af.zU = z cordinate of upper surface (nx1 array)
%      af.xL = x cordinate of lower surface (nx1 array)
%      af.zL = z cordinate of lower surface (nx1 array)
%      af.xC = x cordinate of camber line (nx1 array)
%      af.zC = z cordinate of camber line (nx1 array)
%    af.name = Name of the airfoil
%  af.header = Airfoil name ; No of panels ; Type of spacing
%              (eg. 'NACA4412 : [50 panels,Uniform x-spacing]')
% 
% 
% File:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% First line : Header eg. 'NACA4412 : [50 panels,Half cosine x-spacing]'
% Subsequent lines : (2*n+1) rows of x and z values
% 
% Typical Inputs:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% n=56;
% HalfCosineSpacing=1;
% wantFile=1;
% datFilePath='./'; % Current folder
% is_finiteTE=0;

a0= 0.2969;
a1=-0.1260;
a2=-0.3516;
a3= 0.2843;

if is_finiteTE ==1
    a4=-0.1015; % For finite thick TE
else
    a4=-0.1036;  % For zero thick TE
end

% % [[Giving x-spacing---------------------------------------------------]]
if HalfCosineSpacing==1
    beta=linspace(0,pi,n+1)';
    x=(0.5*(1-cos(beta))); % Half cosine based spacing
    
else
    x=linspace(0,1,n+1)';
   
end

yt=(t/0.2)*(a0*sqrt(x)+a1*x+a2*x.^2+a3*x.^3+a4*x.^4);

xc1=x(find(x<=p));
xc2=x(find(x>p));
xc=[xc1 ; xc2];

if p==0
    xu=x;
    yu=yt;

    xl=x;
    yl=-yt;
    
    zc=zeros(size(xc));
else
    yc1=(m/p^2)*(2*p*xc1-xc1.^2);
    yc2=(m/(1-p)^2)*((1-2*p)+2*p*xc2-xc2.^2);
    zc=[yc1 ; yc2];

    dyc1_dx=(m/p^2)*(2*p-2*xc1);
    dyc2_dx=(m/(1-p)^2)*(2*p-2*xc2);
    dyc_dx=[dyc1_dx ; dyc2_dx];
    theta=atan(dyc_dx);

    xu=x-yt.*sin(theta);
    yu=zc+yt.*cos(theta);

    xl=x+yt.*sin(theta);
    yl=zc-yt.*cos(theta);
end

af.x=[flipud(xu) ; xl(2:end)];
af.z=[flipud(yu) ; yl(2:end)];

indx1=1:min( find(af.x==min(af.x)) );  % Upper surface indices
indx2=min( find(af.x==min(af.x)) ):length(af.x); % Lower surface indices
af.xU=af.x(indx1); % Upper Surface x
af.zU=af.z(indx1); % Upper Surface z
af.xL=af.x(indx2); % Lower Surface x
af.zL=af.z(indx2); % Lower Surface z
    
af.xC=xc;
af.zC=zc;

lecirFactor=0.8;
af.rLE=0.5*(a0*t/0.2)^2;

le_offs=0.5/100;
dyc_dx_le=(m/p^2)*( 2*p-2*le_offs );
theta_le=atan(dyc_dx_le);
af.xLEcenter=af.rLE*cos(theta_le);
af.yLEcenter=af.rLE*sin(theta_le);
