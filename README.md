Why fork? 
Recent fixes to LFP2datamerger broke labchart2datamerger. 

For extracellular/intracellular data merge using labchart2datamerger - Current version of labchart2datamerger won't work. 
TLDR: Easy fix is to download this fork - & delete file LFP2datamerger before use: At least 1 subfunction of LFP2datamerger has the same name as subfunctions used in labchart2datamerger – subsequent conflicts cause code to break. (package_blocks.m) - is used by both, different code for both. 
There might be more cases of this I’m not sure. 

Update: 
Import_Convert_Combine_6Units.m
Has had the way files are saved changed to be correct: fixing naming convention and how data is organised in array (col converted to row) so it loads properly into flyflydatamerger. 
