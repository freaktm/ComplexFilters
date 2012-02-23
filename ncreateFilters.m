function f = ncreateFilters(mtspeed)
% Version which uses FFT function to create full set of filters

% Note filters are stored in order (0 30 330 60 300 90 270 120 240 150 210
% 180).
% Writes to file.

% John Perrone May 2010
str1 = 'nFilter';
str2 = '.dat';
str3 = num2str(mtspeed); 

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

nk = 1;
for ntheta = 1:length(theta)
    [mtspeed theta(ntheta)]
 
    wimang = theta(ntheta);
    ang = wimang * con;   
    for nn = 1:8
        wf = wvals(nn);
        for ny = 1:ysize
            vf = y1(ny);
            for nx = 1:xsize
                uf = x1(nx);              
                [esust, osust, etrans, otrans] = createComplexFiltervals(uf, vf, wf, ang, 0, 0, mtspeed, 40);
                nspectSe(nn,ny,nx) = esust * 4;
                nspectSo(nn,ny,nx) = osust * 4;
                nspectTe(nn,ny,nx) = etrans * 4 * 2;                
                nspectTo(nn,ny,nx) = otrans * 4 * 2;              
            end
        end
        
    end
    fnspectSe = (fftshift(nspectSe));
    fnspectSo = (fftshift(nspectSo));
    fnspectTe = (fftshift(nspectTe));
    fnspectTo = (fftshift(nspectTo));
    
    str4 = num2str(nk);
    str5 = strcat(str1, str3, '.', str4, str2);
    fid1 = fopen(str5, 'wb');
    for nf = 1:nframes
        fwrite(fid1, real((fnspectSe((nf),:,:))), 'float32');
        fwrite(fid1, imag((fnspectSe((nf),:,:))), 'float32');
        fwrite(fid1, real((fnspectSo((nf),:,:))), 'float32');
        fwrite(fid1, imag((fnspectSo((nf),:,:))), 'float32');
        fwrite(fid1, real((fnspectTe((nf),:,:))), 'float32');
        fwrite(fid1, imag((fnspectTe((nf),:,:))), 'float32');
        fwrite(fid1, real((fnspectTo((nf),:,:))), 'float32');
        fwrite(fid1, imag((fnspectTo((nf),:,:))), 'float32');
    end
    fclose(fid1);
    clear nspectSe;
    clear nspectTe;
    clear nspectSo;
    clear nspectTo;
    
    nk = nk + 1;
end


disp('Filters completed');
disp(wimang);

