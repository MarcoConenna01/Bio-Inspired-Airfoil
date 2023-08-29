function [InitialObservation, LoggedSignal] = myResetFunction()
% Reset function to place custom airfoil environment into initial state
% 2212

% Return initial environment state variables as logged signals.
LoggedSignal.State = 0;
InitialObservation = LoggedSignal.State;

end