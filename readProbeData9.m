function data = readProbeData9(filename,n)

%n is the number of items in the fileheader

% open the file
fid = fopen(filename);

% read the file
block = 1;
while ~feof(fid)
    data(block).headerText = fscanf(fid, '%s', n); %there are n items in the file header, this code effectively groups them all as one

    % fscanf fills the array in column order,
    % so transpose the results
    data(block).points  = ...
      fscanf(fid, '%f,%f,%f,%f,%f,%f,%f,%f,%f',[9,inf])'; %there are 10 csv data points in a row, this imports all 10, each as a separate row

    block = block + 1;
end

% close the file
fclose(fid);

end