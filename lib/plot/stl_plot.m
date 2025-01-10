function stl_plot(config, tibia_transform, femur_transform)
% Tibia and femur transform are 4 x 4 x m matrices.

if config.is_right_knee
    path_tibia = config.stl.tibia_right;
    path_femur = config.stl.femur_right;
else
    path_tibia = config.stl.tibia_left;
    path_femur = config.stl.femur_left;
end

tibia = stlread(path_tibia);


t_points = [tibia.Points, ones(size(tibia.Points, 1), 1)]'; % 4 x n
t_transformed_points = pagemtimes(tibia_transform, t_points); % 4 x m x n
% Extract x,y,z and turn into 2D
t_x = squeeze(t_transformed_points(1, :, :))';
t_y = squeeze(t_transformed_points(2, :, :))';
t_z = squeeze(t_transformed_points(3, :, :))';
% t_z = -t_z;

femur = stlread(path_femur);
f_points = [femur.Points, ones(size(femur.Points, 1), 1)]'; % 4 x n
f_transformed_points = pagemtimes(femur_transform, f_points); % 4 x m x n

% Extract x,y,z and turn into 2D
f_x = squeeze(f_transformed_points(1, :, :))';
f_y = squeeze(f_transformed_points(2, :, :))';
f_z = squeeze(f_transformed_points(3, :, :))';


% Transforms that might be helpful to plot properly
% f_x = -f_x + x_offset_multi*t_x(1); % This needs to be fixed. completely arbitrary.

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
fig1 = figure;

linkdata on;
hold off;
alpha(0.80);
while true
    for i = 1:3:height(f_z)
        % tiledlayout(2,2);
    clf(fig1);
    
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
    
        camlight; lighting gouraud; axis equal; camorbit(1,0,'camera');
        grid on;  xlabel("x"), ylabel("y"); zlabel("z"); hold on;
        xlim(x_range); ylim(y_range); zlim(z_range);
    
        patch('Vertices', [f_x(i,:)', f_y(i,:)', f_z(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', '#eadfc3', 'EdgeColor', 'none');
        patch('Vertices', [t_x(i,:)', t_y(i,:)', t_z(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', '#eadfc3', 'EdgeColor', 'none');
        % 
        
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

    function make_patch(x, y, z, connections)
        h = patch('Vertices', [x', y', z'], 'Faces', connections, 'FaceColor', '#eadfc3', 'EdgeColor', 'none');
        set(h,'XDataSource','x');
        set(h,'YDataSource','y');
        set(h,'ZDataSource','z');
    end