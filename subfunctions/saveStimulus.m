function fileName = saveStimulus(path, fileName, DataBlock, Units, parameterFile, trial, CustomTag, simplifyForPublication)
%function exportFileName = saveStimulus(DataBlock, parameterFile, trial,
%exportPathName, preName)
%
% saves data block and parameters of a single labChart trial (block) to the
% specified path. Note that a labChart block may contain several flyfly
% trials, since the labchart blocks are cut by the (optional) flyfly
% pauses. Which flyfly trials corresponds to this block is specified by the
% parameter "trial", which is in the format [trial1 trial2 ... trialn].
% (Note that trial1 is not equal to 1.)
%
%

load(parameterFile);

% Correct for differences in capitalisation
if exist('stimulus', 'var')
    Stimulus = stimulus;
    clear stimulus
end

try 
    t = datetime(timeStartPrecision);
catch
    t = datetime(timeStart, 'Format','d-MMM-y HH_mm_ss');
end
fileName = [datestr(t, 'yyyy-mm-dd@hh_MM_ss') '-' fileName];

%loads:
%-Stimulus
%-debugData
%-message
%-skippedInTrial
%-timeFinish
%-timeStart
%-totalSkippedFrames

Experiment_Name = Stimulus.name;

if isempty(CustomTag)
    clear CustomTag;
end
if isempty(Units)
    clear Units;
end

for n = 1:length(Stimulus.layers)
    
   % layer     = debugData.stimulus.layers(n); old version
    layer     = Stimulus.layers(n); %sarah's changes
    
    for k = 1:length(trial)
       % trialData = layer.data(:,trial(k)); old version
        trialData = cell2mat(struct2cell(layer.Param(:,trial(k)))); %sarah's changes

        try
            eval(['Layer_' num2str(n) '_Name = layerName;']);
        catch
            eval(['Layer_' num2str(n) '_Name = Experiment_Name;']);
        end
        
        [R, ~] = size(trialData);
        for r = 1:R
            parName = fieldnames(layer.Param); %sarah's changes
            parName = parName{r}; %sarah's changes
            parName = regexprep(parName, ' ', '_'); %replace space with underscore

            eval(sprintf('Layer_%d_Parameters.%s(%d)=trialData(%d);',n,parName,k,r));
        end
    end
end

% User chooses to save everything loaded (simplifyForPublication == 0)
% or to save only the bare neccesary files needed for publication
if simplifyForPublication == 0
    clear R parName n layer Stimulus r skippedInTrial ...
    trialData timeFinish exportPathName trial preName k;
    save(fullfile(path,fileName));
else
    screenData.monitorHeight = debugData.screenData.monitorHeight;
    screenData.flyDistance = debugData.screenData.flyDistance;
    screenData.partial = debugData.screenData.partial;
    screenData.bgColor = debugData.screenData.bgColor;
    screenData.beforeBgColor = debugData.screenData.beforeBgColor;
    screenData.hz = debugData.screenData.hz;
    screenData.ifi = debugData.screenData.ifi;
    save(fullfile(path,fileName), "DataBlock", "Experiment_Name", "fileName", "Units",...
        "screenData", "timeStart");
    % Iteratively go through and make sure all layer data is in the file
    for n = 1:length(Stimulus.layers)
        eval(['save(fullfile(path, fileName), "Layer_' n ...
            '_Parameters", "Layer_' n '_Name", "-append", "-nocompression")'])
    end
end



