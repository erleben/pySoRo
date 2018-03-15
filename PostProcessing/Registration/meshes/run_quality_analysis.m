% Copyright 2011, Kenny Erleben
clear all;
close all;
clc;

meshes = {
  'bar_T1098_V300.mat',...
  'bar_T1197_V325.mat',...
  'bar_T2293_V576.mat',...
  'bar_T7737_V1701.mat',...
  'bar_T8150_V1782.mat',...
  'bar_T11741_V2500.mat',...
  'bar_T20423_V4176.mat',...
  'bar_T27977_V5577.mat'...
  };

for m=1:length(meshes)
  
  load( meshes{m} );
  [ Qrr, Qrl, Qtheta, Qvl ] = compute_quality_measures(T, X, Y, Z);
  fh = figure(1);
  clf;
  set(gca,'FontSize',18);
  hist(Qrr, 40);
  ylabel('value','FontSize',18);
  xlabel('Q_{rr}','FontSize',18);
  filename = strcat( 'Qrr_m', num2str(m));
  print(fh, '-depsc2', filename);
  
  fh = figure(2);
  clf;
  set(gca,'FontSize',18);
  hist(Qrl, 40);
  ylabel('value','FontSize',18);
  xlabel('Q_{rl}','FontSize',18);
  filename = strcat( 'Qrl_m', num2str(m));
  print(fh, '-depsc2', filename);
  
  fh = figure(3);
  clf;
  set(gca,'FontSize',18);
  hist(Qtheta, 40);
  ylabel('value','FontSize',18);
  xlabel('Q_{\theta}','FontSize',18);
  filename = strcat( 'Qtheta_m', num2str(m));
  print(fh, '-depsc2', filename);
  
  fh = figure(4);
  clf;
  set(gca,'FontSize',18);
  hist(Qvl, 40);
  ylabel('value','FontSize',18);
  xlabel('Q_{vl}','FontSize',18);
  filename = strcat( 'Qvl_m', num2str(m));
  print(fh, '-depsc2', filename);
  
end
