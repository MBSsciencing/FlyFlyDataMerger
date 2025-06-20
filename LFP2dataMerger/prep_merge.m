
clear
filePath = uigetdir('/home/', 'Choose folder containing your converted TDT .mat files');
savePath = uigetdir('/home/', 'Choose folder to save your prep_merged files to');

filelist = dir(fullfile(filePath, '*.mat'));
filenames = {filelist.name};
nfiles = length(filenames);
indata = cell(nfiles,1);

for i=1:nfiles
    load([filePath '/' filenames{i}]);
    infilename  = [filePath '/' filenames{i}];
    outfilename = [savePath '/' strcat(filenames{i}(10:22),'_N01_prep_merged')];
    
    photodiode = (data.streams.Phoe.data);
    photodiode = double(photodiode);
    figure(1),clf
    plot(photodiode,'k')
    hold on
    [b,a] = butter(2,.005,'low');
    Photodiode=filtfilt(b,a,photodiode);
    plot(Photodiode,'r')
     title(strcat('Block number ', num2str(i)))
    
    ON_THRESHOLD = min(Photodiode)+1.5;
    UPPER_VALUE_THRESHOLD = max(Photodiode)+1;
    ON_DURATION = 1000;
    OFF_DURATION = 100;
%     on_off = find_blocks(Photodiode, ON_THRESHOLD, UPPER_VALUE_THRESHOLD, ON_DURATION, OFF_DURATION, true);
       
    LFP_2_datamerger(infilename, outfilename, ON_THRESHOLD, UPPER_VALUE_THRESHOLD, ON_DURATION, OFF_DURATION, Photodiode)
    
    disp(i)
    disp('Done')
    
    pause(1)
    close all
       
end

