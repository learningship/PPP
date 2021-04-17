function [recPosition] = straightPos(ttr, settings) 
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


% receiver position is a straight trajectory.
dt       = ttr - settings.recRefTime;
distance = settings.recVel*dt + (1/2)*settings.recAcc*dt^2 + (1/6)*settings.recJerk*dt^3;

E = distance;
N = 0;
U = 0;

recPosition = (llh2xyz(settings.recposOrigin) + enu2xyz(settings.recposOrigin,[E N U]))';