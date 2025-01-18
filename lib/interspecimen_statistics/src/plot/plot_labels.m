function plot_labels()

% linestyles = ["-","-o","--d"];
% Varus
nexttile(1);
title("Varus rotation")
xlabel('Flexion ($\circ$)')
ylabel('Varus ($\circ$) +ve')
% linestyleorder(linestyles)
% ylim([-15 10])

% External
nexttile(2); 
title("External rotation")
xlabel('Flexion ($\circ$)')
ylabel('External (mm) +ve')
% linestyleorder(linestyles)
% ylim([-15 10])

% Lateral
nexttile(3);
title("Lateral translation")
xlabel('Flexion ($\circ$)')
ylabel('Lateral (mm) +ve')
% linestyleorder(linestyles)
% ylim([-15 10])

% Anterior
nexttile(4);
title("Anterior translation")
xlabel('Flexion ($\circ$)')
ylabel('Anterior (mm) +ve')
% linestyleorder(linestyles)
% ylim([-15 10])

% Superior
nexttile(5);
title("Superior translation")
xlabel('Flexion ($\circ$)')
ylabel('Superior (mm) +ve')
% linestyleorder(linestyles)
% ylim([-15 10])

end
