function dataBlock = getDataBlock(fileName, blockNo, channel)

load(fileName);

dataBlock = eval(['data_block' num2str(blockNo) '(' num2str(channel) ',:)']);
% Remove NaN
dataBlock = dataBlock(~isnan(dataBlock)); 