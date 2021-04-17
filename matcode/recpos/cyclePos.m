function [recPosition] = cyclePos(ttr, settings) 
%CYCLEPOS Computation of receiver coordinates X,Y,Z at TTR for
%given reference time with cycle trajectory. 
%[recPosition] = recpos(ttr, tref) 
%
%   Inputs:
%       ttr           - receiver posiontion at ttr time (GPST) 
%       settings      - receiver posiontion settings
%
%   Outputs:
%       recPosition  - position of receiver (in ECEF system [X; Y; Z;])


% receiver position is a cycle trajectory.
if(settings.recRadius ~= 0)
    dt       = ttr - settings.recRefTime;
    distance = settings.recVel*dt + (1/2)*settings.recAcc*dt^2 + (1/6)*settings.recJerk*dt^3;

    E = settings.recRadius * cos(distance/settings.recRadius);
    N = settings.recRadius * sin(distance/settings.recRadius);
    U = 0;
else
    E = 0;
    N = 0;
    U = 0;
end
recPosition = (llh2xyz(settings.recposOrigin) + enu2xyz(settings.recposOrigin,[E N U]))';