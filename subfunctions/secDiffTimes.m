function s = secDiffTimes(timeString1, timeString2)
%
% difference in seconds between two time strings

 s = timeString1 - timeString2;
 s = s *60*60*24; %convert from days to seconds