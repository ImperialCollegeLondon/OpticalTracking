% Code to numerically differentiate a cell array of matrices
% Specifically, this code was written to differentiate the orientation
% matrix of the tibia relative to the femur in order to find the relative
% angular velocity vector
% Daryl 05072018

% Forward difference for the first matrix, backward difference for the last
% matrix and central difference for all the matrices in between

function derivatives = numdiff(A,dt) % A is the cell array of orientation matrices, dt is the time increment

l = length(A); % find number of elements in A

derivatives = {}; % initialise an empty cell array to store the cell array of matrix derivatives

for i = 1:l
    if i == 1 % forward difference for the first matrix
       derivatives{i,1} = (A{i+1,1}-A{i,1})/(dt);
    
    elseif i == l % backward difference for the last matrix
       derivatives{i,1} = (A{i,1}-A{i-1,1})/(dt);
   
    else % central difference for all elements in between
        derivatives{i,1} = (A{i+1,1}-A{i-1,1})/(2*dt);
        
    end
end