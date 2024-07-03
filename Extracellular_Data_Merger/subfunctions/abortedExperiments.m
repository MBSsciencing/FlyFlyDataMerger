function [fileNames] = abortedExperiments(directoryPath)
%
% Aquire a list of all aborted experiments in directory
%

if nargin < 2
    date = 'All';    
end

fileList = dir(directoryPath); %list of all files in folder "directory"

k = 1;
fileNames = {};
for n = 3:length(fileList) %first two files are "." and "..", ignore them
    
    loadedFile = [directoryPath fileList(n).name];
    load(loadedFile);
    
    if strcmp(message, 'NOTE: THIS RUN WAS ABORTED') %message aborted        
        fileNames{k} = loadedFile;        
        k = k+1;
    end
end

fileNames = fileNames';