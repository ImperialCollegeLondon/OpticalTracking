function stl_plot(config, tibia_transform, femur_transform, x_offset_multi)
% Tibia and femur transform are 4 x 4 x m matrices.

if config.is_right_knee
    path_tibia = config.stl.tibia_right;
    path_femur = config.stl.femur_right;
else
    path_tibia = config.stl.tibia_left;
    path_femur = config.stl.femur_left;
end

tibia = stlread(path_tibia);
% We want to end up with m x n points for x, y and z points.
% m: time. n: points in the stl model
% tibia_transform = cat(3, tibia_transform{:}); % 4 x 4 x m

% Reflect the tibia in the ZY plane
tibia_transform(:, 2, :) = -tibia_transform(:, 2, :);
tibia_transform(:, 3, :) = -tibia_transform(:, 3, :);
t_points = [tibia.Points, ones(size(tibia.Points, 1), 1)]'; % 4 x n
t_transformed_points = pagemtimes(tibia_transform, t_points); % 4 x m x n
% Extract x,y,z and turn into 2D
t_x = squeeze(t_transformed_points(1, :, :))';

t_y = squeeze(t_transformed_points(2, :, :))';
t_z = squeeze(t_transformed_points(3, :, :))';
% t_z = -t_z;

femur = stlread(path_femur);
f_points = [femur.Points, ones(size(femur.Points, 1), 1)]'; % 4 x n
femur_transform(1, :, :) = -femur_transform(1, :, :);
femur_transform(2, :, :) = -femur_transform(2, :, :);
f_transformed_points = pagemtimes(femur_transform, f_points); % 4 x m x n

% Extract x,y,z and turn into 2D
f_x = squeeze(f_transformed_points(1, :, :))';
% f_x = -f_x + x_offset_multi*t_x(1); % This needs to be fixed. completely arbitrary.
f_y = squeeze(f_transformed_points(2, :, :))';
f_z = squeeze(f_transformed_points(3, :, :))';
% f_z = -f_z;

% Move z to 0.
% t_z = t_z - t_z(1);
% f_z = f_z - f_z(1);

% f_y = f_y - f_y(1);
% t_y = t_y - t_y(1);

% t_x = t_x - x_offset_multi*t_x(1);

%% Plotting axes
x_range = [ min([f_x(:) ; t_x(:)]), max([f_x(:); t_x(:)]) ];
y_range = [ min([f_y(:) ; t_y(:)]), max([f_y(:); t_y(:)]) ];
z_range = [ min([f_z(:) ; t_z(:)]), max([f_z(:); t_z(:)]) ];


filename = "stlplot.gif";
fig1 = uifigure;
range = 1:3:height(f_z);
i = range(1);
% camlight; lighting gouraud; axis equal;
% grid on;  xlabel("x"), ylabel("y"); zlabel("z");
% camorbit(1,0,'camera');


% Bad attempt at interactivity
% Create axes and plot initial patches
ax = uiaxes(fig1);
% xlim(ax, x_range); ylim(ax, y_range); zlim(ax, z_range);
    camlight(ax); axis(ax, 'equal'); grid(ax, 'on');
    lighting(ax, 'gouraud');
patch_handle_1 = patch(ax, 'Vertices', [f_x(1,:)', f_y(1,:)', f_z(1,:)'], ...
    'Faces', femur.ConnectivityList, 'FaceColor', '#eadfc3', 'EdgeColor', 'none');
patch_handle_2 = patch(ax, 'Vertices', [t_x(1,:)', t_y(1,:)', t_z(1,:)'], ...
    'Faces', tibia.ConnectivityList, 'FaceColor', '#eadfc3', 'EdgeColor', 'none');
xlabel(ax, "X"); ylabel(ax, "Y"); zlabel(ax, "Z");
hold(ax, 'off');

% Create slider
sld = uislider(fig1);
sld.Limits = [min(range) max(range)];
sld.Value = 1;
sld.ValueChangingFcn = @(src, event) update_frame(src, event);

% Update function for the frame
function update_frame(src, event)
    clf(ax);
    i = round(event.Value); % Get current slider value

    patch_handle_1.Vertices = [f_x(i,:)', f_y(i,:)', f_z(i,:)'];
    patch_handle_2.Vertices = [t_x(i,:)', t_y(i,:)', t_z(i,:)'];
        camlight(ax); 
    lighting(ax, 'gouraud');
    axis(ax, 'equal');
    grid(ax, 'on');
end

fig2 = figure;
for i = range
    clf(fig2);
    tiledlayout(2,2);


    % %% 2d plot
    % % XY plane projection
    % nexttile; title("XY plane"); hold on;
    % camlight; lighting gouraud; grid on; axis equal;
    % patch('Vertices', [f_x(i,:)', f_y(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    % patch('Vertices', [t_x(i,:)', t_y(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    % xlim(x_range); ylim(y_range);
    % hold off;
    % % ZY plane projection
    % nexttile; title("ZY plane"); hold on;
    % camlight; lighting gouraud; grid on; axis equal;
    % xlim(y_range); ylim(z_range);
    % patch('Vertices', [f_y(i,:)', f_z(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    % patch('Vertices', [t_y(i,:)', t_z(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    % hold off;
    % % ZX plane projection
    % nexttile;
    % title("ZX plane"); hold on;
    % camlight; lighting gouraud; grid on; axis equal;
    % 
    % patch('Vertices', [f_x(i,:)', f_z(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    % patch('Vertices', [t_x(i,:)', t_z(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    % xlim(x_range); ylim(z_range);
    % hold off;
    % 
    % nexttile;

    %% 3d plot
    camlight; lighting gouraud; axis equal; camorbit(1,0,'camera');
    grid on;  xlabel("x"), ylabel("y"); zlabel("z");
    
    
    xlim(x_range); ylim(y_range); zlim(z_range);
    patch('Vertices', [f_x(i,:)', f_y(i,:)', f_z(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', '#eadfc3', 'EdgeColor', 'none');
    patch('Vertices', [t_x(i,:)', t_y(i,:)', t_z(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', '#eadfc3', 'EdgeColor', 'none');
    xlabel("X"); ylabel("Y"); zlabel("Z");
    hold off;
    % 
    alpha(0.80);
    % view(60+5*i/20,30);

    % Create the gif
    frame = getframe(fig1);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);
    if i == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
end

%% Suggestions from Maria
% %% 4. Animate Bone Movement
% % Number of time steps
% numSteps = size(bone1_xyz, 1);
% % Loop through time steps
% for t = 1:numSteps
% % Update Bone 1 position
% hBone1.Vertices = bone1.Vertices + bone1_xyz(t, :);
% % Update Bone 2 position
% hBone2.Vertices = bone2.Vertices + bone2_xyz(t, :);
% % Pause to visualize the movement
% pause(0.1); % Adjust the pause duration for desired animation speed
% end
% %% 5. (Optional) Export Animation to Video
% % Create a VideoWriter object
% v = VideoWriter('bone_animation.avi');
% v.FrameRate = 10; % Set frame rate
% open(v);
% % Loop through time steps and save frames
% for t = 1:numSteps
% % Update Bone positions
% hBone1.Vertices = bone1.Vertices + bone1_xyz(t, :);
% hBone2.Vertices = bone2.Vertices + bone2_xyz(t, :);
% % Capture the frame
% frame = getframe(gcf);
% writeVideo(v, frame);
% end
% close(v);


end

