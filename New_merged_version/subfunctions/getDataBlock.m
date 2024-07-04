function dataBlock = getDataBlock(fileName, blockNo, channel)

load(fileName);

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

dataBlock = eval(['data_block' num2str(blockNo) '(' num2str(channel) ',:)']);
    

%for frankfrank
%dataBlock = eval(['data_block' num2str(blockNo,'%04.0f') '(' num2str(channel) ',:)']);
dataBlock = dataBlock(~isnan(dataBlock)); %remove NaN