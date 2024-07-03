
function dateString = tickTimes2dateString(fileName)

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

% offset (serial date number for 1/1/1970)
dnOffset = datenum('01-Jan-1970');

dnNow = x/(24*60*60) + dnOffset;

dateString = datestr(dnNow);


