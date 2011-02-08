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
  constant deltu     : float32 := (2.0*to_float(umax))/to_float(xsize);
  constant thalf     : integer := nframes/2;
  constant maxrate   : integer := 20;
  constant wInterval : real    := real(maxrate/thalf);
  constant con       : float32 := to_float(MATH_PI) / 180.0;
  constant kc1       : integer := 43;
  constant con_90    : float32 := con * 90.0;
  constant kc2       : integer := 41;
  constant ks1       : integer := 43;
  constant ks2       : integer := kc2+ks1-kc1;
  constant g         : real    := 0.25;


  -----------------------------------------------------------------------------
  -- Array signals length definition
  -----------------------------------------------------------------------------
  type float_vec is array (natural range <>) of float32;
  type std_logic_a is array (natural range <>) of std_logic;
  constant N_STAGES_UF            : integer := 3;
  constant N_STAGES_VF            : integer := 3;
  constant N_STAGES_ANG           : integer := 3;
  constant N_STAGES_SCALE         : integer := 5;
  constant N_STAGES_THILB         : integer := 9;
  constant N_STAGES_SHILB         : integer := 19;
  constant N_STAGES_STRATIO       : integer := 12;
  constant N_STAGES_SG1           : integer := 5;
  constant N_STAGES_ETSUST        : integer := 14;
  constant N_STAGES_W             : integer := 7;
  constant N_STAGES_SPEED         : integer := 2;
  constant N_STAGES_SIGYS_PI      : integer := 5;
  constant N_STAGES_TPHASE_S      : integer := 3;
  constant N_STAGES_TPHASE_C      : integer := 3;
  constant N_STAGES_UDASH         : integer := 2;
  constant N_STAGES_SFPI2         : integer := 2;
  constant N_STAGES_TEMP4         : integer := 11;
  constant N_STAGES_ETTRANS       : integer := 13;
  constant N_STAGES_THILB_ETTRANS : integer := 13;
  constant N_STAGES_SCALEC        : integer := 9;
  constant N_STAGES_SCALES        : integer := 4;
  constant N_STAGES_P1SQUARE      : integer := 3;
  constant N_STAGES_P1            : integer := 2;
  constant N_STAGES_ESUST_INT     : integer := 5;
  constant N_STAGES_OSUST_INT     : integer := 4;
  constant N_STAGES_ETRANS_INT    : integer := 2;
  constant N_STAGES_OMAIN         : integer := 2;

  -----------------------------------------------------------------------------
  -- stage 0 signals
  -----------------------------------------------------------------------------
  signal uf_int               : float_vec(N_STAGES_UF-1 downto 0);
  signal vf_int               : float_vec(N_STAGES_VF-1 downto 0);
  signal ang                  : float_vec(N_STAGES_ANG-1 downto 0);
  signal scale                : float_vec(N_STAGES_SCALE-1 downto 0);
  signal w                    : float_vec(N_STAGES_W-1 downto 0);
  signal thilb_im_temp        : float32;
  signal u0                   : float32;
  -----------------------------------------------------------------------------
  -- stage 1 signals
  -----------------------------------------------------------------------------
  signal thilb_im             : float_vec(N_STAGES_THILB-1 downto 0);
  signal thilb_re             : std_logic_a(N_STAGES_THILB-1 downto 0);
  signal u0_kratio            : float32;
  signal ang_s                : float32;
  signal ang_c                : float32;
  signal ang_90_con           : float32;
  signal sigys                : float32;
  signal w_square             : float32;
  signal w_tphase             : float32;
  -----------------------------------------------------------------------------
  -- stage 2 signals
  -----------------------------------------------------------------------------
  signal speed                : float_vec(N_STAGES_SPEED-1 downto 0);
  signal vf_ang_c             : float32;
  signal vf_ang_s             : float32;
  signal uf_ang_c             : float32;
  signal uf_ang_s             : float32;
  signal grad                 : float32;
  signal sigys_pi             : float_vec(N_STAGES_SIGYS_PI-1 downto 0);
  signal w_2_tsd              : float32;
  signal tphase_s             : float_vec(N_STAGES_TPHASE_S-1 downto 0);
  signal tphase_c             : float_vec(N_STAGES_TPHASE_C-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 3 signals
  -----------------------------------------------------------------------------
  signal shilb_im             : std_logic_vector(N_STAGES_SHILB-1 downto 0);
  signal udash                : float_vec(N_STAGES_UDASH-1 downto 0);
  signal vdash                : float32;
  signal w_2_tsd_div          : float32;
  signal s                    : float32;
  -----------------------------------------------------------------------------
  -- stage 4 signals
  -----------------------------------------------------------------------------
  signal hz                   : float32;
  signal sf                   : float32;
  signal s_2_pi               : float32;
  signal vdash_s              : float32;
  signal exp_w_2              : float32;
  -----------------------------------------------------------------------------
  -- stage 5 signals
  -----------------------------------------------------------------------------
  signal xc1                  : float32;
  signal xc2                  : float32;
  signal xs1                  : float32;
  signal xs2                  : float32;
  signal hz_0                 : float32;
  signal sf_pi2               : float_vec(N_STAGES_SFPI2-1 downto 0);
  signal udash_s_pi           : float32;
  signal vdash_sx2            : float32;
  signal temp3                : float32;
  signal tphase_exp_s         : float32;
  -----------------------------------------------------------------------------
  -- stage 6 signals
  -----------------------------------------------------------------------------
  signal hz_abs               : float32;
  signal xc22                 : float32;
  signal scale_s              : float_vec(N_STAGES_SCALES-1 downto 0);
  signal scale_c              : float_vec(N_STAGES_SCALEC-1 downto 0);
  signal xs22                 : float32;
  signal xc12                 : float32;
  signal vdash_exp            : float32;
  signal xs12                 : float32;
  signal etsust_re            : float_vec(N_STAGES_ETSUST-1 downto 0);
  signal etsust_im            : float_vec(N_STAGES_ETSUST-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 7 signals
  -----------------------------------------------------------------------------
  signal xs12_sfpi2           : float32;
  signal xc12_sfpi2           : float32;
  signal xs22_sfpi2           : float32;
  signal xc22_sfpi2           : float32;
  signal temp4                : float_vec(N_STAGES_TEMP4-1 downto 0);
  signal hz_kratio            : float32;
  signal temp6_re             : float32;
  signal temp6_im             : float32;
  -----------------------------------------------------------------------------
  -- stage 8 signals
  -----------------------------------------------------------------------------
  signal stratio              : float_vec(N_STAGES_STRATIO-1 downto 0);
  signal xc22_exp             : float32;
  signal xs22_exp             : float32;
  signal xc12_exp             : float32;
  signal xs12_exp             : float32;
  signal temp7_im             : float32;
  signal temp7_re             : float32;
  -----------------------------------------------------------------------------
  -- stage 9 signals
  -----------------------------------------------------------------------------
  signal r                    : float32;
  signal t                    : float32;
  signal p                    : float32;
  signal q                    : float32;
  signal ettrans_re           : float_vec(N_STAGES_ETTRANS-1 downto 0);
  signal ettrans_im           : float_vec(N_STAGES_ETTRANS-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 10 signals
  -----------------------------------------------------------------------------
  signal scale_s_g            : float32;
  signal r1                   : float32;
  signal p1                   : float_vec(N_STAGES_P1-1 downto 0);
  signal thilb_ettrans_re     : float_vec(N_STAGES_THILB_ETTRANS-1 downto 0);
  signal thilb_ettrans_im     : float_vec(N_STAGES_THILB_ETTRANS-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 11 signals
  -----------------------------------------------------------------------------
  signal scale_s_r1           : float32;
  signal scale_c_r1           : float32;
  signal p1_square            : float_vec(N_STAGES_P1SQUARE-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 12 signals
  -----------------------------------------------------------------------------
  signal scale_SG1            : float_vec(N_STAGES_SG1-1 downto 0);
  signal scale_c_p1           : float32;
  -----------------------------------------------------------------------------
  -- stage 13 signals
  -----------------------------------------------------------------------------
  signal scale_c_p1_x2        : float32;
  -----------------------------------------------------------------------------
  -- stage 14 signals
  -----------------------------------------------------------------------------
  signal p1_square_scale_c    : float32;
  -----------------------------------------------------------------------------
  -- stage 15 signals
  -----------------------------------------------------------------------------
  signal scale_cc             : float32;
  -----------------------------------------------------------------------------
  -- stage 16 signals
  -----------------------------------------------------------------------------
  signal temp1                : float32;
  -----------------------------------------------------------------------------
  -- stage 17 signals
  -----------------------------------------------------------------------------
  signal temp2                : float32;
  -----------------------------------------------------------------------------
  -- stage 18 signals
  -----------------------------------------------------------------------------
  signal tempx                : float32;
  signal tempy                : float32;
  -----------------------------------------------------------------------------
  -- stage 19 signals
  -----------------------------------------------------------------------------
  signal espsust              : float32;
  -----------------------------------------------------------------------------
  -- stage 20 signals
  -----------------------------------------------------------------------------
  signal esust_int_re         : float_vec(N_STAGES_ESUST_INT-1 downto 0);
  signal esust_int_im         : float_vec(N_STAGES_ESUST_INT-1 downto 0);
  signal esptrans             : float32;
  -----------------------------------------------------------------------------
  -- stage 21 signals
  -----------------------------------------------------------------------------
  signal osust_int_re         : float_vec(N_STAGES_OSUST_INT-1 downto 0);
  signal osust_int_im         : float_vec(N_STAGES_OSUST_INT-1 downto 0);
  signal shilb_esptrans_im    : float32;
  signal emain_im             : float32;
  signal emain_re             : float32;
  -----------------------------------------------------------------------------
  -- stage 22 signals
  -----------------------------------------------------------------------------
  signal emain_neg_im         : float32;
  signal emain_neg_re         : float32;
  signal ehilb_im             : float32;
  signal ehilb_re             : float32;
  signal shilb_esptrans_im_im : float32;
  signal omain_re             : float_vec(N_STAGES_OMAIN-1 downto 0);
  signal omain_im             : float_vec(N_STAGES_OMAIN-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 23 signals
  -----------------------------------------------------------------------------
  signal ohilb_im             : float32;
  signal ohilb_re             : float32;
  signal etrans_int_im        : float_vec(N_STAGES_ETRANS_INT-1 downto 0);
  signal etrans_int_re        : float_vec(N_STAGES_ETRANS_INT-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 24 signals
  -----------------------------------------------------------------------------
  signal otrans_int_re        : float32;
  signal otrans_int_im        : float32;
  -----------------------------------------------------------------------------
  -- output signals
  -----------------------------------------------------------------------------
  signal etrans_im_int        : float32;
  signal etrans_re_int        : float32;
  signal otrans_re_int        : float32;
  signal otrans_im_int        : float32;
  -----------------------------------------------------------------------------
  -- input signals
  -----------------------------------------------------------------------------
  signal uf_i                 : float32;
  signal vf_i                 : float32;
  signal wf_int               : float32;
  signal theta_int            : float32;
  signal oeval_int            : float32;
  signal stval_int            : float32;
  signal mtspeed_int          : float32;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- float32 signals converted to real for simulation only  -------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --synthesis translate_off
  signal sigys_real           : real;
  signal u0_real              : real;
  signal scale_real           : real;
  signal speed_real           : real;
  signal ang_real             : real;
  signal grad_real            : real;
  --synthesis translate_on




begin  -- Behavioral
  -----------------------------------------------------------------------------
  -- input stage
  -----------------------------------------------------------------------------
  p_input_registers  : process (clk)
  begin
    if clk'event and clk = '1' then
      uf_i                  <= uf;
      vf_i                  <= vf;
      wf_int                <= wf;
      theta_int             <= theta;
      oeval_int             <= oeval;
      stval_int             <= stval;
      mtspeed_int           <= mtspeed;
    end if;
  end process p_input_registers;
  -----------------------------------------------------------------------------
  -- output stage
  -----------------------------------------------------------------------------
  p_output_registers : process (clk)
  begin
    if clk'event and clk = '1' then
      esust_im              <= esust_int_im(3);
      esust_re              <= esust_int_re(3);
      osust_im              <= osust_int_im(2);
      osust_re              <= osust_int_re(2);
      etrans_im             <= etrans_int_im(1);
      etrans_re             <= etrans_int_re(1);
      otrans_im             <= otrans_int_im;
      otrans_re             <= otrans_int_re;
    end if;
  end process p_output_registers;
  -----------------------------------------------------------------------------
  -- stage 0
  -----------------------------------------------------------------------------
  p_stage_0          : process (clk)
  begin
    if clk'event and clk = '1' then
      u0                    <= to_float(peakhz)/mtspeed_int;
      thilb_im_temp         <= SIGN(wf_int);
      w(0)                  <= to_float(wInterval) * wf_int;
      for i in 1 to N_STAGES_W-1 loop
        w(i)                <= w(i-1);
      end loop;  -- i
      uf_int(0)             <= uf_i;
      for i in 1 to N_STAGES_UF-1 loop
        uf_int(i)           <= uf_int(i-1);
      end loop;  -- i
      vf_int(0)             <= vf_i;
      for i in 1 to N_STAGES_VF-1 loop
        vf_int(i)           <= vf_int(i-1);
      end loop;  -- i
      ang(0)                <= theta_int * con;
      for i in 1 to N_STAGES_ANG-1 loop
        ang(i)              <= ang(i-1);
      end loop;  -- i
      scale(0)              <= mtspeed_int*(3.0/to_float(peakhz));
      for i in 1 to N_STAGES_SCALE-1 loop
        scale(i)            <= scale(i-1);
      end loop;  -- i
    end if;
  end process p_stage_0;
  -----------------------------------------------------------------------------
  -- stage 1
  -----------------------------------------------------------------------------
  p_stage_1          : process (clk)
  begin
    if clk'event and clk = '1' then
      sigys                 <= (1.4 * to_float(aspect))/u0;
      u0_kratio             <= to_float(kratio) * u0;
      ang_s                 <= sin(ang);
      ang_c                 <= cos(ang);
      ang_90_con            <= con_90 + ang(0);
      w_square              <= w(0)*w(0);
      w_tphase              <= w(0) * (2.0*to_float(MATH_PI)*to_float(tphase));
      if thilb_im_temp = 0.0 then
        thilb_re(0)         <= '1';
      else
        thilb_re(0)         <= '0';
      end if;
      thilb_im(0)           <= thilb_im_temp;
      for i in 1 to N_STAGES_THILB-1 loop
        thilb_im(i)         <= thilb_im(i-1);
        thilb_re(i)         <= thilb_re(i-1);
      end loop;  -- i
    end if;
  end process p_stage_1;
  -----------------------------------------------------------------------------
  -- stage 2
  -----------------------------------------------------------------------------
  p_stage_2          : process (clk)
  begin
    if clk'event and clk = '1' then
      sigys_pi(0)           <= sigys * to_float(MATH_PI);
      for i in 1 to N_STAGES_SIGYS_PI-1 loop
        sigys_pi(i)         <= sigys_pi(i-1);
      end loop;  -- i
      speed(0)              <= 1.0/u0_kratio;
      for i in 1 to N_STAGES_SPEED-1 loop
        speed(i)            <= speed(i-1);
      end loop;  -- i
      tphase_s(0)           <= sin(w_tphase);
      for i in 1 to N_STAGES_TPHASE_S-1 loop
        tphase_s(i)         <= tphase_s(i-1);
      end loop;  -- i
      tphase_c(0)           <= cos(w_tphase);
      for i in 1 to N_STAGES_TPHASE_C-1 loop
        tphase_c(i)         <= tphase_c(i-1);
      end loop;  -- i
      grad                  <= tan(ang_90_con);
      vf_ang_s              <= vf_int(2) * ang_s;
      vf_ang_c              <= vf_int(2) * ang_c;
      uf_ang_s              <= uf_int(2) * ang_s;
      uf_ang_c              <= uf_int(2) * ang_c;
      w_2_tsd               <= w_square * to_float(tsd**2);
    end if;
  end process p_stage_2;
  -----------------------------------------------------------------------------
  -- stage 3
  -----------------------------------------------------------------------------
  p_stage_3          : process (clk)
  begin
    if clk'event and clk = '1' then
      udash(0)              <= vf_ang_s + uf_ang_c;
      vdash                 <= uf_ang_s + vf_ang_c;
      w_2_tsd_div           <= w_2_tsd * 0.5;
      s                     <= (8.23/60) * scale(3);
      if (ang(2) = 0.0) then
        if (uf_int(2)       <= 0.0) then
          shilb_im(0)       <= '1';     -- i
        else
          shilb_im(0)       <= '0';     -- -i
        end if;
      else
        if (vf_int(2)       <= grad) then
          shilb_im(0)       <= '1';     -- i
        else
          shilb_im(0)       <= '0';     -- -i
        end if;
      end if;
      for i in 1 to N_STAGES_SHILB-1 loop
        shilb_im(i)         <= shilb_im(i-1);
      end loop;  -- i
      for i in 1 to N_STAGES_UDASH-1 loop
        udash(i)            <= udash(i-1);
      end loop;  -- i
    end if;
  end process p_stage_3;
  -----------------------------------------------------------------------------
  -- stage 4
  -----------------------------------------------------------------------------
  p_stage_4          : process (clk)
  begin
    if clk'event and clk = '1' then
      hz                    <= speed(1) * udash(0);
      sf                    <= udash(0) * udash(0);
      s_2_pi                <= (2.0 * to_float(MATH_PI)) * s;
      vdash_s               <= vdash * sigys_pi(1);
      exp_w_2               <= exp(w_2_tsd_div);
    end if;
  end process p_stage_4;
  -----------------------------------------------------------------------------
  -- stage 5
  -----------------------------------------------------------------------------
  p_stage_5          : process (clk)
  begin
    if clk'event and clk = '1' then
      if (hz = 0.0) then
        hz_0                <= to_float(0.001);
      else
        hz_0                <= hz;
      end if;
      xc1                   <= scale(4)*(2.22/60.0);
      xc2                   <= scale(4)*(4.97/60.0);
      xs1                   <= scale(4)*(15.36/60.0);
      xs2                   <= scale(4)*(17.41/60.0);
      sf_pi2(0)             <= sf * to_float(MATH_PI*MATH_PI);
      for i in 1 to N_STAGES_SFPI2-1 loop
        sf_pi2(i)           <= sf_pi2(i-1);
      end loop;  -- i
      udash_s_pi            <= udash(1) * s_2_pi;
      vdash_sx2             <= -1.0 * (vdash_s * vdash_s);
      temp3                 <= tphase_c(2) * exp_w_2;
      tphase_exp_s          <= tphase_s(2) * exp_w_2;
    end if;
  end process p_stage_5;
  -----------------------------------------------------------------------------
  -- stage 6
  -----------------------------------------------------------------------------
  p_stage_6          : process (clk)
  begin
    if clk'event and clk = '1' then
      hz_abs                <= abs(hz_0);
      xc22                  <= xc2*xc2;
      scale_s(0)            <= sin(udash_s_pi);
      scale_c(0)            <= cos(udash_s_pi);
      xs22                  <= xs2*xs2;
      xc12                  <= xc1*xc1;
      vdash_exp             <= exp(vdash_sx2);
      xs12                  <= xs1*xs1;
      etsust_re(0)          <= temp3;
      etsust_im(0)          <= tphase_exp_s;
      for i in 1 to N_STAGES_ETSUST-1 loop
        etsust_re(i)        <= etsust_re(i-1);
        etsust_im(i)        <= etsust_im(i-1);
      end loop;  -- i
      for i in 1 to N_STAGES_SCALES-1 loop
        scale_s(i)          <= scale_s(i-1);
      end loop;  -- i
      for i in 1 to N_STAGES_SCALEC-1 loop
        scale_c(i)          <= scale_c(i-1);
      end loop;  -- i
    end if;
  end process p_stage_6;
  -----------------------------------------------------------------------------
  -- stage 7
  -----------------------------------------------------------------------------
  p_stage_7          : process (clk)
  begin
    if clk'event and clk = '1' then
      xs12_sfpi2            <= sf_pi2(1) * xs12;
      xc12_sfpi2            <= sf_pi2(1) * xc12;
      xs22_sfpi2            <= sf_pi2(1) * xs22;
      xc22_sfpi2            <= sf_pi2(1) * xc22;
      temp4(0)              <= sigys_pi(4) * vdash_exp;
      hz_kratio             <= hz_abs * to_float(kratio);
      temp6_re              <= w(6) * etsust_re(0);
      temp6_im              <= w(6) * etsust_im(0);
    end if;
  end process p_stage_7;
  -----------------------------------------------------------------------------
  -- stage 8
  -----------------------------------------------------------------------------
  p_stage_8          : process (clk)
  begin
    if clk'event and clk = '1' then
      stratio(0)            <= 1.0 / hz_kratio;
      xc22_exp              <= to_float(-1.0) * exp(xc22_sfpi2);
      xs22_exp              <= to_float(-1.0) * exp(xs22_sfpi2);
      xc12_exp              <= to_float(-1.0) * exp(xc12_sfpi2);
      xs12_exp              <= to_float(-1.0) * exp(xs12_sfpi2);
      temp7_im              <= to_float(kratio) * temp6_im;
      temp7_re              <= to_float(kratio) * temp6_re;
      for i in 1 to N_STAGES_STRATIO-1 loop
        stratio(i)          <= stratio(i-1);
      end loop;  -- i
    end if;
  end process p_stage_8;
  -----------------------------------------------------------------------------
  -- stage 9
  -----------------------------------------------------------------------------
  p_stage_9          : process (clk)
  begin
    if clk'event and clk = '1' then
      r                     <= xc22_exp * to_float(kc2);
      t                     <= xs22_exp * to_float(ks2);
      p                     <= xc12_exp * to_float(kc1);
      q                     <= xs12_exp * to_float(ks1);
      ettrans_im(0)         <= temp7_re;
      ettrans_re(0)         <= temp7_im;
      for i in 1 to N_STAGES_ETTRANS-1 loop
        ettrans_re(i)       <= ettrans_re(i-1);
        ettrans_im(i)       <= ettrans_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_9;
  -----------------------------------------------------------------------------
  -- stage 10
  -----------------------------------------------------------------------------
  p_stage_10         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_s_g             <= scale_s(3) * 1.2 * to_float(g);
      r1                    <= r - t;
      p1(0)                 <= p - q;
      for i in 1 to N_STAGES_P1-1 loop
        p1(i)               <= p1(i-1);
      end loop;  -- i 
      if thilb_re(8) = '0' then
        thilb_ettrans_im(0) <= thilb_im(8) * ettrans_re(0);
        thilb_ettrans_re(0) <= thilb_im(8) * ettrans_im(0);
      else
        thilb_ettrans_re(0) <= ettrans_re(0);
        thilb_ettrans_im(0) <= ettrans_im(0);
      end if;
      for i in 1 to N_STAGES_THILB_ETTRANS-1 loop
        thilb_ettrans_re(i) <= thilb_ettrans_re(i-1);
        thilb_ettrans_im(i) <= thilb_ettrans_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_10;
  -----------------------------------------------------------------------------
  -- stage 11
  -----------------------------------------------------------------------------
  p_stage_11         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_s_r1            <= scale_s_g * r1;
      scale_c_r1            <= scale_c(4) * r1;
      p1_square(0)          <= p1(0) * p1(0);
      for i in 1 to N_STAGES_P1SQUARE-1 loop
        p1_square(i)        <= p1_square(i-1);
      end loop;  -- i
    end if;
  end process p_stage_11;
  -----------------------------------------------------------------------------
  -- stage 12
  -----------------------------------------------------------------------------
  p_stage_12         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_SG1(0)          <= scale_s_r1 * scale_s_r1;
      for i in 1 to N_STAGES_SG1-1 loop
        scale_SG1(i)        <= scale_SG1(i-1);
      end loop;  -- i
      scale_c_p1            <= scale_c_r1 * p1(1);
    end if;
  end process p_stage_12;
  -----------------------------------------------------------------------------
  -- stage 13
  -----------------------------------------------------------------------------
  p_stage_13         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_c_p1_x2         <= scale_c_p1 + scale_c_p1;
    end if;
  end process p_stage_13;
  -----------------------------------------------------------------------------
  -- stage 14
  -----------------------------------------------------------------------------
  p_stage_14         : process (clk)
  begin
    if clk'event and clk = '1' then
      p1_square_scale_c     <= (-1.0 * scale_c_p1_x2) + p1_square(2);
    end if;
  end process p_stage_14;
  -----------------------------------------------------------------------------
  -- stage 15
  -----------------------------------------------------------------------------
  p_stage_15         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_cc              <= p1_square_scale_c + scale_c(8);
    end if;
  end process p_stage_15;
  -----------------------------------------------------------------------------
  -- stage 16
  -----------------------------------------------------------------------------
  p_stage_16         : process (clk)
  begin
    if clk'event and clk = '1' then
      temp1                 <= scale_cc * scale_cc;
    end if;
  end process p_stage_16;
  -----------------------------------------------------------------------------
  -- stage 17
  -----------------------------------------------------------------------------
  p_stage_17         : process (clk)
  begin
    if clk'event and clk = '1' then
      temp2                 <= temp1 + scale_SG1(4);
    end if;
  end process p_stage_17;
  -----------------------------------------------------------------------------
  -- stage 18
  -----------------------------------------------------------------------------
  p_stage_18         : process (clk)
  begin
    if clk'event and clk = '1' then
      tempx                 <= SQRT(temp2);
      tempy                 <= SQRT(temp4(10));
    end if;
  end process p_stage_18;
  -----------------------------------------------------------------------------
  -- stage 19
  -----------------------------------------------------------------------------
  p_stage_19         : process (clk)
  begin
    if clk'event and clk = '1' then
      espsust               <= tempx * tempy;
    end if;
  end process p_stage_19;
  -----------------------------------------------------------------------------
  -- stage 20
  -----------------------------------------------------------------------------
  p_stage_20         : process (clk)
  begin
    if clk'event and clk = '1' then
      esptrans              <= stratio(11) * espsust;
      esust_int_re(0)       <= espsust * etsust_re(13);
      esust_int_im(0)       <= espsust * etsust_im(13);
      for i in 1 to N_STAGES_ESUST_INT-1 loop
        esust_int_re(i)     <= esust_int_re(i-1);
        esust_int_im(i)     <= esust_int_im(i-1);
      end loop;  -- i     
    end if;
  end process p_stage_20;
  -----------------------------------------------------------------------------
  -- stage 21
  -----------------------------------------------------------------------------
  p_stage_21         : process (clk)
  begin
    if clk'event and clk = '1' then
      osust_int_re(0)       <= esust_int_im(0) * to_float(shilb_im(17));
      osust_int_im(0)       <= esust_int_re(0) * shilb_im(17);
      for i in 1 to N_STAGES_OSUST_INT-1 loop
        osust_int_im(i)     <= osust_int_im(i-1);
        osust_int_im(i)     <= osust_int_im(i-1);
      end loop;  -- i
      emain_im              <= esptrans * ettrans_im(11);
      emain_re              <= esptrans * ettrans_re(11);
      shilb_esptrans_im     <= esptrans * shilb_im(17);
    end if;
  end process p_stage_21;
  -----------------------------------------------------------------------------
  -- stage 22
  -----------------------------------------------------------------------------
  p_stage_22         : process (clk)
  begin
    if clk'event and clk = '1' then
      emain_neg_re          <= emain_re * to_float(-1.0);
      emain_neg_im          <= emain_im * to_float(-1.0);
      ehilb_re              <= thilb_ettrans_im * shilb_esptrans_im;
      ehilb_im              <= thilb_ettrans_re * shilb_esptrans_im;
      shilb_esptrans_im_im  <= shilb_esptrans_im + shilb_im(18);
      omain_re(0)           <= ettrans_im(12) * shilb_esptrans_im;
      omain_im(0)           <= ettrans_re(12) * shilb_esptrans_im;
      for i in 1 to N_STAGES_OMAIN-1 loop
        omain_re(i)         <= omain_re(i-1);
        omain_im(i)         <= omain_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_22;
  -----------------------------------------------------------------------------
  -- stage 23
  -----------------------------------------------------------------------------
  p_stage_23         : process (clk)
  begin
    if clk'event and clk = '1' then
      ohilb_re              <= shilb_esptrans_im_im * thilb_ettrans_im(12);
      ohilb_im              <= shilb_esptrans_im_im * thilb_ettrans_re(12);
      etrans_int_re(0)      <= -1.0 * (emain_neg_re + ehilb_re);
      etrans_int_im(0)      <= -1.0 * (emain_neg_im + ehilb_im);
      for i in 1 to N_STAGES_ETRANS_INT-1 loop
        etrans_int_im(i)    <= etrans_int_im(i-1);
        etrans_int_re(i)    <= etrans_int_re(i-1);
      end loop;  -- i
    end if;
  end process p_stage_23;
  -----------------------------------------------------------------------------
  -- stage 24
  -----------------------------------------------------------------------------
  p_stage_24         : process (clk)
  begin
    if clk'event and clk = '1' then
      otrans_int_re         <= -1.0 * (ohilb_re + omain_re(1));
      otrans_int_im         <= -1.0 * (ohilb_im + omain_im(1));
    end if;
  end process p_stage_24;




  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- float32 signals converted to real for simulation only  -------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --synthesis translate_off
  u0_real    <= To_real(u0);
  sigys_real <= To_real(sigys);
  scale_real <= To_real(scale(0));
  speed_real <= To_real(speed(0));
  ang_real   <= To_real(ang(0));
  grad_real  <= To_real(grad);
  --synthesis translate_on




end Behavioral;
