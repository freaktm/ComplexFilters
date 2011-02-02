library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library floatfixlib;
use floatfixlib.float_pkg.all;
use floatfixlib.fixed_pkg.all;




entity filters is

  port (
    clk       : in  std_logic;
    esust_im  : out float32;
    esust_re  : out float32;
    osust_re  : out float32;
    osust_im  : out float32;
    etrans_re : out float32;
    etrans_im : out float32;
    otrans_re : out float32;
    otrans_im : out float32;
    uf        : in  float32;
    vf        : in  float32;
    wf        : in  float32;
    theta     : in  float32;
    oeval     : in  float32;
    stval     : in  float32;
    mtspeed   : in  float32
    );

end filters;


architecture Behavioral of filters is


  component trig_function
    generic (
      opcode : string := "COS"
      );
    port (
      clk      : in  std_logic;
      data_in  : in  float32;
      data_out : out float32);
  end component;

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
  constant deltu     : real    := (2.0*real(umax))/real(xsize);
  constant thalf     : integer := nframes/2;
  constant maxrate   : integer := 20;
  constant wInterval : real    := real(maxrate/thalf);
  constant con       : real    := MATH_PI / 180.0;
  constant kc1       : integer := 43;
  constant kc2       : integer := 41;
  constant ks1       : integer := 43;
  constant ks2       : integer := kc2+ks1-kc1;
  constant g         : real    := 0.25;


  signal sigys          : float32;
  signal sigys_pi       : float32;
  signal sigys_pi_vdash : float32;
  signal speed          : float32;
  signal u0             : float32;
  signal scale          : float32;
  signal grad           : float32;
  signal u0_kratio      : float32;
  signal ang_90_con     : float32;
  signal w_2            : float32;
  signal w_tphase       : float32;



  signal udash               : real := 0.0;
  signal shilb_im            : real := 0.0;
  signal hz                  : real := 0.0;
  signal stratio             : real := 0.0;
  signal udash_pi            : real := 0.0;
  signal ang                 : float32;
  signal ang_S, ang_C        : real := 0.0;
  signal S                   : real := 0.0;
  signal scale_S, scale_C    : real := 0.0;
  signal xc1, xc2, xs1, xs2  : real := 0.0;
  signal r, t                : real := 0.0;
  signal p, q                : real := 0.0;
  signal r1, p1              : real := 0.0;
  signal vdash               : real := 0.0;
  signal w                   : float32;
  signal temp1, temp2, temp3 : real := 0.0;
-- signal temp4 : sfixed(sfixed_exp_size downto sfixed_dec_size);
  signal temp5_im            : real := 0.0;
  signal tphase_S, tphase_C  : real := 0.0;
  signal etsust_re           : real := 0.0;
  signal etsust_im           : real := 0.0;
  signal thilb_im            : float32;
-- signal tempy, tempx : sfixed(sfixed_exp_size downto sfixed_dec_size);
-- signal espsust : sfixed(sfixed_exp_size downto sfixed_dec_size);
-- signal esptrans : sfixed(sfixed_exp_size downto sfixed_dec_size);
  signal temp6_re            : real := 0.0;
  signal temp6_im            : real := 0.0;
  signal ettrans_im          : real := 0.0;
  signal ettrans_re          : real := 0.0;
  signal thilb_ettrans_im    : real := 0.0;
  signal thilb_ettrans_re    : real := 0.0;
  signal shilb_esptrans_im   : real := 0.0;
  signal shilb_esptrans_re   : real := 0.0;
  signal ehilb_re            : real := 0.0;
  signal ehilb_im            : real := 0.0;
  signal emain_re            : real := 0.0;
  signal emain_im            : real := 0.0;
  signal omain_im            : real := 0.0;
  signal omain_re            : real := 0.0;
  signal ohilb_im            : real := 0.0;
  signal ohilb_re            : real := 0.0;


  signal esust_im_int  : float32;
  signal esust_re_int  : float32;
  signal osust_re_int  : float32;
  signal osust_im_int  : float32;
  signal etrans_im_int : float32;
  signal etrans_re_int : float32;
  signal otrans_re_int : float32;
  signal otrans_im_int : float32;

  signal uf_int      : float32;
  signal vf_int      : float32;
  signal wf_int      : float32;
  signal theta_int   : float32;
  signal oeval_int   : float32;
  signal stval_int   : float32;
  signal mtspeed_int : float32;


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- float32 signals converted to real for simulation only  -------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --synthesis translate_off
  signal sigys_real : real;
  signal u0_real    : real;
  signal scale_real : real;
  signal speed_real : real;
  signal ang_real   : real;
  signal grad_real  : real;
  --synthesis translate_on







begin  -- Behavioral
  
  p_input_registers : process (clk)
  begin
    if clk'event and clk = '1' then
      uf_int      <= uf;
      vf_int      <= vf;
      wf_int      <= wf;
      theta_int   <= theta;
      oeval_int   <= oeval;
      stval_int   <= stval;
      mtspeed_int <= mtspeed;
    end if;
  end process p_input_registers;

  p_output_registers : process (clk)
  begin
    if clk'event and clk = '1' then
      esust_im  <= esust_im_int;
      esust_re  <= esust_re_int;
      osust_im  <= osust_im_int;
      osust_re  <= osust_re_int;
      etrans_im <= etrans_im_int;
      etrans_re <= etrans_re_int;
      otrans_im <= otrans_im_int;
      otrans_re <= otrans_re_int;
    end if;
  end process p_output_registers;


  p_stage_0 : process (clk)
  begin
    if clk'event and clk = '1' then
      u0       <= to_float(peakhz)/mtspeed_int;
      scale    <= mtspeed_int*(3.0/to_float(peakhz));
      uf_0     <= uf_int;
      vf_0     <= vf_int;
      ang      <= theta_int * to_float(con);
      thilb_im <= SIGN(wf_int);
      w        <= to_float(wInterval) * wf_int;
    end if;
  end process p_stage_0;


  p_stage_1 : process (clk)
  begin
    if clk'event and clk = '1' then
      sigys      <= (1.4*to_float(aspect))/u0;
      u0_kratio  <= to_float(kratio) * u0;
      uf_1       <= uf_0;
      vf_1       <= vf_0;
      ang_0      <= ang;
      ang_S      <= sin(ang);
      ang_C      <= cos(ang);
      ang_90_con <= (90.0 * to_float(con)) + ang;
      w_2        <= (w)**2;
      w_tphase   <= w * (2.0*to_float(MATH_PI)*to_float(tphase));
    end if;
  end process p_stage_1;


  p_stage_2 : process (clk)
  begin
    if clk'event and clk = '1' then
      speed    <= 1.0/u0_kratio;
      vf_ang_s <= vf_1 * ang_S;
      vf_ang_c <= vf_1 * ang_C;
      uf_ang_s <= uf_1 * ang_S;
      uf_ang_c <= uf_1 * ang_C;
      sigys_pi <= sigys * to_float(MATH_PI);
      grad_in  <= ang * 90.0 * to_float(con);
      w_2_tsd  <= w_2 * to_float(tsd**2);
      tphase_s <= sin(w_tphase);
      tphase_c <= cos(w_tphase);
    end if;
  end process p_stage_2;





  grad : trig_function
    generic map (
      opcode => "TAN")
    port map (
      clk      => clk,
      data_in  => grad_in,
      data_out => grad);


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- float32 signals converted to real for simulation only  -------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --synthesis translate_off
  u0_real    <= To_real(u0);
  sigys_real <= To_real(sigys);
  scale_real <= To_real(scale);
  speed_real <= To_real(speed);
  ang_real   <= To_real(ang);
  grad_real  <= To_real(grad);
  --synthesis translate_on






-- udash <= (vf_int*ang_S)+(uf_int*ang_C);


-- p_shilb : process (ang, uf_int, vf_int)
-- begin                                -- process p_shilb
--     if (ang = 0.0) then
--       if (uf_int <= 0.0) then
--         shilb_im <= 1.0;
--       else
--         shilb_im <= -1.0;
--       end if;
--     else
--       if (vf_int <= grad) then
--         shilb_im <= 1.0;
--       else
--         shilb_im <= -1.0;
--       end if;
--     end if;
--   end process p_shilb;

-- p_hz_check : process (hz)
-- begin                                -- process p_hz_check
--     hz   <= speed * udash;
--     if (hz = 0.0) then
--       hz <= 0.001;
--     end if;
--   end process p_hz_check;

-- stratio <= (abs(hz)*real(kratio))/1.0;

-- udash_pi <= (MATH_PI*MATH_PI)*(udash**2);

-- S <= scale*(8.23/60.0)*(2.0*MATH_PI);
-- scale_S <= sin(S);
-- scale_C <= cos(S);

-- xc1 <= scale*(2.22/60.0);
-- xc2 <= scale*(4.97/60.0);
-- xs1 <= scale*(15.36/60.0);
-- xs2 <= scale*(17.41/60.0);

-- r <= real(kc2) * (exp(-1.0 * ((xs2**2)*udash_pi)));
-- t <= real(ks2) * (exp(-1.0 * ((xs2**2)*udash_pi)));
-- p <= real(kc1) * (exp(-1.0 * ((xc1**2)*udash_pi)));
-- q <= real(ks1) * (exp(-1.0 * ((xs1**2)*udash_pi)));

-- p1 <= p + q;
-- r1 <= r - t;

-- vdash <= ((-1.0 * uf_int)*ang_S)+(vf_int*ang_C);


-- sigys_pi_vdash <= sigys_pi * to_sfixed(vdash, sfixed_exp_size, sfixed_dec_size);
-- temp1 <= (scale_C*((p1**2)+(-1.0 * (2.0 * (scale_C * p1)))))**2;
-- temp2 <= temp1 + (r1 * (scale_C*(1.0-2.0*g)))**2;
-- temp4 <= sigys_pi * to_sfixed(exp(-1.0 * (to_real(sigys_pi_vdash)**2)), sfixed_exp_size, sfixed_dec_size);

-- tempy <= to_sfixed(SQRT(to_real(temp4)), sfixed_exp_size, sfixed_dec_size);
-- tempx <= to_sfixed(SQRT(temp2), sfixed_exp_size, sfixed_dec_size);

-- tphase_C <= cos(w * (2.0*MATH_PI*tphase));
-- tphase_S <= sin(w * (2.0*MATH_PI*tphase));

-- temp3 <= tphase_C * (exp(-0.5*((tsd**2)*(w**2))));
-- temp5_im <= tphase_C * (exp(-0.5*((tsd**2)*(w**2))));

-- etsust_re <= temp3;
-- etsust_im <= temp5_im;

-- espsust <= tempy * tempx;
-- esptrans <= espsust * to_sfixed(stratio, sfixed_exp_size, sfixed_dec_size);

-- temp6_im <= w*etsust_im;
-- temp6_re <= w*etsust_re;
-- ettrans_re <= kratio * temp6_im;
-- ettrans_im <= kratio * temp6_re;

-- emain_re <= -1.0 * (ettrans_re * esptrans);
-- emain_im <= -1.0 * (ettrans_im * esptrans);


-- p_thilb : process (thilb_im)
-- begin                                -- process p_thilb
--     if thilb_im = 0.0 then
--       thilb_ettrans_re <= ettrans_re;
--       thilb_ettrans_im <= ettrans_im;
--     else
--       thilb_ettrans_im <= thilb_im * ettrans_re;
--       thilb_ettrans_re <= thilb_im * ettrans_im;
--     end if;
--   end process p_thilb;


-- esust_re_int <= to_float(espsust * etsust_re);
-- esust_im_int <= to_float(espsust * etsust_im);

-- osust_re_int <= esust_im_int * to_float(shilb_im);
-- osust_im_int <= esust_re_int * to_float(shilb_im);

-- shilb_esptrans_im <= esptrans * shilb_im;
-- shilb_esptrans_re <= shilb_im * shilb_esptrans_im;
-- ehilb_re <= thilb_ettrans_im * shilb_esptrans_im;
-- ehilb_im <= shilb_esptrans_im * thilb_ettrans_re;

-- etrans_re_int <= to_float(-1.0 * ((-1.0 * emain_re) + ehilb_re));
-- etrans_im_int <= to_float(-1.0 * ((-1.0 * emain_im) + ehilb_im));

-- omain_im <= -1.0 * (shilb_esptrans_im * ettrans_re);
-- omain_re <= -1.0 * (shilb_esptrans_im * ettrans_im);

-- ohilb_re <= shilb_esptrans_re * thilb_ettrans_re;
-- ohilb_im <= thilb_ettrans_im * shilb_esptrans_re;

-- otrans_re_int <= to_float(-1.0 * ((ohilb_im * omain_im) + (ohilb_re * omain_re)));
-- otrans_im_int <= to_float(-1.0 * ((ohilb_im * omain_re) + (ohilb_re * omain_im)));


end Behavioral;
