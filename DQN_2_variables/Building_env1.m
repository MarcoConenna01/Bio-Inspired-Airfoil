clc
clear all
ObservationInfo = rlNumericSpec([1 2]);
ObservationInfo.Name = 'Geometry';
ObservationInfo.Description = {'Max_Camber','Max_Thickness'};

ActionInfo = rlFiniteSetSpec({[-0.01 -0.01],[-0.01 -0.005],[-0.01 0],[-0.01 0.005],[-0.01 0.01],...
                             [-0.005 -0.01],[-0.005 -0.005],[-0.005 0],[-0.005  0.005],[-0.005 0.01],...
                             [0 -0.01],[0 -0.005],[0 0],[0  0.005],[0 0.01],...
                             [0.005 -0.01],[0.005 -0.005],[0.005 0],[0.005  0.005],[0.005 0.01],...
                             [0.01 -0.01],[0.01 -0.005],[0.01 0],[0.01  0.005],[0.01 0.01]});
ActionInfo.Name = 'Geometry Morphing';
ActionInfo.Description = 'Max_Camber';

env = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunction1','myResetFunction1');

