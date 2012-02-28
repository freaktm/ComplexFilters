function f = smallTestFilters(mtspeed)
% Version which uses FFT function to create full set of filters

% Note filters are stored in order (0 30 330 60 300 90 270 120 240 150 210
% 180).
% Writes to file.

% John Perrone May 2010
str1 = 'nFilterSmall';
str2 = '.txt';
str3 = num2str(mtspeed); 

nframes = 8.0;
xsize = 128.0;
peakhz = 4.0;

ysize = xsize;
u0 = peakhz/mtspeed;
umax = 20;

deltu = (2 * umax)/xsize;

con = pi/180;
sqpi = sqrt(pi);

hsize = round(xsize/2);
thalf = nframes/2;


theta = [0 30 60 90 120 150 180 210 240 270 300 330];

wvals = [-thalf:thalf-1];
x1 = [-umax:deltu:umax];
y1 = [-umax:deltu:umax];

angNum = 2; % 1 to 12
wfNum = 4; % 1 to nframes
vfNum = 45; % 1 to ysize
ufNum = 53; % 1 to xsize


    wimang = theta(angNum);
    ang = wimang * con; 
    str5 = strcat(str1, str3, '.', str2); 	
    dataFile = fopen(str5, 'w');
	wf = wvals(wfNum);
	vf = y1(vfNum);
	uf = x1(ufNum);
	inputstring = strcat(num2str(mtspeed), ',',num2str(wimang), ',', num2str(wf), ',', num2str(vf), ',', num2str(uf));
	[esust, osust, etrans, otrans] = createComplexFiltervals(uf, vf, wf, ang, 0, 0, mtspeed, 40);	
	fwrite(dataFile, inputstring);
	fwrite(dataFile, num2str(real(esust)));
	fwrite(dataFile, osust);
	fwrite(dataFile, etrans);
	fwrite(dataFile, otrans);        
    fclose(dataFile); 

disp('Test completed');

