function plot_all(data)

MinFlex = min([data.flexion])
MaxFlex = max([data.flexion])



%% PlotsFMed
% 
% 
figure
subplot(3, 1, 1)
plot([data.flexion])
ylabel('Flexion')
subplot(3, 1, 2)
plot([data.varus])
ylabel('Tibial Varus')
subplot(3, 1, 3)
plot([data.external])
ylabel('Tibial Ext Rotation')
sgtitle('Tibia angles relative to femur')

figure
subplot(3, 1, 1)
plot([data.lateral])
ylabel('Lateral/medial')
subplot(3, 1, 2)
plot([data.anterior])
ylabel('Anterior/posterior')
subplot(3, 1, 3)
plot([data.superior])
ylabel('DistComp')
sgtitle('Tibia translations relative to femur')
% 
% % Write output files
% OutputPath = [pwd,'\',char(Knee), '\OutputFiles\' Test '.csv'];
% Output = [TFangles TFtranslations];
% % Output = fillmissing(Output,'spline');
% % csvwrite(OutputPath, Output);
% 
end