%% Batch_MesCal_Measure.m


%% Initialize MesCol object
mesCol = MesCol('COM1', 9600);
mesCol.SetRemoteOn();
mesCol.SetMesMode(1, 60.00);
mesStatus = mesCol.GetMesStatus();


%% Set drawing parameters
LIN = (17:17:255)';
ZER = zeros(size(LIN));

ColK = [000, 000, 000];
KtoR = [LIN, ZER, ZER];
KtoG = [ZER, LIN, ZER];
KtoB = [ZER, ZER, LIN];
KtoW = [LIN, LIN, LIN];

ColorMap = [ColK; KtoR; KtoG; KtoB; KtoW];
NofColor = size(ColorMap, 1);


%% Initialize drawing system
% Write initialize script below




% Write initialize script above


%% Measurement
filepath = 'C:\Users\cogni\Desktop\MesCol\DataM';
datename = datestr(now,'yymmddTHHMMSS');

specFileName = fullfile(filepath, sprintf('MesColSpec_%s.csv', datename));
specFile = fopen(specFileName, 'w');
fclose(specFile);

propFileName = fullfile(filepath, sprintf('MesColProp_%s.csv', datename));
propFile = fopen(propFileName, 'w');
fclose(propFile);

NofTrial = 1;
tic;
cnt = 0;
fprintf('# MesCol      : %d (%d x %d)\n', NofColor*NofTrial, NofColor, NofTrial);
for ti = 1:NofTrial
  IdxColor = randperm(NofColor);
  for ci =  IdxColor
    cnt = cnt + 1;
    % Write draw script below
    
    
    
    
    % Write draw script above
    
    mesCol.StartMes();
    
    colSpec = mesCol.GetColSpec(0);
    specFile = fopen(specFileName, 'a');
    fprintf(specFile, '%3d, %3d, %3d', ColorMap(ci, :));
    fprintf(specFile, ', %E', colSpec);
    fprintf(specFile, '\n');
    fclose(specFile);
    
    colProp = mesCol.GetColProp(0);
    propFile = fopen(propFileName, 'a');
    fprintf(propFile, '%3d, %3d, %3d', ColorMap(ci, :));
    fprintf(propFile, ', %f', [colProp{:}]);
    fprintf(specFile, '\n');
    fclose(propFile);
    
    fprintf('# M %8d  : %8.0f min, [%3d, %3d, %3d] -> Lv: %8.3f, x: %6.4f, y: %6.4f\n', cnt, toc/60, ColorMap(ci, :), colProp{2}, colProp{6}, colProp{7});
  end
end



%% Finalize drawing system
% Write finalize script below




% Write finalize script above

fprintf('# MesCol      : %d (%d x %d), %8.0f min\n', NofColor*NofTrial, NofColor, NofTrial, toc/60);
