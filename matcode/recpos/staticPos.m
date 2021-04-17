function [recPosition] = staticPos(ttr, settings) 
%RECPOS Computation of receiver coordinates X,Y,Z at TTR for
%given reference time. 
%[recPosition] = recpos(ttr, tref) 
%
%   Inputs:
%       ttr           - transmission time
%       tref          - receiver posiontion reference time
%
%   Outputs:
%       recPosition  - position of receiver (in ECEF system [X; Y; Z;])


% receiver position is a static trajectory.
recPosition = llh2xyz(settings.recposOrigin)';