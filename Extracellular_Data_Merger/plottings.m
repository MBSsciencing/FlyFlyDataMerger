%plottings

sorted = sort(timeStringParameters);
%sorted = sorted(19:end);

plot(sorted);
hold on;
plot(timeStringData, 'r')