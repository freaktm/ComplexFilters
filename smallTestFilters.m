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
    str5 = strcat(str1, str3, '.', str2); 	%build the filename string
    dataFile = fopen(str5, 'w'); %open the file to overwrite
	
	% set the input variables
	wf = wvals(wfNum);
	vf = y1(vfNum);
	uf = x1(ufNum);    
	wimang = theta(angNum);
    ang = wimang * con;
	
	%initialise outputs
	esust = 1 * i;
	osust = 1 * i;
	etrans = 1 * i;
	otrans = 1 * i;

    % turn input variables into strings and concatenate	
	inputstring = strcat(num2str(mtspeed), ',',num2str(wimang), ',', num2str(wf), ',', num2str(vf), ',', num2str(uf), ','); 
	
	%NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING 
	[esust osust etrans otrans] = createComplexFiltervals(uf, vf, wf, ang, 0, 0, mtspeed, 40);% calculate output variables 
	newLine = '\n'; % new line, 
	%NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING NOT WORKING 

	%write line of data	
	fwrite(dataFile, inputstring); % write the input variables to the first half of data line
	esustString = strcat(num2str(real(esust)), '+', num2str(imag(esust)), 'i,'); %get string values for esust
	fwrite(dataFile, esustString); % write the esust values to the data line. 
	disp(esustString); % write the esust values to console. 
	osustString = strcat(num2str(real(osust)), '+', num2str(imag(osust)), 'i,'); %get string values for osust
	fwrite(dataFile, osustString); % write the osust values to the data line. 
	disp(osustString); % write the osust values to console. 
	etransString = strcat(num2str(real(etrans)), '+', num2str(imag(etrans)), 'i,'); %get string values for etrans
	fwrite(dataFile, etransString); % write the etrans values to the data line. 
	disp(etransString); % write the etrans values to console. 
	otransString = strcat(num2str(real(otrans)), '+', num2str(imag(otrans)), 'i'); %get string values for otrans
	fwrite(dataFile, otransString); % write the otrans values to the data line. 
	disp(otransString); % write the otrans values to console. 
	fwrite(dataFile, newLine); % new line
	fwrite(dataFile, 'TEST COMPLETE'); % write Completion Line      
    fclose(dataFile); % close the file

disp('Test completed');

