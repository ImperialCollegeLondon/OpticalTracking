function raw_plot_tf(name, input, idx_interpolation)
figure

subplot(3, 2, 1); hold on;
plot(input.flexion);
minima = find_minima(input.flexion);

plot(minima, input.flexion(minima), 'k*')
scatter(find(idx_interpolation), input.flexion(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Flexion');
title('Angles');

subplot(3, 2, 3); hold on;
plot(input.varus);
scatter(find(idx_interpolation), input.varus(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Tibial Varus');

subplot(3, 2, 5); hold on;
plot(input.external);
scatter(find(idx_interpolation), input.external(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Tibial Ext Rotation');

subplot(3, 2, 2); hold on;
plot(input.lateral);
scatter(find(idx_interpolation), input.lateral(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Lateral/medial');
title('Translations');

subplot(3, 2, 4); hold on;
plot(input.anterior);
scatter(find(idx_interpolation), input.anterior(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Anterior/posterior');

subplot(3, 2, 6); hold on;
plot(input.superior);
scatter(find(idx_interpolation), input.superior(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('DistComp');

sgtitle([name "Tibia motion relative to Femur"]);
end
