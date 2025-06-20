function [x, timeName] = tickTimes2timeString(fileName)
% Inform the user of warning message
disp("A warning will come up as part of this script, please ignore it as it's intentional")

% Make an array with the starting times of all blocks
n = 1;
% Test to see what kind of variable we're dealing with
oldTimes = true;
validFile = false;
warning off % Temporarily turn off warnings so we can check our data name scheme
load(fileName, "ticktimes_block1") %#ok<NASGU>
load(fileName, "Ticktime_Block_1") %#ok<NASGU>
if exist('ticktimes_block1', 'var')
    validFile = true;
    timeName = 'ticktimes_block1';
elseif exist('Ticktime_Block_1', 'var')
    oldTimes = false;
    validFile = true;
    timeName = 'Ticktime_Block_1';
end
warning on

if validFile == false
    disp("Incorrect file loaded, no ticktimes variable present or detected!")
end

% We need either "ticktimes_block' num2str(n) '" or "Ticktime_Block_' num2str(n) '"  
while true
    try
        if oldTimes == true
            eval(['load(fileName, "ticktimes_block' num2str(n) '");']);
            timeBlock = ['ticktimes_block' num2str(n)];
        else
            eval(['load(fileName, "Ticktime_Block_' num2str(n) '");']);
            timeBlock = ['Ticktime_Block_' num2str(n)];
        end
        x(n) = eval(timeBlock);
    catch
        break;
    end
    n = n+1;
end

x = x'; %x is number of seconds since 1 jan 1970

if oldTimes == false
    x = double(x);
end

offset = datenum('01-Jan-1970'); %number of seconds up til 1 jan 1970
x = x/(24*60*60) + offset; %current time in seconds
