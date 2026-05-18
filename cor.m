data = readtable("data/HF04_RK/Intact_Tibial Surface/surface.csv");
data = data(strcmpi(data.State, 'OK'), 1:13);

x = data.Tx;
y = data.Ty;
z = data.Tz;

hold on;
scatter3(x, y, z, 'red');