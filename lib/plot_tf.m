function plot_tf(name, input)
figure

subplot(3, 2, 1);
plot([input.flexion]);
ylabel('Flexion');
title('Angles');

subplot(3, 2, 3);
plot([input.varus]);
ylabel('Tibial Varus');

subplot(3, 2, 5);
plot([input.external]);
ylabel('Tibial Ext Rotation');

subplot(3, 2, 2);
plot([input.lateral]);
ylabel('Lateral/medial');
title('Translations');

subplot(3, 2, 4);
plot([input.anterior]);
ylabel('Anterior/posterior');

subplot(3, 2, 6);
plot([input.superior]);
ylabel('DistComp');

sgtitle([name "Tibia motion relative to Femur"]);
end
