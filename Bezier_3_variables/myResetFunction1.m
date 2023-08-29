function [InitialObservation, LoggedSignal] = myResetFunction1()
% Reset function to place custom airfoil environment into initial state
% 2212
% Return initial environment state variables as logged signals.
load coords.mat BX_L BX_U BY_L BY_U
LoggedSignal.State = [BX_U BY_U;BX_L BY_L];
InitialObservation = LoggedSignal.State;

end