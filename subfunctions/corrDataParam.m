function [indice error] = corrDataParam(TimeStringData, TimeStringParam, shift)
%returns the array indice.
%indice(1) is the index of the value in TimeStringParam closest to
%TimeStringData(1).
%error(1) contains the difference between these two values.

N = length(TimeStringData);
K = length(TimeStringParam);

% tempTime=TimeStringParam+shift;%Frank edit

indice = zeros(1, N);
error  = zeros(1, N);

%each iteration is a single data block
for n = 1:N  
    
    bestMatch = inf;
    for k = 1:K
        
        difference = secDiffTimes(TimeStringData(n), TimeStringParam(k)+shift);%Frank edit temp time
        
        %compare abs value of difference with best match. also check so
        %that the match is unique.
        if (abs(difference) < abs(bestMatch)) %&& (sum(indice==k) == 0)
            bestMatch = difference;
            indice(n) = k;
        end
    end
    
    error(n) = bestMatch;        
end

function s = secDiffTimes(timeString1, timeString2)
%
% difference in seconds between two time strings

 s = timeString1 - timeString2;
 s = s *60*60*24; %convert from days to seconds
