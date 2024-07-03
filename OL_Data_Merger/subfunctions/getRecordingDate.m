function date = getRecordingDate(fileName)

load(fileName);

%make an array with the starting times of all blocks
fileName = ['ticktimes_block1(1,1)'];
x = eval(fileName);


% offset (serial date number for 1/1/1970)
dnOffset = datenum('01-Jan-1970');

dnNow = x/(24*60*60) + dnOffset;

date = datestr(dnNow);
date = date(1:11);