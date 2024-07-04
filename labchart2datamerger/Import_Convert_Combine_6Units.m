% Find all text files in the current folder
files = dir('*.txt');

% Set important variables
delimiter = '\t';
formatSpec = '%{HH:mm:ss.SSSS}D%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
Number_Repeats = length(files);
filename= files(1).name;
formatSpec2 = 'Processing %s\n';

% Open the text file and format it as desired
fprintf(formatSpec2, files(1).name);
fileID = fopen(filename,'r');
% Save contents of file into a variable
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

% Find time stamps for the full file
Date = files(1).name(1:6);
RawTime = dataArray{:, 1};  
% Find incorrect times, and guesstimate what they would've been
NotaTime = find(isnat(RawTime));
for x = 1:length(NotaTime)
    RawTime(NotaTime(x)) = RawTime(NotaTime(x) + 1) - seconds(0.0001);
end

HourStart = hour(RawTime(1));
LengthTime = length(RawTime);
HourEnd = hour(RawTime(LengthTime));
    if  HourStart == HourEnd && HourStart > 6
    FixedTime = RawTime;
    elseif HourStart == HourEnd
        FixedTime = RawTime + hours (12);
    end
if HourStart ~= HourEnd && HourStart == 12 && HourEnd < 6
   [w, x] = find (hour(RawTime) < 6);
   y = w(1);
   FixedTime(y:LengthTime, 1) = RawTime(y:LengthTime) + hours (12);
   FixedTime(1:y-1, 1) = RawTime(1:y-1);
elseif  HourStart ~= HourEnd && HourStart > 6
        FixedTime = RawTime;
elseif  HourStart ~= HourEnd
            FixedTime = RawTime + hours (12);                
end
Time = FixedTime; 
RawData = dataArray{:, 2};
Photodiode = dataArray{:, 3};
U1 = isnan (dataArray{:, 4}(1,1));
U2 = isnan (dataArray{:, 5}(1,1));
U3 = isnan (dataArray{:, 6}(1,1));
U4 = isnan (dataArray{:, 7}(1,1));
U5 = isnan (dataArray{:, 8}(1,1));
U6 = isnan (dataArray{:, 9}(1,1));
    if U1 == 0
        Unit1 = dataArray{:, 4}; 
    end
    if U2 == 0
        Unit2 = dataArray{:, 5};
    end
    if U3 == 0
        Unit3 = dataArray{:, 6};
    end
    if U4 == 0
        Unit4 = dataArray{:, 7};
    end
    if U5 == 0
        Unit5 = dataArray{:, 8};
    end
    if U6 == 0
        Unit6 = dataArray{:, 9};
    end
for n = 2:Number_Repeats
    fprintf(formatSpec2, files(n).name);
    filename= files(n).name;
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    clear FixedTime;
    RawTime = dataArray{:, 1};
    NotaTime = find(isnat(RawTime));

    for x = 1:length(NotaTime)
        RawTime(NotaTime(x))=RawTime(NotaTime(x)+1)-seconds(0.0001);
    end

    HourStart = hour(RawTime(1));
    LengthTime = length(RawTime);
    HourEnd = hour(RawTime(LengthTime));
    FixedTime = RawTime;
    
    dataArraylength=length(dataArray{:, 2});  
    Time(end+1:end+dataArraylength) = FixedTime;  
    RawData(end+1:end+dataArraylength) = dataArray{:, 2};
    Photodiode(end+1:end+dataArraylength) = dataArray{:, 3};

    if U1 == 0
        Unit1(end+1:end+dataArraylength) = dataArray{:, 4}; 
    end
    if U2 == 0
        Unit2(end+1:end+dataArraylength) = dataArray{:, 5};
    end
    if U3 == 0
        Unit3(end+1:end+dataArraylength) = dataArray{:, 6};
    end
    if U4 == 0
        Unit4(end+1:end+dataArraylength) = dataArray{:, 7};
    end
    if U5 == 0
        Unit5(end+1:end+dataArraylength) = dataArray{:, 8};
    end
    if U6 == 0
        Unit6(end+1:end+dataArraylength) = dataArray{:, 9};
    end
end

savename = files(1).name(1:13);
if U1 == 1
    save (savename, 'Date', 'Photodiode', 'RawData', 'Time');
elseif U2 == 1
    save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1');
elseif U3 == 1
    save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1', 'Unit2');
elseif U4 == 1
    save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1', 'Unit2', 'Unit3');
elseif U5 == 1
    save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1', 'Unit2', 'Unit3', 'Unit4')
elseif U6 == 1
    save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1', 'Unit2', 'Unit3', 'Unit4', 'Unit5');
else
    save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1', 'Unit2', 'Unit3', 'Unit4', 'Unit5', 'Unit6');
end

clear