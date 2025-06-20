function [dataBlock, cellName] = getDataBlock(fileName, blockNo, channel) %#ok<INUSD> Used in an eval statement, so is ok 

warning off % Turn off warnings while we check our data scheme
eval(['load(fileName, "data_block' num2str(blockNo) '");']);
eval(['load(fileName, "Data_Block_' num2str(blockNo) '");']);
warning on

% Test which form of data block spelling we need
if exist(['data_block' num2str(blockNo)], 'var')
    cellName = 'data_block';
elseif exist(['Data_Block_' num2str(blockNo)], 'var')
    cellName = 'Data_Block_';
end

%for sampsamp
% if blockNo<10,
%     
%     
%     dataBlock = eval(['data_block000' num2str(blockNo) '(' num2str(channel) ',:)']);
%     
% elseif blockNo<100,
%     
%     dataBlock = eval(['data_block00' num2str(blockNo) '(' num2str(channel) ',:)']);
%     
% elseif blockNo<1000,
%     
%     dataBlock = eval(['data_block0' num2str(blockNo) '(' num2str(channel) ',:)']);
% 
% else
%         
%     dataBlock = eval(['data_block' num2str(blockNo) '(' num2str(channel) ',:)']);
%     
% end

% Testing if there are sting header cells used
cellTest = eval(['iscell(' cellName num2str(blockNo) ');']);

% Shouldn't need to check for if is cell or not, but good to stay safe
if cellTest
    stringTest = eval(['isstring(' cellName num2str(blockNo) '{1,1});']);
else
    stringTest = eval(['isstring(' cellName num2str(blockNo) '(1,1));']);
end
if stringTest
    channel = channel + 1;
end

dataBlock = eval([cellName num2str(blockNo) '(:, ' num2str(channel) ')']);
    
% Data can come from a lot of different places, so force it into a
% particular format first to prevent errors
if iscell(dataBlock)
    dataBlock = cell2mat(dataBlock);
end

%for frankfrank
%dataBlock = eval(['data_block' num2str(blockNo,'%04.0f') '(' num2str(channel) ',:)']);
dataBlock = dataBlock(~isnan(dataBlock)); %remove NaN