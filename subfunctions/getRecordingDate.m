function date = getRecordingDate(fileName)

warning off % Temporarily turn off warnings so we can check our data name scheme
load(fileName, "ticktimes_block1")
load(fileName, "Ticktime_Block_1")
if exist('ticktimes_block1', 'var')
    date = char(datetime(ticktimes_block1, 'convertfrom', 'posixtime', 'Format', 'dd-MMM-uuuu'));
elseif exist('Ticktime_Block_1', 'var')
    date = char(datetime(Ticktime_Block_1, 'convertfrom', 'posixtime', 'Format', 'dd-MMM-uuuu'));
end
warning on

date = date(1:11);