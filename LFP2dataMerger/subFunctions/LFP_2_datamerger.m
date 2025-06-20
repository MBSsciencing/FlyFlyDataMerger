% This function handles the majority of converting a TDT file to something 
% We can use in FlyFly data merger
function LFP_2_datamerger(infilename, outfilename, ON_THRESHOLD, UPPER_VALUE_THRESHOLD, ON_DURATION, OFF_DURATION, Photodiode)
    % Init inputs in-case users forget to
    if ~exist('ON_THRESHOLD', 'var') 
        ON_THRESHOLD = [];
    end
    if ~exist('UPPER_VALUE_THRESHOLD', 'var') 
        UPPER_VALUE_THRESHOLD = [];
    end
    if ~exist('ON_DURATION', 'var')
         ON_DURATION = [];
    end
    if ~exist('OFF_DURATION', 'var') 
        OFF_DURATION = [];
    end
    
    % Load our data file
    load(infilename); %#ok<LOAD> We are using a path to load this so we avoid conflicts

    % Figure out what is the timing data of the experiment from the data file
    year=str2double(data.info.date(1:4));
    month=str2double(data.info.blockname(12:13));
    day=str2double(data.info.blockname(14:15));
    hour=str2double(data.info.blockname(17:18));
    minute=str2double(data.info.blockname(19:20));
    second=str2double(data.info.blockname(21:22));

    temp_start_time=strcat(data.info.blockname(17:22));
    
    labStartTime   = [year month day hour minute second];
    labStartDate   = data.info.date;
    labStartTiming = datenum(str2num(data.info.blockname(17:22)));

    num_samples = length(Photodiode);

    RawData = data.streams.RawP.data;
    num_samples2 = size(RawData,2);

    Units = zeros(size(RawData,1), min(num_samples,num_samples2));
    for uid = 1:size(RawData,1)
        Units(uid, :) = RawData(uid,:);
    end
      
    
    SR=data.streams.FilP.fs;
    
    on_off = find_blocks(Photodiode, ON_THRESHOLD, UPPER_VALUE_THRESHOLD, ON_DURATION, OFF_DURATION, true);
  
    package_blocks(on_off, Units, Photodiode, SR, labStartTime, outfilename);
end