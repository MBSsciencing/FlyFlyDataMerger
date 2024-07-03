

function labchart2datamerger(infilename, outfilename, ON_THRESHOLD, UPPER_VALUE_THRESHOLD, ON_DURATION, OFF_DURATION)
    if ~exist('ON_THRESHOLD', 'var') 
        ON_THRESHOLD = [];
    end;
    if ~exist('UPPER_VALUE_THRESHOLD', 'var') 
        UPPER_VALUE_THRESHOLD = [];
    end;
    if ~exist('ON_DURATION', 'var')
         ON_DURATION = [];
    end;
    if ~exist('OFF_DURATION', 'var') 
        OFF_DURATION = [];
    end;
    
    load(infilename);
    t1 = Time(1)
    
    %[Time, RawData, Photodiode, Units] = read_lab_chart(infilename);

    %{
    num_samples = length(Photodiode);
    
    t2 = Time(num_samples);
    t1sec = 3600*t1.Hour + 60*t1.Minute + t1.Second;
    t2sec = 3600*t2.Hour + 60*t2.Minute + t2.Second;
    timediff = t2sec-t1sec;
    SR = round((num_samples - 1)/timediff);
    %}
    
    dsec = duration(0, 0, 1);   % 1 second
    SR = round((Time(2)-Time(1))/dsec);
    
    year = str2num(Date(1:2)) + 2000;
    month = str2num(Date(3:4));
    day = str2num(Date(5:6));
    %labStartTime = [recordingDate t1.Hour t1.Minute t1.Second];
    labStartTime = [year month day t1.Hour t1.Minute t1.Second];
     
    unames = who('Unit*');
    Units = zeros(length(unames), length(Photodiode));
    for uid = 1:length(unames)
        uname = unames{uid};
        Units(uid, :) = eval(uname);
    end
      
    on_off = find_blocks(Photodiode, ON_THRESHOLD, UPPER_VALUE_THRESHOLD, ON_DURATION, OFF_DURATION, false);

    package_blocks(on_off, RawData, Photodiode, Time, Units, SR, labStartTime, outfilename);

end