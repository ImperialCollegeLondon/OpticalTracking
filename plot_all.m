function plot_all(input)
figure

subplot(3, 2, 1);
plot(input.data.flexion);
ylabel('Flexion');
title('Angles');

subplot(3, 2, 3);
plot(input.data.varus);
ylabel('Tibial Varus');

subplot(3, 2, 5);
plot(input.data.external);
ylabel('Tibial Ext Rotation');

subplot(3, 2, 2);
plot(input.data.lateral);
ylabel('Lateral/medial');
title('Translations');

subplot(3, 2, 4);
plot(input.data.anterior);
ylabel('Anterior/posterior');

subplot(3, 2, 6);
plot(input.data.superior);
ylabel('DistComp');

name = strrep(input.name, '_', ' ');
sgtitle([name "Tibia motion relative to Femur"]);
end
