%% Finds the lines in 3d space, then takes the transverse projection.
% Lines are skew, so we end up with the approximation of the intersection,
% which seems to work fine.
function [centre_of_rotation, direction] = intersect_surface(self)
    centre_of_rotation = cell(numel(self), 1);
    direction          = cell(numel(self), 1);
    for i = 1:numel(self)

        tTts = self(i).transforms.tTts;

        if isempty(tTts)
            continue
        end

        tTf = pageinv(self(i).transforms.fTt);

        tsTt = pageinv(tTts);
        tsTf = pageinv(self(i).transforms.fTts);

        %% In tibial surface frame of reference::
        tibia_ml    = tsTt(:, 1, :);
        tibia_origin = tsTt(:, 4, :);
        
        femur_ml = tsTf(:, 1, :);
        femur_origin = tsTf(:, 4, :);

        % Intersection points
        femur = zeros(4, 2, size(tTf, 3));
        femur(:, 1, :) = femur_ml;
        femur(:, 2, :) = -tibia_ml;

        tibial_surface = tibia_origin - femur_origin;

        ft = pagemldivide(femur, tibial_surface);
    
        centre_of_rotation{i} = (tibia_origin + pagemtimes(tibia_ml, ft(2, 1, :) )); %tsTcor
        direction{i}     = femur_ml; 
    end
end

%% Projects the lines to the transverse plane, then finds intersection.

% function [centre_of_rotation, direction] = intersect_surface(self)
%     centre_of_rotation = cell(numel(self), 1);
%     direction          = cell(numel(self), 1);
%     for i = 1:numel(self)
%         tTts = self(i).transforms.tTts;
% 
%         if isempty(tTts)
%             continue
%         end
% 
%         tTf = pageinv(self(i).transforms.fTt);
% 
%         surface_ml    = tTts(1:2, 1);
%         surface_origin = tTts(1:2, 4);
% 
%         femur_ml = tTf(1:2, 1, :);
%         femur_origin = tTf(1:2, 4, :);
% 
%         % Intersection points
%         femur = zeros(2, 2, size(tTf, 3));
%         femur(1, 1, :) = femur_ml(1, 1, :);
%         femur(2, 1, :) = femur_ml(2, 1, :);
%         femur(1, 2, :) = -surface_ml(1);
%         femur(2, 2, :) = -surface_ml(2);
% 
%         tibia = surface_origin - femur_origin;
% 
%         ft = pagemldivide(femur, tibia);
% 
%         centre_of_rotation{i} = squeeze(surface_origin + pagemtimes(surface_ml, ft(2, 1, :) )); %tTcor
%         direction{i}     = squeeze(femur_ml);
%     end
% end
