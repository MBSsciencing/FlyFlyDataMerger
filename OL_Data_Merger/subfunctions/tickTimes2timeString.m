
function x = tickTimes2timeString(fileName)

load(fileName);

%make an array with the starting times of all blocks
n = 1;
while true
    try
        fileName = ['ticktimes_block' num2str(n) '(1,1)'];
        x(n) = eval(fileName);
    catch
        break;
    end
    n = n+1;
end

x = x'; %x is number of seconds since 1 jan 1970

offset = datenum('01-Jan-1970'); %number of seconds up til 1 jan 1970

x = x/(24*60*60) + offset; %current time in seconds
