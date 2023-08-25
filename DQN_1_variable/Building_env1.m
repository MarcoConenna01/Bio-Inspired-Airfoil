clc
clear all
ObservationInfo = rlNumericSpec([1 1]);
ObservationInfo.Name = 'Geometry';
ObservationInfo.Description = 'Max_Camber';

ActionInfo = rlFiniteSetSpec(-0.01:0.001:0.01);
ActionInfo.Name = 'Geometry Morphing';
ActionInfo.Description = 'Max_Camber';

env = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunction1','myResetFunction1');

