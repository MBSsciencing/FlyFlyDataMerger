%Edited by Joseph Fabian in Nov 2020 based off Sarah Nicholas original script.
%This script is altered to import data from the windows version of
%labchart, not the mac version. Changes include correcting the altered
%channel order, and adding in downsampling.
%
%IMPORTANT!!! This script desamples the data from 40kHz to 1kHZ, in order
%to reduce file sizes and make the following analysis much faster. This
%downsampling occurs AFTER spike sorting, so to not alter spike sorting
%accuracy. If you need sub-millisecond spike timing accuracy do not use
%this script, but it should be precise enough for 99% of cases.

clear

downsample_factor = 40; %how much do you want to downsample data by? 1 = no downsample, 40 means 40 times shorter (40k -> 1k)

A = dir('*.txt');
delimiter = '\t';
formatSpec = '%{HH:mm:ss.SSSS}D%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
Number_Repeats =length(A);
filename= A(1).name;
formatSpec2 = 'Processing %s\n';

% Open the text file and format it as desired
fprintf(formatSpec2, A(1).name);
fileID = fopen(filename,'r');
% Save contents of file into a variable
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

% Find time stamps for the full file
Date = A(1).name(1:6);
RawTime = dataArray{:, 1};  
% Find incorrect times, and guesstimate what they would've been
NotaTime = find(isnat(RawTime));
sampleRate = 40000;
for x = 1:length(NotaTime);
    RawTime(NotaTime(x))=RawTime(NotaTime(x)+1)-seconds(0.0001);
end
HoursALL = hour(RawTime);

HourStart = HoursALL(1);
    LengthTime = length(RawTime);
    HourEnd = HoursALL(length(HoursALL));
        if  HourStart == HourEnd && HourStart > 6;
        FixedTime = RawTime;
        elseif HourStart == HourEnd;
            FixedTime = RawTime + hours (12);
        end
   if HourStart ~= HourEnd && HourStart == 12 && HourEnd < 6
       [w, x] = find (hour(RawTime) < 6);
       y = w(1);
       FixedTime(y:LengthTime, 1) = RawTime(y:LengthTime) + hours (12);
%        FixedTime(1:y-2, 1) = RawTime(1:y-2);
%        FixedTime(y-1,1) = '13:00:00.0000';
   elseif  HourStart ~= HourEnd && HourStart > 6;
            FixedTime = RawTime;
   elseif  HourStart ~= HourEnd
                FixedTime = RawTime + hours (12);                
   end
Time = FixedTime; 

%HERE IS WHERE THE DOWNSAMPLING OCCURS. If you want to downsample more or
%less, change these values.

Time = downsample(Time,downsample_factor);
RawData = downsample(dataArray{:, 3},downsample_factor);
Photodiode = downsample(dataArray{:, 2},downsample_factor);
spiketimes = floor(find(dataArray{:, 4}>0)./downsample_factor);

%little hack to prevent a bug caused by a zero value in the spiketimes variable, which cant be used as an index.
%This only ever happens on the rare occurance that a spike occurs in the
%first 1ms of the data file. Upon downsampling this time becomes 0, a value that cant be used as an index.
%I simply say if a spike happens between times 0 and 1 ms, I just overwrite it as happening at 1ms. 
%
if spiketimes(1) == 0
    spiketimes(1) = 1;
end

%regenerating the new spike train at the lower sample frequency (prevents
%spikes being deleted, which occurs if you just use the downsample function).

Unit1 = zeros(length(RawData),1);
Unit1(spiketimes) = 1;

savename = A(1).name(1:13);

save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1');

%clear