function plot_tf(name, input, idx_interpolation)
figure

subplot(3, 2, 3); hold on;
plot(input.flexion, input.varus, 'b');
scatter(input.flexion(find(idx_interpolation)), input.varus(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Tibial Varus (°)');
xlabel('Flexion (°)');

subplot(3, 2, 5); hold on;
plot(input.flexion, input.external, 'b');
scatter(input.flexion(find(idx_interpolation)), input.external(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Tibial Ext Rotation (°)');
xlabel('Flexion (°)');

subplot(3, 2, 2); hold on;
plot(input.flexion, input.lateral, 'b');
scatter(input.flexion(find(idx_interpolation)), input.lateral(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Lateral (mm) +ve');
title('Translations');
xlabel('Flexion (°)');

subplot(3, 2, 4); hold on;
plot(input.flexion, input.anterior, 'b');
scatter(input.flexion(find(idx_interpolation)), input.anterior(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Anterior (mm) +ve');
xlabel('Flexion (°)');

subplot(3, 2, 6); hold on;
plot(input.flexion, input.superior, 'b');
scatter(input.flexion(find(idx_interpolation)), input.superior(idx_interpolation), 5, "filled", 'r');
hold off;
ylabel('Distal (mm) +ve');
xlabel('Flexion (°)');

sgtitle([name "Tibia motion relative to Femur"]);
end
