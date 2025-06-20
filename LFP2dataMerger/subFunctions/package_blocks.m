function package_blocks(on_off, Units, Photodiode, SR, labStartTime, outfilename)
%     magic_number = make_magic_number(labStartTime);
    w = {};
    dsec = duration(0, 0, 1); % 1 second
    lst = datetime(labStartTime);
    magic_number = make_magic_number(lst);
    
    for b_id = 1:size(on_off,1)
        dvarname = sprintf('data_block%d', b_id);
        ttvarname = sprintf('ticktimes_block%d', b_id);
        uvarname = sprintf('unit_block%d', b_id);
        if b_id == 239
            stophere = true;
        end
        s = on_off(b_id, 1);
        e = on_off(b_id, 2);
        dblock = [Photodiode(s:e)'; Units(s:e)'];
        
        offset=s/SR;
        ttblock = make_magic_number2(lst, offset); 

                
        eval([dvarname ' = dblock;']);
        eval([ttvarname ' = ttblock;']);
        w{end + 1} = dvarname;
        w{end + 1} = ttvarname;
        if ~isempty(Units)
            ublock = Units(:, s:e);
            eval([uvarname ' = ublock;']);
            w{end + 1} = uvarname;
        end
    end

    info = '---- Data from RL script ---';
    w{end+1} = 'info';
    save(outfilename, w{:});
end

function magic_number = make_magic_number(timeStartPrecision)
    dd = datenum(timeStartPrecision);
    dnOffset = datenum('01-Jan-1970');
    days_diff = datenum(dd) - dnOffset; % datenum gives you days (since Day Zero)    
    
    magic_number = 24*60*60*days_diff;
end

function magic_number2 = make_magic_number2(timeStartPrecision, offset)
    t2 = addtodate(datenum(timeStartPrecision),round(offset),'second');
    %     t2 = datetime(timeStartPrecision) + offset;
    dd = datenum(t2);
    dnOffset = datenum('01-Jan-1970');
    days_diff = datenum(dd) - dnOffset; % datenum gives you days (since Day Zero)    
    
    magic_number2 = 24*60*60*days_diff;
end