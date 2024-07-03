A = dir('*.txt');
delimiter = '\t';
formatSpec = '%{HH:mm:ss.SSSS}D%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
Number_Repeats =length(A);
filename= A(1).name;
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);
Date = A(1).name(1:6);
RawTime = dataArray{:, 1};  
HourStart = hour(RawTime(1));
    LengthTime = length(RawTime);
    HourEnd = hour(RawTime(LengthTime));
        if  HourStart == HourEnd & HourStart > 8;
        FixedTime = RawTime;
            else if HourStart == HourEnd;
            FixedTime = RawTime + hours (12);
                end
        end
   if HourStart ~= HourEnd & HourStart == 12
       [w, x] = find (hour(RawTime) < 8);
       y = w(1)
       FixedTime(y:LengthTime, 1) = RawTime(y:LengthTime) + hours (12);
       FixedTime(1:y-2, 1) = RawTime(1:y-2);
       FixedTime(y-1,1) = '13:00:00.0000';
            else if  HourStart ~= HourEnd & HourStart > 8;
            FixedTime = RawTime;
                else if  HourStart ~= HourEnd
                FixedTime = RawTime + hours (12);
                    end
                 end
   end
Time = FixedTime; 
RawData = dataArray{:, 2};
Photodiode = dataArray{:, 3};
Unit1 = dataArray{:, 4}; 
for n = 2:Number_Repeats;
filename= A(n).name;
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);
RawTime = dataArray{:, 1};
    HourStart = hour(RawTime(1));
    LengthTime = length(RawTime);
    HourEnd = hour(RawTime(LengthTime));
        if  HourStart == HourEnd & HourStart > 8;
        FixedTime = RawTime;
            else if HourStart == HourEnd;
            FixedTime = RawTime + hours (12);
                end
        end
   if HourStart ~= HourEnd & HourStart == 12
       [w, x] = find (hour(RawTime) < 8);
       y = w(1)
       FixedTime(y:LengthTime, 1) = RawTime(y:LengthTime) + hours (12);
       FixedTime(1:y-2, 1) = RawTime(1:y-2);
       FixedTime(y-1,1) = '13:00:00.0000';
            else if  HourStart ~= HourEnd & HourStart > 8;
            FixedTime = RawTime;
                else if  HourStart ~= HourEnd
                FixedTime = RawTime + hours (12);
                    end
                 end
   end
dataArraylength=length(dataArray{:, 2})   
Time(end+1:end+dataArraylength) = FixedTime;  
RawData(end+1:end+dataArraylength) = dataArray{:, 2};
Photodiode(end+1:end+dataArraylength) = dataArray{:, 3};
Unit1(end+1:end+dataArraylength) = dataArray{:, 4}; 
end
NotaTime = find(isnat(Time));
for x = 1:length(NotaTime);   
    Time(NotaTime(x))=Time(NotaTime(x)+1)-seconds(0.001);
end
savename = Date;
save (savename, 'Date', 'Photodiode', 'RawData', 'Time', 'Unit1');
clear