%% Batch_MesCol_Analysis.m
% 
% spec: spectral data
%       lambda 380:780 nm
%       size: N x 404 = RGB(3 elem) + data(401 elem)
%       R, G, B, t380, t381, ..., t779, t780
% 
% prop: property data
%       size: N x 14 = RGB(3 elem) + data(11 elem)
%         1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11
%        Le,  Lv,   X,   Y,   Z,   x,   y,  u',  v',   T, Duv

filepath = 'C:\Users\cogni\Desktop\MesCol\DataM';
datename = '';

spec = dlmread(fullfile(filepath, sprintf('MesColSpec_%s.csv', datename)));
prop = dlmread(fullfile(filepath, sprintf('MesColProp_%s.csv', datename)));

data.R.condi = prop(:, 2) == 0 & prop(:, 3) == 0;
data.G.condi = prop(:, 1) == 0 & prop(:, 3) == 0;
data.B.condi = prop(:, 1) == 0 & prop(:, 2) == 0;
data.W.condi = prop(:, 1) == prop(:, 2) & prop(:, 2) == prop(:, 3);

data.R.chans = 1;
data.G.chans = 2;
data.B.chans = 3;
data.W.chans = 2;


data.R.MarkerFaceColor = 'r';
data.G.MarkerFaceColor = 'g';
data.B.MarkerFaceColor = 'b';
data.W.MarkerFaceColor = 'k';


for col = ["R", "G", "B", "W"]
  index = find(data.(col).condi);
  digit = prop(index, data.(col).chans);
  data.(col).index = feval(@(A, I) A(I), index, argsort(digit));
  data.(col).digit = prop(data.(col).index, data.(col).chans);
  data.(col).spec = spec(data.(col).index, 4:end);
  data.(col).prop = prop(data.(col).index, 4:end);
  data.(col).Lv = data.(col).prop(:, 2);
  data.(col).X = data.(col).prop(:, 3);
  data.(col).Y = data.(col).prop(:, 4);
  data.(col).Z = data.(col).prop(:, 5);
  data.(col).x = data.(col).prop(:, 6);
  data.(col).y = data.(col).prop(:, 7);
end

%%
figure(1);
clf
set(gcf, 'WindowStyle', 'docked');
set(gca, 'NextPlot', 'add');

figure(2);
clf
set(gcf, 'WindowStyle', 'docked');
set(gca, 'NextPlot', 'add');


for col = ["R", "G", "B", "W"]
%   ind = feval(@(x, y) x(8<y), 1:length(data.(col).digit), data.(col).prop(:, 2));
  ind = 1:65;
  fprintf('%s : %2d [%3d(%3d) - %3d(%3d)]\n', col, numel(ind), min(data.(col).digit(ind)), min(ind), max(data.(col).digit(ind)), max(ind));
  
  figure(1);
  scatter3(data.(col).x(ind), data.(col).y(ind), data.(col).Y, [], 'MarkerEdgeColor', 'none', 'MarkerFaceColor', data.(col).MarkerFaceColor );
  
  figure(2);
  scatter(data.(col).digit(ind), data.(col).Lv(ind), [], 'MarkerEdgeColor', 'none', 'MarkerFaceColor', data.(col).MarkerFaceColor );

end

%%
ind = 1:65;

dig = data.W.digit(ind)./255;
lum = data.W.prop(ind, 2);

fitfunc = @(d, g, Ydata) range(Ydata).*(d.^g) + min(Ydata);
sse = @(g) sum( (lum - fitfunc(dig, g, lum)).^2 );
gam = fminsearch(sse, 2);

revfunc = @(Y, g, Ydata) ( (Y - min(Ydata))./range(Ydata) ).^(1/g);

figure(3);
clf
plot(dig, lum);
hold on
plot(dig, fitfunc(dig, gam, lum))


%%
xR = data.R.x(end);
yR = data.R.y(end);
zR = 1 - xR - yR;

xG = data.G.x(end);
yG = data.G.y(end);
zG = 1 - xG - yG;

xB = data.B.x(end);
yB = data.B.y(end);
zB = 1 - xB - yB;

CONV = [
  xR/yR, xG/yG, xB/yB;
    1.0,   1.0,   1.0;
  zR/yR, zG/yG, zB/yB;
  ];

INVC = inv(CONV);














