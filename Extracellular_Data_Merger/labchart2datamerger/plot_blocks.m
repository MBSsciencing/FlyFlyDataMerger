function plot_blocks(Photodiode, on_off)
 
    maxY = 4e-3;
    maxY = max(Photodiode);
    NUM_BLOCKS_PER_FIGURE = 10;
    MARGIN = 1000;
    yy = [0 maxY];
    num_figures = ceil(size(on_off,1) / NUM_BLOCKS_PER_FIGURE);

    for f_id = 1:num_figures
        start_block = (f_id-1)*NUM_BLOCKS_PER_FIGURE+1;
        end_block = min(f_id*NUM_BLOCKS_PER_FIGURE, size(on_off,1));
        figure('NumberTitle', 'on', 'Name', sprintf('Blocks %d to %d', start_block, end_block));
        hold on;

        range = max(1,on_off(start_block, 1)-MARGIN):min(length(Photodiode), on_off(end_block, 2)+MARGIN);
        for b_idx = start_block:end_block
            s = on_off(b_idx, 1);
            e = on_off(b_idx, 2);
            w = e-s;       

            v = [s yy(1) w yy(2)-yy(1)];
            rectangle('Position', v, 'FaceColor', [1 0.9 0.9], 'EdgeColor', 'none');
        end;   
        plot(range, Photodiode(range));
        ylim(yy);
    end;
end