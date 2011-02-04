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


  -----------------------------------------------------------------------------
  -- constants
  -----------------------------------------------------------------------------
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


  -----------------------------------------------------------------------------
  -- pipelined signals length definition
  -----------------------------------------------------------------------------
  subtype  float_vec is array (natural range<>) of float32;
  constant N_STAGES_UF       : integer := 3;
  constant N_STAGES_VF       : integer := 3;
  constant N_STAGES_ANG      : integer := 3;
  constant N_STAGES_SCALE    : integer := 5;
  constant N_STAGES_THILB    : integer := 9;
  constant N_STAGES_SHILB    : integer := 18;
  constant N_STAGES_STRATIO  : integer := 11;
  constant N_STAGES_SG1      : integer := 5;
  constant N_STAGES_ETSUST   : integer := 12;
  constant N_STAGES_W        : integer := 8;
  constant N_STAGES_SPEED    : integer := 2;
  constant N_STAGES_SIGYS_PI : integer := 5;
  constant N_STAGES_TPHASE_S : integer := 3;
  constant N_STAGES_TPHASE_C : integer := 3;

  -----------------------------------------------------------------------------
  -- stage 0 signals
  -----------------------------------------------------------------------------
  signal uf                 : float_vec(N_STAGES_UF-1 downto 0);
  signal vf                 : float_vec(N_STAGES_VF-1 downto 0);
  signal ang                : float_vec(N_STAGES_ANG-1 downto 0);
  signal scale              : float_vec(N_STAGES_SCALE-1 downto 0);
  signal w                  : float_vec(N_STAGES_W-1 downto 0);
  signal thilb_im_temp      : float32;
  signal u0                 : float32;
  -----------------------------------------------------------------------------
  -- stage 1 signals
  -----------------------------------------------------------------------------
  signal thilb_im           : float_vec(N_STAGES_THILB-1 downto 0);
  signal thilb_re           : float_vec(N_STAGES_THILB-1 downto 0);
  signal u0_kratio          : float32;
  signal ang_s              : float32;
  signal ang_c              : float32;
  signal ang_90_con         : float32;
  signal sigys              : float32;
  signal w_square           : float32;
  signal w_tphase           : float32;
  -----------------------------------------------------------------------------
  -- stage 2 signals
  -----------------------------------------------------------------------------
  signal speed              : float_vec(N_STAGES_SPEED-1 downto 0);
  signal vf_ang_c           : float32;
  signal vf_ang_s           : float32;
  signal uf_ang_c           : float32;
  signal uf_ang_s           : float32;
  signal grad               : float32;
  signal sigys_pi           : float_vec(N_STAGES_SIGYS_PI-1 downto 0);
  signal w_2_tsd            : float32;
  signal tphase_s           : float_vec(N_STAGES_TPHASE_S-1 downto 0);
  signal tphase_c           : float_vec(N_STAGES_TPHASE_C-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 3 signals
  -----------------------------------------------------------------------------
  signal shilb_im           : float_vec(N_STAGES_SHILB-1 downto 0);
  signal speed_0            : float32;
  signal udash              : float32;
  signal vdash              : float32;
  signal sigys_pi_0         : float32;
  signal w_2_tsd_div        : float32;
  signal tphase_s_0         : float32;
  signal tphase_c_0         : float32;
  signal s                  : float32;
  signal w_2                : float32;
  -----------------------------------------------------------------------------
  -- stage 4 signals
  -----------------------------------------------------------------------------
  signal hz                 : float32;
  signal sf                 : float32;
  signal udash_0            : float32;
  signal s_2_pi             : float32;
  signal sigys_pi_1         : float32;
  signal vdash_s            : float32;
  signal tphase_s_1         : float32;
  signal tphase_c_1         : float32;
  signal exp_w_2            : float32;
  signal w_3                : float32;
  -----------------------------------------------------------------------------
  -- stage 5 signals
  -----------------------------------------------------------------------------
  signal hz_0               : float32;
  signal xc1                : float32;
  signal xc2                : float32;
  signal xs1                : float32;
  signal xs2                : float32;
  signal sf_pi2             : float32;
  signal udash_s_pi         : float32;
  signal sigys_pi_2         : float32;
  signal vdash_sx2          : float32;
  signal temp3              : float32;
  signal tphase_exp_s       : float32;
  signal w_4                : float32;
  -----------------------------------------------------------------------------
  -- stage 6 signals
  -----------------------------------------------------------------------------
  signal hz_abs             : float32;
  signal xc22               : float32;
  signal sf_pi2_0           : float32;
  signal scale_s            : float32;
  signal scale_c            : float32;
  signal xs22               : float32;
  signal xc12               : float32;
  signal sigys_pi_3         : float32;
  signal vdash_exp          : float32;
  signal xs12               : float32;
  signal temp3_0            : float32;
  signal temp5_im           : float32;
  signal w_5                : float32;
  -----------------------------------------------------------------------------
  -- stage 7 signals
  -----------------------------------------------------------------------------
  signal etsust_re          : float_vec(N_STAGES_ETSUST-1 downto 0);
  signal etsust_im          : float_vec(N_STAGES_ETSUST-1 downto 0);
  signal xs12_sfpi2         : float32;
  signal xc12_sfpi2         : float32;
  signal xs22_sfpi2         : float32;
  signal xc22_sfpi2         : float32;
  signal temp4              : float32;
  signal hz_kratio          : float32;
  signal w_6                : float32;
  signal scale_s_0          : float32;
  signal scale_c_0          : float32;
  -----------------------------------------------------------------------------
  -- stage 8 signals
  -----------------------------------------------------------------------------
  signal stratio            : float_vec(N_STAGES_STRATIO-1 downto 0);
  signal xc22_exp           : float32;
  signal xs22_exp           : float32;
  signal xc12_exp           : float32;
  signal temp4_0            : float32;
  signal xs12_exp           : float32;
  signal temp6_re           : float32;
  signal temp6_im           : float32;
  signal scale_s_1          : float32;
  signal scale_c_1          : float32;
  signal temp4_0            : float32;
  -----------------------------------------------------------------------------
  -- stage 9 signals
  -----------------------------------------------------------------------------
  signal r                  : float32;
  signal t                  : float32;
  signal scale_s_2          : float32;
  signal scale_c_2          : float32;
  signal p                  : float32;
  signal q                  : float32;
  signal temp7_im           : float32;
  signal temp7_re           : float32;
  signal temp4_1            : float32;
  -----------------------------------------------------------------------------
  -- stage 10 signals
  -----------------------------------------------------------------------------
  signal scale_s_g          : float32;
  signal r1                 : float32;
  signal scale_c_3          : float32;
  signal p1                 : float32;
  signal ettrans_re         : float32;
  signal ettrans_im         : float32;
  signal temp4_2            : float32;
  -----------------------------------------------------------------------------
  -- stage 11 signals
  -----------------------------------------------------------------------------
  signal scale_s_r1         : float32;
  signal scale_c_r1         : float32;
  signal scale_c_4          : float32;
  signal p1_0               : float32;
  signal p1_square          : float32;
  signal thilb_ettrans_re   : float32;
  signal thilb_ettrans_im   : float32;
  signal temp4_3            : float32;
  -----------------------------------------------------------------------------
  -- stage 12 signals
  -----------------------------------------------------------------------------
  signal scale_SG1          : float_vec(N_STAGES_SG1-1 downto 0);
  signal scale_c_p1         : float32;
  signal p1_square_0        : float32;
  signal thilb_ettrans_re_0 : float32;
  signal thilb_ettrans_im_0 : float32;
  signal temp4_4            : float32;
  -----------------------------------------------------------------------------
  -- stage 13 signals
  -----------------------------------------------------------------------------
  signal scale_c_p1_x2      : float32;
  signal p1_square_1        : float32;
  signal thilb_ettrans_re_1 : float32;
  signal thilb_ettrans_im_1 : float32;
  signal temp4_5            : float32;
  -----------------------------------------------------------------------------
  -- stage 14 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_2 : float32;
  signal thilb_ettrans_im_2 : float32;
  signal p1_square_scale_c  : float32;
  signal temp4_6            : float32;
  -----------------------------------------------------------------------------
  -- stage 15 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_3 : float32;
  signal thilb_ettrans_im_3 : float32;
  signal scale_cc           : float32;
  signal temp4_7            : float32;
  -----------------------------------------------------------------------------
  -- stage 16 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_4 : float32;
  signal thilb_ettrans_im_4 : float32;
  signal temp4_8            : float32;
  signal temp1              : float32;
  -----------------------------------------------------------------------------
  -- stage 17 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_5 : float32;
  signal thilb_ettrans_im_5 : float32;
  signal temp4_9            : float32;
  signal temp2              : float32;
  -----------------------------------------------------------------------------
  -- stage 18 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_6 : float32;
  signal thilb_ettrans_im_6 : float32;
  signal tempx              : float32;
  signal tempy              : float32;
  -----------------------------------------------------------------------------
  -- stage 19 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_7 : float32;
  signal thilb_ettrans_im_7 : float32;
  signal espsust            : float32;
  -----------------------------------------------------------------------------
  -- stage 20 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_8 : float32;
  signal thilb_ettrans_im_8 : float32;
  signal esust_int          : float32;
  signal esptrans           : float32;
  -----------------------------------------------------------------------------
  -- stage 21 signals
  -----------------------------------------------------------------------------
  signal thilb_ettrans_re_9 : float32;
  signal thilb_ettrans_im_9 : float32;
  signal esust_int_0        : float32;
  signal osust_int          : float32;
  signal emain              : float32;
  signal shilb_esptrans_im  : float32;




  -----------------------------------------------------------------------------
  -- output signals
  -----------------------------------------------------------------------------
  signal esust_im_int  : float32;
  signal esust_re_int  : float32;
  signal osust_re_int  : float32;
  signal osust_im_int  : float32;
  signal etrans_im_int : float32;
  signal etrans_re_int : float32;
  signal otrans_re_int : float32;
  signal otrans_im_int : float32;
  -----------------------------------------------------------------------------
  -- input signals
  -----------------------------------------------------------------------------
  signal uf_int        : float32;
  signal vf_int        : float32;
  signal wf_int        : float32;
  signal theta_int     : float32;
  signal oeval_int     : float32;
  signal stval_int     : float32;
  signal mtspeed_int   : float32;


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


  -----------------------------------------------------------------------------
  -- stage 0
  -----------------------------------------------------------------------------
  p_stage_0 : process (clk)
  begin
    if clk'event and clk = '1' then
      u0            <= to_float(peakhz)/mtspeed_int;
      thilb_im_temp <= SIGN(wf_int);


      w(0) <= to_float(wInterval) * wf_int;
      for i in 1 to N_STAGES_W-1 loop
        w(i) <= w(i-1);
      end loop;  -- i

      uf(0) <= uf_int;
      for i in 1 to N_STAGES_UF-1 loop
        uf(i) <= uf(i-1);
      end loop;  -- i

      vf(0) <= vf_int;
      for i in 1 to N_STAGES_VF-1 loop
        vf(i) <= vf(i-1);
      end loop;  -- i

      ang(0) <= theta_int * to_float(con);
      for i in 1 to N_STAGES_ANG-1 loop
        ang(i) <= ang(i-1);
      end loop;  -- i

      scale(0) <= mtspeed_int*(3.0/to_float(peakhz));
      for i in 1 to N_STAGES_SCALE-1 loop
        scale(i) <= scale(i-1);
      end loop;  -- i
      
    end if;
  end process p_stage_0;



  -----------------------------------------------------------------------------
  -- stage 1
  -----------------------------------------------------------------------------
  p_stage_1 : process (clk)
  begin
    if clk'event and clk = '1' then
      sigys      <= (1.4*to_float(aspect))/u0;
      u0_kratio  <= to_float(kratio) * u0;
      ang_s      <= sin(ang);
      ang_c      <= cos(ang);
      ang_90_con <= (90.0 * to_float(con)) + ang;
      w_square   <= (w)**2;
      w_tphase   <= w * (2.0*to_float(MATH_PI)*to_float(tphase));

      if thilb_im_temp = 0.0 then
        thilb_re(0) <= to_float(1.0);
      else
        thilb_re(0) <= to_float(0.0);
      end if;
      thilb_im(0) <= thilb_im_temp;
      for i in 1 to N_STAGES_THILB-1 loop
        thilb_im(i) <= thilb_im(i-1);
        thilb_re(i) <= thilb_re(i-1);
      end loop;  -- i
    end if;
  end process p_stage_1;

  -----------------------------------------------------------------------------
  -- stage 2
  -----------------------------------------------------------------------------
  p_stage_2 : process (clk)
  begin
    if clk'event and clk = '1' then
      sigys_pi(0) <= sigys * to_float(MATH_PI);
      for i in 1 to N_STAGES_SIGYS_PI-1 loop
        sigys_pi(i) <= sigys_pi(i-1);
      end loop;  -- i
      speed(0) <= 1.0/u0_kratio;
      for i in 1 to N_STAGES_SPEED-1 loop
        speed(i) <= speed(i-1);
      end loop;  -- i
      tphase_s(0) <= sin(w_tphase);
      for i in 1 to N_STAGES_TPHASE_S-1 loop
        tphase_s(i) <= tphase_s(i-1);
      end loop;  -- i
      tphase_c(0) <= cos(w_tphase);
      for i in 1 to N_STAGES_TPHASE_C-1 loop
        tphase_c(i) <= tphase_c(i-1);
      end loop;  -- i

      vf_ang_s <= vf_1 * ang_s;
      vf_ang_c <= vf_1 * ang_c;
      uf_ang_s <= uf_1 * ang_s;
      uf_ang_c <= uf_1 * ang_c;
      grad_in  <= ang * 90.0 * to_float(con);
      w_2_tsd  <= w_square * to_float(tsd**2);
    end if;
  end process p_stage_2;


--  grad : trig_function
--    generic map (
--      opcode   => "TAN")
--    port map (
--      clk      => clk,
--      data_in  => grad_in,
--      data_out => grad);



  p_stage_3 : process (clk)
  begin
    if clk'event and clk = '1' then
      speed_0     <= speed;
      scale_2     <= scale_1;
      sigys_pi_0  <= sigys_pi;
      udash       <= vf_ang_s + uf_ang_c;
      vdash       <= uf_ang_s + vf_ang_c;
      w_2_tsd_div <= w_2_tsd * 0.5;
      tphase_c_0  <= tphase_c;
      tphase_s_0  <= tphase_s;
      s           <= (8.23/60) * scale;
      w_2         <= w_1;
      if (ang_1 = 0.0) then
        if (uf_2 <= 0.0) then
          shilb_im <= 1.0;
        else
          shilb_im <= -1.0;
        end if;
      else
        if (vf_2 <= grad) then
          shilb_im <= 1.0;
        else
          shilb_im <= -1.0;
        end if;
      end if;
    end if;
  end process p_stage_3;

  p_stage_4 : process (clk)
  begin
    if clk'event and clk = '1' then
      hz         <= speed_0 * udash;
      sf         <= (udash)**2;
      udash_0    <= udash;
      s_2_pi     <= (2.0 * to_float(MATH_PI)) * s;
      scale_3    <= scale_2;
      sigys_pi_1 <= sigys_pi_0;
      vdash_s    <= vdash * sigys_pi_0;
      tphase_s_1 <= tphase_s_0;
      tphase_c_1 <= tphase_c_0;
      exp_w_2    <= exp(w_2_tsd_div);
      w_3        <= w_2;
    end if;
  end process p_stage_4;



  p_stage_5 : process (clk)
  begin
    if clk'event and clk = '1' then
      if (hz = 0.0) then
        hz_0 <= to_float(0.001);
      else
        hz_0 <= hz;
      end if;
      xc1          <= scale_3*(2.22/60.0);
      xc2          <= scale_3*(4.97/60.0);
      xs1          <= scale_3*(15.36/60.0);
      xs2          <= scale_3*(17.41/60.0);
      sf_pi2       <= sf * to_float(MATH_PI*MATH_PI);
      udash_s_pi   <= udash_0 * s_2_pi;
      sigys_pi_2   <= sigys_pi_1;
      vdash_sx2    <= -1.0 * (vdash_s)**2;
      temp3        <= tphase_c_1 * exp_w_2;
      tphase_exp_s <= tphase_s_1 * exp_w_2;
      w_4          <= w_3;
    end if;
  end process p_stage_5;


  p_stage_6 : process (clk)
  begin
    if clk'event and clk = '1' then
      hz_abs     <= abs(hz_0);
      xc22       <= (xc2)**2;
      sf_pi2_0   <= sf_pi2;
      scale_s    <= sin(udash_s_pi);
      scale_c    <= cos(udash_s_pi);
      xs22       <= (xs2)**2;
      xc12       <= (xc1)**2;
      sigys_pi_3 <= sigys_pi_2;
      vdash_exp  <= exp(vdash_sx2);
      xs12       <= (xs1)**2;
      temp3_0    <= temp3;
      temp5_im   <= (-1.0 * (tphase_exp_s));
      w_5        <= w_4;
    end if;
  end process p_stage_6;


  p_stage_7 : process (clk)
  begin
    if clk'event and clk = '1' then
      etsust_re  <= temp3_0;
      etsust_im  <= temp5_im;
      xs12_sfpi2 <= sf_pi2_0 * xs12;
      xc12_sfpi2 <= sf_pi2_0 * xc12;
      xs22_sfpi2 <= sf_pi2_0 * xs22;
      xc22_sfpi2 <= sf_pi2_0 * xc22;
      temp4      <= sigys_pi_3 * vdash_exp;
      hz_kratio  <= hz_abs * to_float(kratio);
      w_6        <= w_5;
      scale_s_0  <= scale_s;
      scale_c_0  <= scale_c;
    end if;
  end process p_stage_7;

  p_stage_8 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_8;

  p_stage_9 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_9;

  p_stage_10 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_10;

  p_stage_11 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_11;

  p_stage_12 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_12;

  p_stage_13 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_13;

  p_stage_14 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_14;

  p_stage_15 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_15;

  p_stage_16 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_16;

  p_stage_17 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_17;

  p_stage_18 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_18;


  p_stage_19 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_19;

  p_stage_20 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_20;

  p_stage_21 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_21;

  p_stage_22 : process (clk)
  begin
    if clk'event and clk = '1' then

    end if;
  end process p_stage_22;




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








  -----------------------------------------------------------------------------
  -- --------------------------------------------------------------------------
  -- --------------------------------------------------------------------------
  -- --------------------------------------------------------------------------
  -- OLD CODE - COMBINATIONAL           -------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

-- stratio <= (abs(hz)*real(kratio))/1.0;

-- udash_pi <= (MATH_PI*MATH_PI)*(udash**2);

-- S <= scale*(8.23/60.0)*(2.0*MATH_PI);
-- scale_S <= sin(S);
-- scale_C <= cos(S);


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
