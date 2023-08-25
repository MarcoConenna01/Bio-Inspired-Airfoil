function [NextObs,Reward,IsDone,LoggedSignals] = myStepFunction2_changeangle(Action,LoggedSignals)

% Custom step function to construct airfoil environment.

% This function applies the given action to the environment and evaluates
% the system characteristics for one simulation step.

% Define the environment constants.
chord = 1; 
alpha = 5; % angle of attack in degrees
u = 22; % speed
k = 1.4207e-5; %air kinematic viscosity
Re = u*chord/k; % Reynolds number
h = 0.01; % height in km
t = h*6.5 + 15; % air temperature
v = t*0.62 + 331; % speed of sound
Mach = u/v; % Mach number
p = 0.4;
t = 0.12;

Delta = Action;

% Unpack the state vector from the logged signals.
State = LoggedSignals.State;
m = State + Delta;

% Calculate new geometry.
n = 50;
HalfCosineSpacing = 1;
is_finiteTE = 0;
af = naca4gen(m,p,t,n,HalfCosineSpacing,is_finiteTE);

coords = [af.x(10:50) af.z(10:50);af.x(52:end-9) af.z(52:end-9)];
% coords(:,1) = coords(:,1) + 0.0001 + abs(min(coords(:,1)));
% Checks on Geometry
intersections = selfintersect(coords(:,1),coords(:,2));
check = isempty(intersections); % interesecting curves
check2 = m > 0.095 || m<0;
if ~check || check2
    Reward = -100;
    IsDone = 0;
else

% Xfoil analysis
tic
[pol,~] =xfoil(coords,m,alpha,Re,Mach);
time = toc;
warning1 = pol.warning;

if warning1
    Reward = -100;
    IsDone = 0;
else

CL = pol.CL;
CD = pol.CD;
ratio = CL/CD;

% update state
LoggedSignals.State = m;

% Check terminal condition.
IsDone = 0;
if ratio > 80
    Reward = 10*ratio;
elseif ratio >50
    Reward = 5*ratio;
else
    Reward = ratio;
end
end
end

% save observation.
NextObs = LoggedSignals.State;

end