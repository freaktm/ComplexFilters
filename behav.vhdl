library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;
use ieee.math_complex.all;


entity filters is

  port (
    esust_im  : out real;
    esust_re  : out real;
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
  constant wInterval : real    := real(maxrate/thalf);
  constant con       : real    := MATH_PI / 180.0;
  constant kc1       : integer := 43;
  constant kc2       : integer := 41;
  constant ks1       : integer := 43;
  constant ks2       : integer := kc2+ks1-kc1;

  signal speed               : real := 0.0;
  signal u0                  : real := 0.0;
  signal scale               : real := 0.0;
  signal sigys               : real := 0.0;
  signal udash               : real := 0.0;
  signal shilb_im            : real := 0.0;
  signal hz                  : real := 0.0;
  signal stratio             : real := 0.0;
  signal udash_pi            : real := 0.0;
  signal ang                 : real := 0.0;
  signal ang_S, ang_C, grad  : real := 0.0;
  signal S                   : real := 0.0;
  signal scale_S, scale_C    : real := 0.0;
  signal xc1, xc2, xs1, xs2  : real := 0.0;
  signal r, t                : real := 0.0;
  signal p, q                : real := 0.0;
  signal g                   : real := 0.25;
  signal r1, p1              : real := 0.0;
  signal vdash               : real := 0.0;
  signal w                   : real := 0.0;
  signal sigys_pi            : real := 0.0;
  signal temp1, temp2, temp3 : real := 0.0;
  signal temp4               : real := 0.0;
  signal temp5_im            : real := 0.0;
  signal tphase_S, tphase_C  : real := 0.0;
  signal etsust_re           : real := 0.0;
  signal etsust_im           : real := 0.0;
  signal thilb_im            : real := 0.0;
  signal tempy, tempx        : real := 0.0;
  signal espsust             : real := 0.0;
  signal esptrans            : real := 0.0;
  signal temp6_re            : real := 0.0;
  signal temp6_im            : real := 0.0;
  signal ettrans_im          : real := 0.0;
  signal ettrans_re          : real := 0.0;
  signal thilb_ettrans_im    : real := 0.0;
  signal thilb_ettrans_re    : real := 0.0;
  signal esust_im_int        : real := 0.0;
  signal esust_re_int        : real := 0.0;
  signal shilb_esptrans_im   : real := 0.0;
  signal ehilb               : real := 0.0;
  signal emain_re            : real := 0.0;
  signal emain_im            : real := 0.0;
  signal omain_im            : real := 0.0;
  signal omain_re            : real := 0.0;
  signal ohilb_im            : real := 0.0;

begin  -- Behavioral

  esust_im <= esust_im_int;
  esust_re <= esust_re_int;

  u0    <= real(peakhz)/mtspeed;
  scale <= mtspeed*(3.0/real(peakhz));
  sigys <= (1.4*real(aspect))/u0;
  speed <= (real(kratio)*u0)/1.0;

  ang   <= theta * con;
  grad  <= tan(ang * 90.0*real(con));
  ang_S <= sin(ang);
  ang_C <= cos(ang);

  udash <= (vf*ang_S)+(uf*ang_C);

  p_shilb : process (ang, uf, vf)
  begin  -- process p_shilb
    if (ang = 0.0) then
      if (uf     <= 0.0) then
        shilb_im <= 1.0;
      else
        shilb_im <= -1.0;
      end if;
    else
      if (vf     <= grad) then
        shilb_im <= 1.0;
      else
        shilb_im <= -1.0;
      end if;
    end if;
  end process p_shilb;

  p_hz_check : process (hz)
  begin  -- process p_hz_check
    hz   <= speed * udash;
    if (hz = 0.0) then
      hz <= 0.001;
    end if;
  end process p_hz_check;

  stratio <= (abs(hz)*real(kratio))/1.0;

  udash_pi <= (MATH_PI*MATH_PI)*(udash**2);

  S       <= scale*(8.23/60.0)*(2.0*MATH_PI);
  scale_S <= sin(S);
  scale_C <= cos(S);

  xc1 <= scale*(2.22/60.0);
  xc2 <= scale*(4.97/60.0);
  xs1 <= scale*(15.36/60.0);
  xs2 <= scale*(17.41/60.0);

  r <= real(kc2) * (exp(-1.0 * ((xs2**2)*udash_pi)));
  t <= real(ks2) * (exp(-1.0 * ((xs2**2)*udash_pi)));
  p <= real(kc1) * (exp(-1.0 * ((xc1**2)*udash_pi)));
  q <= real(ks1) * (exp(-1.0 * ((xs1**2)*udash_pi)));

  p1 <= p + q;
  r1 <= r - t;

  vdash    <= ((-1.0 * uf)*ang_S)+(vf*ang_C);
  w        <= wInterval * wf;
  sigys_pi <= sigys * MATH_PI;
  temp1    <= (scale_C*((p1**2)+(-1.0 * (2.0 * (scale_C * p1)))))**2;
  temp2    <= temp1 + (r1 * (scale_C*(1.0-2.0*g)))**2;
  temp4    <= sigys_pi * (exp(-1.0 * ((sigys_pi * vdash)**2)));

  tempy <= SQRT(temp4);
  tempx <= SQRT(temp2);

  tphase_C <= cos(w * (2.0*MATH_PI*tphase));
  tphase_S <= sin(w * (2.0*MATH_PI*tphase));

  temp3    <= tphase_C * (exp(-0.5*((tsd**2)*(w**2))));
  temp5_im <= tphase_C * (exp(-0.5*((tsd**2)*(w**2))));

  etsust_re <= temp3;
  etsust_im <= temp5_im;

  espsust  <= tempy * tempx;
  esptrans <= espsust * stratio;

  temp6_im   <= w*etsust_im;
  temp6_re   <= w*etsust_re;
  ettrans_re <= kratio * temp6_im;
  ettrans_im <= kratio * temp6_re;

  emain_re <= -1.0 * (ettrans_re * esptrans);
  emain_im <= -1.0 * (ettrans_im * esptrans);

  p_thilb : process (thilb_im)
  begin  -- process p_thilb
    thilb_im   <= SIGN(wf);
    if thilb_im = 0.0 then
      thilb_im <= 1.0;
    end if;
  end process p_thilb;

  thilb_ettrans_im <= thilb_im * ettrans_re;
  thilb_ettrans_re <= thilb_im * ettrans_im;

  esust_re_int <= espsust * etsust_re;
  esust_im_int <= espsust * etsust_im;

  osust_re <= esust_im_int * shilb_im;
  osust_im <= esust_re_int * shilb_im;

  shilb_esptrans_im <= esptrans * shilb_im;
  ehilb             <= thilb_ettrans_im * shilb_esptrans_im;

  etrans_re <= -1.0 * (emain_re + ehilb);
  etrans_im <= -1.0 * emain_im;

  omain_im <= -1.0 * (shilb_esptrans_im * ettrans_re);
  omain_re <= -1.0 * (shilb_esptrans_im * ettrans_im);

  ohilb_im <= thilb_ettrans_im * (shilb_esptrans_im * shilb_im);

  otrans_re <= -1.0 * (ohilb_im * omain_im);
  otrans_im <= -1.0 * (ohilb_im * omain_re);


end Behavioral;
