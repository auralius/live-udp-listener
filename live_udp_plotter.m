function live_udp_plotter()

% Listens to a UDP port and plot the data
% Data must be packed and sent in arrays of double
%
% port         : port number to listen
% buffer_size  : number of data points to plot
% n_channel    : number of data channels
% interval     : waiting time before getting the nex data point 
%
% Auralius Manurung
% 04.08.2016

close all;
clc;

% =========================================================================

prompt = {'Port:', 'Buffer size:', 'Number of channels:', 'Interval (s):'};
dlg_title = 'live_udp_plotter';
num_lines = 1;
defaultans = {'12345','100', '2', '0.3'};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer)
    fprintf('cancelled...\nbye...')
    return;
end

port = str2double(answer{1});
buffer_size = str2double(answer{2});
n_channel = str2double(answer{3});
interval = str2double(answer{4});

colors = {'y', 'm', 'c', 'r', 'g', 'b', 'w', 'k'};

h = figure;

set(h, 'KeyPressFcn', @myKeyPressFcn)
hudpr = dsp.UDPReceiver('LocalIPPort', port, 'MessageDataType', 'double');
buffer = zeros(buffer_size, n_channel);

hold on;
s = '';
for i = 1 : n_channel
    hp(i) = plot(0,0);
    set(hp(i), 'XData', 0:1:buffer_size-1 , 'YData', zeros(1, buffer_size));
    set(hp(i), 'Color', colors{mod(i, 10)}); % Cycle through the 9 colors
    s{i} = strcat('ch-', int2str(i)); 
end

legend(s);
xlim([0 buffer_size-1]);

QUIT = 0;
while ~QUIT
    dataReceived = step(hudpr);
    bytesReceived = length(dataReceived);
    if bytesReceived >= n_channel
        buffer(2:end, :) = buffer(1:end-1, :);
        buffer(1, 1:n_channel) = dataReceived(1:n_channel);
    end
    pause(interval);
    
    for i = 1 : n_channel
        set(hp(i), 'YData', buffer(:,i) );
    end
    drawnow;
end

close(h);
release(hudpr);

% =========================================================================
    function myKeyPressFcn(hObject, event)
        switch event.Key
            case 'q'
                QUIT  = 1;
                disp('bye...');
            otherwise
        end
    end
% =========================================================================

end
