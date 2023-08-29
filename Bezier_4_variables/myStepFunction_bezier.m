function [NextObs,Reward,IsDone,LoggedSignals] = myStepFunction_bezier(Action,LoggedSignals)

% Custom step function to construct airfoil environment.

% This function applies the given action to the environment and evaluates
% the system characteristics for one simulation step.

% Define the environment constants.
chord = 1; 
alpha = 0; % angle of attack
u = 22; % speed
k = 1.4207e-5; %air kinematic viscosity
Re = u*chord/k; % Reynolds number
h = 0.01; % height in km
t = h*6.5 + 15; % air temperature
v = t*0.62 + 331; % speed of sound
Mach = u/v; % Mach number

% Unpack the state vector from the logged signals.
State = LoggedSignals.State;
DY3 = Action(1);
DY4 = Action(2);
DY5 = Action(3);
Dt = Action(4);

%state = [BX_U BY_U;BX_L BY_L];
% Calculate new geometry.
BX_U = State(1:6,1);
BY_U = State(1:6,2);
BX_L = State(7:12,1);
BY_L = State(7:12,2);

BY_U(3:5) = BY_U(3:5) + [DY3;DY4;DY5]+0.5*[Dt 0 0]';
BY_L(3:5) = BY_L(3:5) + [DY3;DY4;DY5]-0.5*[Dt 0 0]';


cc = BezierAirfoil(BX_U,BX_L,BY_U,BY_L);
cc = [cc(10:50,:) ; cc(53:end-9,:)];

% Checks on Geometry
intersections = selfintersect(cc(1:end,1),cc(1:end,2));
check = isempty(intersections);   % interesecting curves
max_camber = 0.5*max(cc(1:41,2)+flip(cc(42:end,2)));
check2 = max_camber > 0.0095 || max_camber<-0.0005 ;
max_thickness = max(cc(1:41,2)-flip(cc(42:end,2))); %% 
check3 = max_thickness<0.05;

if ~check || check2 || check3
    Reward = -100;
    IsDone = 0;
else

% Xfoil analysis

[pol,~] =xfoil(cc,alpha,Re,Mach);

warning1 = pol.warning;

if warning1
    Reward = -1000;
    IsDone = 0;
else

CL = pol.CL;
CD = pol.CD;
ratio = CL/CD;

% update state
LoggedSignals.State = [BX_U BY_U;BX_L BY_L];

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



