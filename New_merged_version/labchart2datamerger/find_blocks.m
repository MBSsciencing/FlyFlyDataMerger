function on_off = find_blocks(Photodiode, ON_THRESHOLD, UPPER_VALUE_THRESHOLD, ON_DURATION, OFF_DURATION, view)
    if ~exist('ON_THRESHOLD', 'var') || isempty(ON_THRESHOLD)
        ON_THRESHOLD = 1.5e-3;
    end
    if ~exist('UPPER_VALUE_THRESHOLD', 'var') || isempty(UPPER_VALUE_THRESHOLD)
        UPPER_VALUE_THRESHOLD = 9e-3;
    end
    if ~exist('ON_DURATION', 'var') || isempty(ON_DURATION)
         ON_DURATION = 20;
    end
    if ~exist('OFF_DURATION', 'var') || isempty(OFF_DURATION)
        OFF_DURATION = 20;
    end
    if ~exist('view', 'var') || isempty(view)
        view = true;
    end
    disp('Finding candidate blocks...');
    on_off = [];
    k = length(Photodiode);
    while k >=1
        e = find(Photodiode(1:k) >= ON_THRESHOLD, 1, 'last');
        s = find(Photodiode(1:e-1) < ON_THRESHOLD, 1, 'last');
        if ~isempty(e) && ~isempty(s)
            if all(Photodiode(s:e) < UPPER_VALUE_THRESHOLD) %&& all(Photodiode(s:e) > LOWER_VALUE_THRESHOLD) 
                on_off = [s+1 e; on_off];
                if mod(size(on_off,1), 100) == 0
                    fprintf('Number of candidate blocks is %d\n', size(on_off,1));
                end
            end
            k = s;
        else
            k = -1;
        end
    end
    
figure(2);clf
plot(Photodiode)
hold on
plot([on_off(:,1) on_off(:,1)]',[ON_THRESHOLD ON_THRESHOLD]', 'marker','o', 'markersize', 6, 'linestyle', 'none', 'color', 'r')
hold on
plot([on_off(:,2) on_off(:,2)]',[ON_THRESHOLD ON_THRESHOLD]', 'marker','o', 'markersize', 6, 'linestyle', 'none', 'color', 'k')
hold on

    disp('Marking dodgy blocks...');
    deletes = false(1,size(on_off,1));
    deletegaps = false(1,size(on_off,1));    
    for b_id = 1:size(on_off,1)-1
        s = on_off(b_id, 1);
        e = on_off(b_id, 2);
        s2 = on_off(b_id+1,1);
        lngth = e-s;
        gap = s2-e;
        
        if lngth < ON_DURATION
           deletes(b_id) = true; 
        end
        if gap < OFF_DURATION
           deletegaps(b_id) = true; 
        end
    end
    
    disp('Reconstructing blocks...');
    new_oo = [];
    s = -1;
    for b_id = 1:size(on_off,1)
        % NOTE: we are implicitly letting deletegaps override deletes if
        % both are true, i.e. we delete the gaps and keep the data.
        % We write out a new block whenever deletegaps is false.
        if deletegaps(b_id) || ~deletes(b_id)
            if s == -1
                s = on_off(b_id,1);
            end
            e = on_off(b_id,2);
        end
        if ~deletegaps(b_id) && s~= -1
            new_oo = [new_oo; s e];
            s = -1;
        end
    end
    on_off = new_oo;
    
    if view
        plot_blocks(Photodiode, on_off);
    end
end

figure(2);
x0=400;
y0=400;
width=1000;
height=500;
set(gcf,'position',[x0,y0,width,height])
plot([new_oo(:,1) new_oo(:,1)]',[ON_THRESHOLD ON_THRESHOLD]', 'marker','.', 'markersize', 6, 'linestyle', 'none', 'color', 'r')
hold on
plot([new_oo(:,2) new_oo(:,2)]',[ON_THRESHOLD ON_THRESHOLD]', 'marker','.', 'markersize', 6, 'linestyle', 'none', 'color', 'k')
hold on
