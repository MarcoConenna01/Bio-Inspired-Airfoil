function coordinates = BezierAirfoil(BX_U,BX_L,BY_U,BY_L)

% BezierAirfoil code: written by Farzad Mohebbi, PhD 
% Email: farzadmohebbi@yahoo.com
% Marie Skodowska-Curie Post Doctoral Fellow
% Zienkiewicz Centre for Computational Engineering
% Swansea University
% Refer to the PhD thesis (Optimal shape design based on body-fitted grid generation)
% http://hdl.handle.net/10092/9427
% Pages 203-205 for the following expressions
% To run the code, two files x & y (airfoil nodes coordinates) should be imported.
% As a sample, the airfoil nodes for NACA 0012 airfoil are given (181 nodes on the airfoil)
% It can be modified for any airfoil shape and any number of nodes
%--------------------------------------------------------------------------
N = 101;
deg=5;    % degree of Bezier curve (can be changed)
cps=deg+1; % the number of control points which is degree+1
t=linspace(0,1,(N+1)/2);   % t is in [0,1]
 
for i=1:(N+1)/2 
for s=1:cps
J(i,s)=nchoosek(deg,s-1)*(t(i)^(s-1))*((1-t(i))^(deg-s+1));
end
end

for i=1:(N+1)/2 
    Xbezier_U(i)=J(i,:)*BX_U; 
    Ybezier_U(i)=J(i,:)*BY_U;
  
    Xbezier_L(i)=J(i,:)*BX_L;
    Ybezier_L(i)=J(i,:)*BY_L; 
end
 
coordinates = [flip(Xbezier_U') flip(Ybezier_U') ; Xbezier_L' Ybezier_L'];
end