clc
clear all
ObservationInfo = rlNumericSpec([12 2]);
ObservationInfo.Name = 'Geometry';

ActionInfo = rlFiniteSetSpec({[-0.01 -0.01 -0.005],[-0.01 -0.005 -0.005],[-0.01 0 -0.005],[-0.01 0.005 -0.005],[-0.01 0.01 -0.005],...
                             [-0.005 -0.01 -0.005],[-0.005 -0.005 -0.005],[-0.005 0 -0.005],[-0.005  0.005 -0.005],[-0.005 0.01 -0.005],...
                             [0 -0.01 -0.005],[0 -0.005 -0.005],[0 0 -0.005],[0  0.005 -0.005],[0 0.01 -0.005],...
                             [0.005 -0.01 -0.005],[0.005 -0.005 -0.005],[0.005 0 -0.005],[0.005  0.005 -0.005],[0.005 0.01 -0.005],...
                             [0.01 -0.01 -0.005],[0.01 -0.005 -0.005],[0.01 0 -0.005],[0.01  0.005 -0.005],[0.01 0.01 -0.005], ...
                             [-0.01 -0.01 -0.01],[-0.01 -0.005 -0.01],[-0.01 0 -0.01],[-0.01 0.005 -0.01],[-0.01 0.01 -0.01],...
                             [-0.005 -0.01 -0.01],[-0.005 -0.005 -0.01],[-0.005 0 -0.01],[-0.005  0.005 -0.01],[-0.005 0.01 -0.01],...
                             [0 -0.01 -0.01],[0 -0.005 -0.01],[0 0 -0.01],[0  0.005 -0.01],[0 0.01 -0.01],...
                             [0.005 -0.01 -0.01],[0.005 -0.005 -0.01],[0.005 0 -0.01],[0.005  0.005 -0.01],[0.005 0.01 -0.01],...
                             [0.01 -0.01 -0.01],[0.01 -0.005 -0.01],[0.01 0 -0.01],[0.01  0.005 -0.01],[0.01 0.01 -0.01], ...
                             [-0.01 -0.01 0],[-0.01 -0.005 0],[-0.01 0 0],[-0.01 0.005 0],[-0.01 0.01 0],...
                             [-0.005 -0.01 0],[-0.005 -0.005 0],[-0.005 0 0],[-0.005  0.005 0],[-0.005 0.01 0],...
                             [0 -0.01 0],[0 -0.005 0],[0 0 0],[0  0.005 0],[0 0.01 0],...
                             [0.005 -0.01 0],[0.005 -0.005 0],[0.005 0 0],[0.005  0.005 0],[0.005 0.01 0],...
                             [0.01 -0.01 0],[0.01 -0.005 0],[0.01 0 0],[0.01  0.005 0],[0.01 0.01 0], ...
                             [-0.01 -0.01 0.005],[-0.01 -0.005 0.005],[-0.01 0 0.005],[-0.01 0.005 0.005],[-0.01 0.01 0.005],...
                             [-0.005 -0.01 0.005],[-0.005 -0.005 0.005],[-0.005 0 0.005],[-0.005  0.005 0.005],[-0.005 0.01 0.005],...
                             [0 -0.01 0.005],[0 -0.005 0.005],[0 0 0.005],[0  0.005 0.005],[0 0.01 0.005],...
                             [0.005 -0.01 0.005],[0.005 -0.005 0.005],[0.005 0 0.005],[0.005  0.005 0.005],[0.005 0.01 0.005],...
                             [0.01 -0.01 0.005],[0.01 -0.005 0.005],[0.01 0 0.005],[0.01  0.005 0.005],[0.01 0.01 0.005], ...
                             [-0.01 -0.01 0.01],[-0.01 -0.005 0.01],[-0.01 0 0.01],[-0.01 0.005 0.01],[-0.01 0.01 0.01],...
                             [-0.005 -0.01 0.01],[-0.005 -0.005 0.01],[-0.005 0 0.01],[-0.005  0.005 0.01],[-0.005 0.01 0.01],...
                             [0 -0.01 0.01],[0 -0.005 0.01],[0 0 0.01],[0  0.005 0.01],[0 0.01 0.01],...
                             [0.005 -0.01 0.01],[0.005 -0.005 0.01],[0.005 0 0.01],[0.005  0.005 0.01],[0.005 0.01 0.01],...
                             [0.01 -0.01 0.01],[0.01 -0.005 0.01],[0.01 0 0.01],[0.01  0.005 0.01],[0.01 0.01 0.01], ...
                             });
ActionInfo.Name = 'Geometry Morphing';
ActionInfo.Description = 'Max_Camber';

env = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunction_bezier','myResetFunction1');

