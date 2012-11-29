%
function plotProbPCA(data, component_count, flat)
[obs_count channel_count] = size(data);
%{
ppca = compute_mapping(m, 'ProbPCA', c);
pc_sensor_weights = zscore(ppca' * m);
n = 0;
for comp = pc_sensor_weights'
  n = n + 1;
  figure
  sensorDistributionFlat(ppca(:,n), flat, comp, jet(128), ['ProbPCA component ' num2str(n)]);
end
%}
n = 0;
[lambda,veig,scores]=robpca(data,component_count,'mad');
for rc = veig
  n = n + 1;
  figure
  sensorDistributionFlat(scores(:,n), flat, rc, jet(128), ['Robust PCA component ' num2str(n)]);  
end
size(scores)
R = cubica34(scores');
size(R)
% u is TIMExCOMPONENTS m is TIMExSENSORS
u = scores*R';
% ic_sensor_weights is COMPONENTSxSENSORS
ic_sensor_weights = u'*data;
size(ic_sensor_weights)
n = 0;
for comp = ic_sensor_weights'
  n = n + 1;
  figure
  sensorDistributionFlat(u(:,n), flat, comp, jet(128), ['Robust PCA followed by ICA component ' num2str(n)])
end

% icompdata is TIMExSENSORSxCOMPONENTS
ic_data = nan(obs_count, channel_count, component_count);
for n = 1:component_count
  ic_data(:,:,n) = u(:,n)*ic_sensor_weights(n,:);
end

save('ic_robpca_data', 'ic_data', 'ic_sensor_weights', 'u', 'data', 'component_count')

%{
n = 0;
mgplvm = compute_mapping(m, 'GPLVM', c);
pc_sensor_weights = zscore(mgplvm' * m);
for comp = pc_sensor_weights'
  n = n + 1;
  figure
  sensorDistributionFlat(mgplvm(:,n), flat, comp, jet(128), ['GPLVM component ' num2str(n)]);
end
%}
end

function sensorDistributionFlat(timeSeries, sensorXY, sensorWeights, sensorColorMap, plotTitle)
  % the sensor coordinates have the front of the head on the right
  % and the left side of the head at the top, looking down on the top of
  % the head
  % rotate the sensor coordinates 90 degrees counterclockwise
  % to get the front of the head at the top of the plot and the left and
  % right sides of the head on the left and right sides, respectively, of
  % the plot
  subplot(4,1,1)
  plot(timeSeries)
  title(plotTitle);
  subplot(4,1,2:4)
  sensorXY(:, 2) = -1 * sensorXY(:, 2);
  xline = linspace(min(sensorXY(:,2)),max(sensorXY(:,2)),1000);
  yline = linspace(min(sensorXY(:,1)),max(sensorXY(:,1)),1000);
  [gridX,gridY] = meshgrid(xline,yline);
  %gridZ = griddata(sensorXY(:,2), sensorXY(:,1), sensorColors, gridX, gridY);
  interpZ = TriScatteredInterp(sensorXY(:,2), sensorXY(:,1), sensorWeights, 'natural');
  gridZ = interpZ(gridX, gridY);

  colormap(sensorColorMap);

  contourf(gridX, gridY, gridZ);
  axis off
  colorbar
  %%set(gca(), 'CLim', [1 128])
  %text(sensorXY(:, 2), sensorXY(:,1), num2str((1:248)'), 'FontSize', 5, 'HorizontalAlignment', 'center');
  % create a 'scale bar' using the actual data
  %%dataScaleBar = linspace(sensorDataMin, sensorDataMax, 128);
  %%hcb = colorbar();
  %%colorBarTicks = (0:16:128);
  %%colorBarTicks(1) = 1;
  %%set(hcb, 'YTick', colorBarTicks);
  %%set(hcb, 'YTickLabel', sprintf('%5.3f|', dataScaleBar(colorBarTicks))); % was dataScaleBar(colorIndices)
  %%set(hcb,'YTickMode','manual')

end
