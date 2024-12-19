function stl_plot(tibia_stl_path, tibia_transform, femur_stl_path, femur_transform)
% Tibia and femur transform are 4 x 4 x m matrices.

tibia = stlread(tibia_stl_path);
% We want to end up with m x n points for x, y and z points.
% m: time. n: points in the stl model
% tibia_transform = cat(3, tibia_transform{:}); % 4 x 4 x m
t_points = [tibia.Points, ones(size(tibia.Points, 1), 1)]'; % 4 x n
t_transformed_points = pagemtimes(tibia_transform, t_points); % 4 x m x n
% Extract x,y,z and turn into 2D
t_x = squeeze(t_transformed_points(1, :, :))';
t_y = squeeze(t_transformed_points(2, :, :))';
t_z = squeeze(t_transformed_points(3, :, :))';

femur = stlread(femur_stl_path);
f_points = [femur.Points, ones(size(femur.Points, 1), 1)]'; % 4 x n
f_transformed_points = pagemtimes(femur_transform, f_points); % 4 x m x n
% Extract x,y,z and turn into 2D
f_x = squeeze(f_transformed_points(1, :, :))';
f_x = -f_x + 1.6*t_x(1);
f_y = squeeze(f_transformed_points(2, :, :))';
f_z = squeeze(f_transformed_points(3, :, :))';


filename = "stlplot.gif";
fig1 = figure(1);

for i = 1:3:height(f_z)
    clf(fig1);
    camlight; lighting gouraud;
grid on;  xlabel("x"), ylabel("y"); zlabel("z");
axis equal; 
    camorbit(1,0,'camera');

%     %% 2d plot
%     % XY plane projection
%     nexttile; title("XY plane"); hold on;
%     patch('Vertices', [f_x(i,:)', f_y(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
%     patch('Vertices', [t_x(i,:)', t_y(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
%     camlight; lighting gouraud;
%     hold off;
% %     % ZY plane projection
%     nexttile; title("ZY plane"); hold on;
%     patch('Vertices', [f_y(i,:)', f_z(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
%     patch('Vertices', [t_y(i,:)', t_z(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
%     camlight; lighting gouraud;
% hold off;
%     % ZX plane projection
%     nexttile;
%     title("ZX plane"); hold on;
%     patch('Vertices', [f_x(i,:)', f_z(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
%     patch('Vertices', [t_x(i,:)', t_z(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
%     camlight; lighting gouraud;
%     hold off;
% 
%     nexttile;

    %% 3d plot
    
    patch('Vertices', [f_x(i,:)', f_y(i,:)', f_z(i,:)'], 'Faces', femur.ConnectivityList, 'FaceColor', 'red', 'EdgeColor', 'none');
    patch('Vertices', [t_x(i,:)', t_y(i,:)', t_z(i,:)'], 'Faces', tibia.ConnectivityList, 'FaceColor', 'blue', 'EdgeColor', 'none');
    hold off;
    % 
    alpha(0.85);
    % view(60+5*log(i),30);

    % Create the gif
    frame = getframe(fig1);
    % im = frame2im(frame);
    % [imind, cm] = rgb2ind(im, 256);
    % if i == 1
    %     imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    % else
    %     imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    % end
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
