% This script takes prioprietary Tucker Davis data files and covnerts them 
% into a form that Matlab can use! This script is intended to be used 
% using either Linux or MacOS :)

% To run this script you need TDT's own toolbox to import their data into 
% Matlab. It can be downloaded from their git page here:
% https://github.com/tdtneuro/TDTMatlabSDK

clear

% If you don't have the toolbox already on your path, write it below and uncomment these lines:
% SDKPATH = 'C:\toolbox\TDTMatlabSDK\TDTSDK\';
% addpath(genpath(SDKPATH));

% Grab the folder location of your data to import
data_folder = uigetdir('/home/', 'Select your folder containing Tucker Davis data');
save_folder = uigetdir('/home/', 'Where would you like to save your .mat files to?');
desired_date=('*210303*');

% Check if user has the files we want!
files=dir([data_folder '/' desired_date]);
num_files=length(files);
if num_files == 0
    warning('No data folders found, exiting!')
    return
end

% Loop through all TD files
for i=1:num_files
    % Import into Matlab
    data=TDTbin2mat([data_folder '/' files(i).name]);
    filename=(files(i).name);
    saveName = strcat(filename,'.mat');
    % Save your TD data into a .mat file
    save([save_folder '/' saveName],'data');
end
