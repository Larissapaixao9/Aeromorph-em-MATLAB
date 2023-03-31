%Add all filepaths
current_dir = cd;
airfoildir = fullfile(current_dir, 'airfoils');
helpdir = fullfile(current_dir, 'help');

%Load Airfoil
inputfile = fullfile(airfoildir, 'lrn1015.dat');
fid = fopen(inputfile);
data = textscan(fid, '%f %f');
fclose(fid);
xc = data{1};
yc = data{2};