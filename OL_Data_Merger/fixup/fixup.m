contents = {'timeStart', 'timeStartPrecision', 'debugData', 'Stimulus', 'message'};

folder = uigetdir;

list = dir(folder);
for idx = 1:length(list)
    item = list(idx).name;
    if strncmp(item, '.', 1)
        continue;
    end
    if strcmp(item(end-3:end), '.mat')
        load(fullfile(folder,item));
        if exist('debugData', 'var')
            ddstimulus = struct(debugData.stimulus);
            if isfield(ddstimulus, 'hGui')
                if ~isdir(fullfile(folder, 'fixed'))
                    mkdir(folder, 'fixed');
                end;
                fprintf('Fixing up %s...\n', item);
                ddstimulus = rmfield(ddstimulus, 'hGui');   % opens figure and causes Matlab to hang
                debugData.stimulus = ddstimulus;
                save(fullfile(folder,'fixed',item), contents{:});
            end;
        end;
    end;
end
