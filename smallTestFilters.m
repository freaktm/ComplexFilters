function f = smallTestFilters(mtspeed)
% tests one input string, 
% for the purposes of tweaking the output strings 
% before inserting into the full range test design
% Writes to file the input and output values

% Aaron Storey 2012
str1 = 'nFilterSmall';
str2 = '.txt';
str3 = num2str(mtspeed); 

% set constants
nframes = 8;
xsize = 128;
peakhz = 4;
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

%Input Values used for test (not the actual values used, but the place in the table of a range of values possible. 
% 1 is the lowest possible input valuein the range of values, ie for theta it is 0, for wf it is -4
angNum = 2; % 1 to 12
wfNum = 4; % 1 to nframes
vfNum = 45; % 1 to ysize
ufNum = 53; % 1 to xsize


	%set the filename string and open file for write
    str5 = strcat(str1, str3, '.', str2); 	
    dataFile = fopen(str5, 'w');
	
	% set the input variables
	wf = wvals(wfNum);
	vf = y1(vfNum);
	uf = x1(ufNum);    
	wimang = theta(angNum);
    ang = wimang * con;

    % turn input variables into strings and concatenate	
	inputstring = strcat(num2str(mtspeed), ',',num2str(wimang), ',', num2str(wf), ',', num2str(vf), ',', num2str(uf)); 
	[esust, osust, etrans, otrans] = createComplexFiltervals(uf, vf, wf, ang, 0, 0, mtspeed, 40);% calculate output variables
	fwrite(dataFile, inputstring); % write the first line of data
	fwrite(dataFile, 'CR'); % write a line break
	%fwrite(dataFile, num2str(real(esust))); - need to find out how to convert complex number into string, these methods dont work
	%fwrite(dataFile, osust);
	%fwrite(dataFile, num2str(etrans));
	%fwrite(dataFile, real(otrans));        
    fclose(dataFile); 

disp('Test completed');

