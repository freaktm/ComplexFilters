library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;
use ieee.math_complex.all;


entity filters is
  
  port (
    esust_re  : out real;
    esust_im  : out real;
    osust_re  : out real;
    osust_im  : out real;
    etrans_re : out real;
    etrans_im : out real;
    otrans_re : out real;
    otrans_im : out real;
    uf        : in  real;
    vf        : in  real;
    wf        : in  real;
    theta     : in  real;
    oeval     : in  real;
    stval     : in  real;
    mtspeed   : in  real;
    fps       : in  real
    );

end filters;



architecture Behavioral of filters is

  constant nframes   : integer := 8;
  constant xsize     : integer := 128;
  constant peakhz    : integer := 4;
  constant aspect    : integer := 1;
  constant umax      : integer := 20;
  constant kratio    : real    := 0.25;
  constant angconv   : real    := 6.4;
  constant tsd       : real    := 0.22;
  constant tphase    : real    := 0.1;
  constant ysize     : integer := xsize;
  constant deltu     : integer := (2*umax)/xsize;
  constant thalf     : integer := nframes/2;
  constant maxrate   : integer := 20;
  constant wInterval : real    := maxrate/thalf;




  signal speed               : real    := 0;
  signal u0                  : real    := 0;
  signal scale               : real    := 0;
  signal sigys               : real    := 0;
  signal udash               : real    := 0;
  signal shilb_im            : real    := 1;
  signal hz                  : real    := 0;
  signal stratio             : real    := 0;
  signal udash_pi            : real    := 0;
  signal ang                 : real    := 0;
  signal ang_S, ang_C, grad  : real    := 0;
  signal S                   : real    := 0;
  signal scale_S, scale_C    : real    := 0;
  signal xc1, xc2, xs1, xs2  : real    := 0;
  signal r, t                : real    := 0;
  signal p, q                : real    := 0;
  signal kc1                 : integer := 43;
  signal kc2                 : integer := 41;
  signal ks1                 : integer := 43;
  signal ks2                 : integer := kc2+ks1-kc1;
  signal g                   : real    := 0.25;
  signal r1, p1              : real    := 0;
  signal vdash               : real    := 0;
  signal w                   : real    := 0;
  signal sigys_pi            : real    := 0;
  signal temp1, temp2, temp3 : real    := 0;
  signal temp4               : real    := 0;
  signal temp5_im            : real    := 1;
  signal temp5_re            : real    := 0;
  signal tphase_S, tphase_C  : real    := 0;
  signal etsust_re           : real    := 0;
  signal etrans_im           : real    := 0;
  signal thilb_im            : real    := 1;
  signal thilb_re            : re      := 0;
  signal tempy, tempx        : re      := 0;
  signal espsust             : real    := 0;
  signal esptrans            : real    := 0;
  

  
begin  -- Behavioral

  

  u0    <= peakhz / mtspeed;
  scale <= mtspeed*(3/peakhz);
  sigys <= (1.4*aspect)/u0;
  speed <= (kratio*u0)/1;

  ang   <= theta * con;
  grad  <= tan(ang * 90*con);
  ang_S <= sin(ang);
  ang_C <= cos(ang);


  udash <= (vf*ang_S)+(uf*ang_C);


  p_shilb : if ang = 0 generate
    p_uf_shilb : if uf <= 0 generate
      shilb_im <= 1;
    else
      shilb_im <= -1;
    end generate p_uf_shilb;
  else
    p_vf_shilb : if vf <= grad generate
      shilb_im <= 1;
    else
      shilb_im <= -1;
    end generate p_vf_shilb;
  end generate p_shilb;


  hz <= speed * udash;

  p_hz_check : if hz = 0 generate
    hz <= 0.001;
  end generate p_hz_check;

  stratio <= (abs(hz)*kratio)/1;

  udash_pi <= (MATH_PI*MATH_PI)*(udash**2);

  S       <= scale*(8.23/60)*(2*MATH_PI);
  scale_S <= sin(S);
  scale_C <= cos(S);

  xc1 <= scale*(2.22/60);
  xc2 <= scale*(4.97/60);
  xs1 <= scale*(15.36/60);
  xs2 <= scale*(17.41/60);





  r <= kc2 * (exp(-1 * ((xs2**2)*udash_pi)));
  t <= ks2 * (exp(-1 * ((xs2**2)*udash_pi)));
  p <= kc1 * (exp(-1 * ((xc1**2)*udash_pi)));
  q <= ks1 * (exp(-1 * ((xs1**2)*udash_pi)));


  p1 <= p + q;
  r1 <= r - t;

  vdash    <= ((-1 * uf)*ang_S)+(vf*ang_C);
  w        <= wInterval * wf;
  sigys_pi <= sigys * MATH_PI;
  temp1    <= (scale_C*((p1**2)+(-1 * (2 * (scale_C * p1)))))**2;
  temp2    <= temp1 + (r1 * (scale_C*(1-2*g)))**2;
  temp4    <= sigys_pi * (exp(-1 * ((sigys_pi * vdash)**2)));

  tempy <= SQRT(temp4);
  tempx <= SQRT(temp2);

  tphase_C <= cos(w * (2*MATH_PI*tphase));
  tphase_S <= sin(w * (2*MATH_PI*tphase));

  -----------------------------------------------------------------------------
  -- esust temp 1
  temp3    <= tphase_C * (exp(-0.5*((tsd**2)*(w**2))));
  -----------------------------------------------------------------------------
  --esust temp 2
  temp5_re <= tphase_C * (exp(-0.5*((tsd**2)*(w**2))));
  temp5_im <= 1;
  -----------------------------------------------------------------------------
  

  

  

  espsust  <= tempy * tempx;
  esptrans <= espsust * stratio;
  

end Behavioral;
