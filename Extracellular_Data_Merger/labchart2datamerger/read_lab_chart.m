function [DateTime, RawData, Photodiode, Units]=read_lab_chart(filename)
    % get information about file structure
    fprintf('Scanning %s to check file structure....', filename);
    fileID = fopen(filename);
    line = fgetl(fileID);
    numfields = length(find(line == 9))-1; % 9 = TAB character
    
    count = 0;
    %{
    while ischar(line)
        count = count + 1;
        line = fgetl(fileID);
    end;
    RawData = zeros(1, count);
    Photodiode = zeros(1, count);
    Units = zeros(numfields, count);
    %}
    fprintf('%d lines\n', count);
    
    fclose(fileID);
    
    % Now read in properly
    fprintf('Reading data from %s....', filename);
    format = '%{HH:mm:ss.SSSS}D';
    for x=1:numfields
        format = strcat(format, '%f');
    end;

    count = 0;
    fileID = fopen(filename);
    
    %{
    line = fgetl(fileID);
    while ischar(line)
        try
            count = count + 1;
            C=strsplit(line, '\t');
            RawData(count) = str2num(C{2});
            Photodiode(count) = str2num(C{3});
            for x=1:numfields-2
                Units(x, count) = str2num(C{3+x});
            end;
            line = fgetl(fileID);
        catch ex
            disp(ex);
            fprintf('ERROR IN LINE %d: %s\n', count, line);
        end;
    end;
    %}
    
    D = textscan(fileID, format, 'Delimiter', '\t', 'EmptyValue' ,NaN, 'ReturnOnError', false);
    
    fclose(fileID);
    fprintf('done\n');
   
    DateTime = D{1};
    RawData = D{2};
    Photodiode = D{3};
    Units = horzcat(D{4:end})';
    
end