function [esust osust etrans otrans] = createComplexFiltervals(uf, vf, wf, theta, oeval, stval, mtspeed, fps) 
% Function for finding filter (complex) values at particular location,

% John Perrone, May 2010

% Constants

nframes = 8;
xsize = 128;
peakhz = 4;
kratio = 0.25;
aspect = 1;
angconv = 6.4;
tsd = 0.22;
tphase = 0.1;

ysize = xsize;
u0 = peakhz/mtspeed;
umax = 20;

deltu = (2 * umax)/xsize;

con = pi/180;
sqpi = sqrt(pi);

hsize = round(xsize/2);
thalf = nframes/2;

% Frequency domain version of temporal filters start here
maxrate = 20;
samprate = fps;
thilb = sign(wf) * i;

if thilb == 0
    thilb = 1;
end

wInterval = maxrate/thalf;
w = wf * wInterval;


temp1 = exp(-.5 * (w^2 * tsd^2)) * cos(2 * pi * w * tphase);
temp2 = -1 * exp(-.5 * (w^2 * tsd^2)) * sin(2 * pi * w * tphase) * i;
etsust = (temp1 + temp2);

ettrans = kratio * etsust * (w) * i;

%Spatial filters start here

scale = 3/u0; 
xc1 = (2.22/60) * scale;  % spread in degrees
xc2 = (4.97/60) * scale;
kc1 = 43;
kc2 = 41;
xs1 = (15.36/60) * scale;
xs2 = (17.41/60) * scale;
ks1 = 43;
ks2 = kc2 + ks1 - kc1;
g = .25;
S = (8.23/60) * scale;

umax = 20;
deltu = (2 * umax)/xsize;
sigys = 1.4 * aspect/u0;
sigyt = sigys;

speed = 1/(kratio * u0);
ang = theta * con;  % all in radians from now on

udash = uf * cos(ang) + vf * sin(ang);
vdash = -uf * sin(ang) + vf * cos(ang);
sf = (udash)^2;
p = kc1 * exp(-1 * xc1 * xc1 * pi * pi * sf);
q = ks1 * exp(-1 * xs1 * xs1 * pi * pi * sf);
r = kc2 * exp(-1 * xc2 * xc2 * pi * pi * sf);
t = ks2 * exp(-1 * xs2 * xs2 * pi * pi * sf);
p1 = p - q;
r1 = r - t;

sf2 = udash;
temp1 = (p1 * p1) - 2 * p1 * r1 * cos(2 * pi * sf2 * S) + (r1 * cos(2 * pi * sf2 * S))^2;
temp2 = (temp1 + (r1 * (1 - 2 * g) * sin(2 * pi * sf2 * S))^2);
tempx = sqrt(temp2);

temp4 = pi * sigys * exp(-1.0 * (pi * sigys * vdash)^2);
tempy = sqrt(temp4);
espsust = tempx * tempy;

hz = udash * speed;
if hz == 0
    hz = .001;
end
stratio = 1/(kratio * abs(hz));
temp4 = pi * sigyt * exp(-1.0 * (pi * sigyt * vdash)^2);
tempy = sqrt(temp4);
esptrans = tempx * stratio * tempy;

if ang == 0.0
    if uf <= 0.0
        shilb = i;
    else
        shilb = -i;
    end
else
    grad = tan(ang + (90 * con));
    ytest = uf * grad;
    if vf <= ytest
        shilb = i;
    else
        shilb = -i;
   end
end

esust = espsust * etsust;
osust = (espsust * shilb) * etsust;

emain = esptrans * ettrans;
ehilb = (esptrans * shilb) * (ettrans * thilb);
etrans = -1 * ((-1 * emain) + ehilb);

omain = (esptrans * shilb) * ettrans;
ohilb = (esptrans * shilb * shilb) * (ettrans * thilb);
otrans = -1 * ((-1 * omain) + ohilb);

