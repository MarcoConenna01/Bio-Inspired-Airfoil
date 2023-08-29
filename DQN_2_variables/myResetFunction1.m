function [InitialObservation, LoggedSignal] = myResetFunction1()
% Reset function to place custom airfoil environment into initial state
% 2212

% Return initial environment state variables as logged signals.
LoggedSignal.State = [0 0.12];
InitialObservation = LoggedSignal.State;

end