function s = secDiffDates(dateString1, dateString2)
%
%difference in seconds between two date strings

timeString1 = datenum(dateString1); %in days
timeString2 = datenum(dateString2);

s = timeString1 - timeString2;
s = s *86400;