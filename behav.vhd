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
    mtspeed   : in  real
    );

end filters;


architecture Behavioral of filters is


  -----------------------------------------------------------------------------
  -- constants
  -----------------------------------------------------------------------------
  constant nframes   : real := 8.0;
  constant xsize     : real := 128.0;
  constant peakhz    : real := 4.0;
  constant aspect    : real := 1.0;
  constant umax      : real := 20.0;
  constant kratio    : real    := 0.25;
  constant angconv   : real    := 6.4;
  constant tsd       : real    := 0.22;
  constant tphase    : real    := 0.1;
  constant ysize     : real := xsize;
  constant deltu     : real := (2.0*umax)/xsize;
  constant thalf     : real := nframes/2.0;
  constant maxrate   : real := 20.0;
  constant wInterval : real    := maxrate/thalf;
  constant con       : real := MATH_PI / 180.0;
  constant kc1       : real := 43.0;
  constant con_90    : real := con * 90.0;
  constant kc2       : real := 41.0;
  constant ks1       : real := 43.0;
  constant ks2       : real := kc2+ks1-kc1;
  constant g         : real    := 0.25;


  -----------------------------------------------------------------------------
  -- Array signals length definition
  -----------------------------------------------------------------------------
  type float_vec is array (natural range <>) of real;
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
  signal uf_int            : float_vec(N_STAGES_UF-1 downto 0);
  signal vf_int            : float_vec(N_STAGES_VF-1 downto 0);
  signal ang               : float_vec(N_STAGES_ANG-1 downto 0);
  signal scale             : float_vec(N_STAGES_SCALE-1 downto 0);
  signal w                 : float_vec(N_STAGES_W-1 downto 0);
  signal thilb_im_temp     : real;
  signal u0                : real;
  -----------------------------------------------------------------------------
  -- stage 1 signals
  -----------------------------------------------------------------------------
  signal thilb_im          : float_vec(N_STAGES_THILB-1 downto 0);
  signal thilb_re          : std_logic_vector(N_STAGES_THILB-1 downto 0);
  signal u0_kratio         : real;
  signal ang_s             : real;
  signal ang_c             : real;
  signal ang_90_con        : real;
  signal sigys             : real;
  signal w_square          : real;
  signal w_tphase          : real;
  -----------------------------------------------------------------------------
  -- stage 2 signals
  -----------------------------------------------------------------------------
  signal speed             : float_vec(N_STAGES_SPEED-1 downto 0);
  signal vf_ang_c          : real;
  signal vf_ang_s          : real;
  signal uf_ang_c          : real;
  signal uf_ang_s          : real;
  signal grad              : real;
  signal sigys_pi          : float_vec(N_STAGES_SIGYS_PI-1 downto 0);
  signal w_2_tsd           : real;
  signal tphase_s          : float_vec(N_STAGES_TPHASE_S-1 downto 0);
  signal tphase_c          : float_vec(N_STAGES_TPHASE_C-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 3 signals
  -----------------------------------------------------------------------------
  signal shilb_im          : std_logic_vector(N_STAGES_SHILB-1 downto 0);
  signal udash             : float_vec(N_STAGES_UDASH-1 downto 0);
  signal vdash             : real;
  signal w_2_tsd_div       : real;
  signal s                 : real;
  -----------------------------------------------------------------------------
  -- stage 4 signals
  -----------------------------------------------------------------------------
  signal hz                : real;
  signal sf                : real;
  signal s_2_pi            : real;
  signal vdash_s           : real;
  signal exp_w_2           : real;
  -----------------------------------------------------------------------------
  -- stage 5 signals
  -----------------------------------------------------------------------------
  signal xc1               : real;
  signal xc2               : real;
  signal xs1               : real;
  signal xs2               : real;
  signal hz_0              : real;
  signal sf_pi2            : float_vec(N_STAGES_SFPI2-1 downto 0);
  signal udash_s_pi        : real;
  signal vdash_sx2         : real;
  signal temp3             : real;
  signal tphase_exp_s      : real;
  -----------------------------------------------------------------------------
  -- stage 6 signals
  -----------------------------------------------------------------------------
  signal hz_abs            : real;
  signal xc22              : real;
  signal scale_s           : float_vec(N_STAGES_SCALES-1 downto 0);
  signal scale_c           : float_vec(N_STAGES_SCALEC-1 downto 0);
  signal xs22              : real;
  signal xc12              : real;
  signal vdash_exp         : real;
  signal xs12              : real;
  signal etsust_re         : float_vec(N_STAGES_ETSUST-1 downto 0);
  signal etsust_im         : float_vec(N_STAGES_ETSUST-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 7 signals
  -----------------------------------------------------------------------------
  signal xs12_sfpi2        : real;
  signal xc12_sfpi2        : real;
  signal xs22_sfpi2        : real;
  signal xc22_sfpi2        : real;
  signal temp4             : float_vec(N_STAGES_TEMP4-1 downto 0);
  signal hz_kratio         : real;
  signal temp6_re          : real;
  signal temp6_im          : real;
  -----------------------------------------------------------------------------
  -- stage 8 signals
  -----------------------------------------------------------------------------
  signal stratio           : float_vec(N_STAGES_STRATIO-1 downto 0);
  signal xc22_exp          : real;
  signal xs22_exp          : real;
  signal xc12_exp          : real;
  signal xs12_exp          : real;
  signal temp7_im          : real;
  signal temp7_re          : real;
  -----------------------------------------------------------------------------
  -- stage 9 signals
  -----------------------------------------------------------------------------
  signal r                 : real;
  signal t                 : real;
  signal p                 : real;
  signal q                 : real;
  signal ettrans_re        : float_vec(N_STAGES_ETTRANS-1 downto 0);
  signal ettrans_im        : float_vec(N_STAGES_ETTRANS-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 10 signals
  -----------------------------------------------------------------------------
  signal scale_s_g         : real;
  signal r1                : real;
  signal p1                : float_vec(N_STAGES_P1-1 downto 0);
  signal thilb_ettrans_re  : float_vec(N_STAGES_THILB_ETTRANS-1 downto 0);
  signal thilb_ettrans_im  : float_vec(N_STAGES_THILB_ETTRANS-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 11 signals
  -----------------------------------------------------------------------------
  signal scale_s_r1        : real;
  signal scale_c_r1        : real;
  signal p1_square         : float_vec(N_STAGES_P1SQUARE-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 12 signals
  -----------------------------------------------------------------------------
  signal scale_SG1         : float_vec(N_STAGES_SG1-1 downto 0);
  signal scale_c_p1        : real;
  -----------------------------------------------------------------------------
  -- stage 13 signals
  -----------------------------------------------------------------------------
  signal scale_c_p1_x2     : real;
  -----------------------------------------------------------------------------
  -- stage 14 signals
  -----------------------------------------------------------------------------
  signal p1_square_scale_c : real;
  -----------------------------------------------------------------------------
  -- stage 15 signals
  -----------------------------------------------------------------------------
  signal scale_cc          : real;
  -----------------------------------------------------------------------------
  -- stage 16 signals
  -----------------------------------------------------------------------------
  signal temp1             : real;
  -----------------------------------------------------------------------------
  -- stage 17 signals
  -----------------------------------------------------------------------------
  signal temp2             : real;
  -----------------------------------------------------------------------------
  -- stage 18 signals
  -----------------------------------------------------------------------------
  signal tempx             : real;
  signal tempy             : real;
  -----------------------------------------------------------------------------
  -- stage 19 signals
  -----------------------------------------------------------------------------
  signal espsust           : real;
  -----------------------------------------------------------------------------
  -- stage 20 signals
  -----------------------------------------------------------------------------
  signal esust_int_re      : float_vec(N_STAGES_ESUST_INT-1 downto 0);
  signal esust_int_im      : float_vec(N_STAGES_ESUST_INT-1 downto 0);
  signal esptrans          : real;
  -----------------------------------------------------------------------------
  -- stage 21 signals
  -----------------------------------------------------------------------------
  signal osust_int_re      : float_vec(N_STAGES_OSUST_INT-1 downto 0);
  signal osust_int_im      : float_vec(N_STAGES_OSUST_INT-1 downto 0);
  signal shilb_esptrans_im : real;
  signal emain_im          : real;
  signal emain_re          : real;
  -----------------------------------------------------------------------------
  -- stage 22 signals
  -----------------------------------------------------------------------------
  signal emain_neg_im      : real;
  signal emain_neg_re      : real;
  signal ehilb_im          : real;
  signal ehilb_re          : real;
  signal shilb_esptrans_re : real;
  signal omain_re          : float_vec(N_STAGES_OMAIN-1 downto 0);
  signal omain_im          : float_vec(N_STAGES_OMAIN-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 23 signals
  -----------------------------------------------------------------------------
  signal ohilb_im          : real;
  signal ohilb_re          : real;
  signal etrans_int_im     : float_vec(N_STAGES_ETRANS_INT-1 downto 0);
  signal etrans_int_re     : float_vec(N_STAGES_ETRANS_INT-1 downto 0);
  -----------------------------------------------------------------------------
  -- stage 24 signals
  -----------------------------------------------------------------------------
  signal otrans_int_re     : real;
  signal otrans_int_im     : real;
  -----------------------------------------------------------------------------
  -- output signals
  -----------------------------------------------------------------------------
  signal etrans_im_int     : real;
  signal etrans_re_int     : real;
  signal otrans_re_int     : real;
  signal otrans_im_int     : real;
  -----------------------------------------------------------------------------
  -- input signals
  -----------------------------------------------------------------------------
  signal uf_i              : real;
  signal vf_i              : real;
  signal wf_int            : real;
  signal theta_int         : real;
  signal oeval_int         : real;
  signal stval_int         : real;
  signal mtspeed_int       : real;





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
      u0                    <= peakhz/mtspeed_int;
      thilb_im_temp         <= SIGN(wf_int);
      w(0)                  <= wInterval * wf_int;
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
      scale(0)              <= mtspeed_int*(3.0/peakhz);
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
      sigys                 <= (1.4 * aspect)/u0;
      u0_kratio             <= kratio * u0;
      ang_s                 <= sin(ang(0));
      ang_c                 <= cos(ang(0));
      ang_90_con            <= con_90 + ang(0);
      w_square              <= w(0)*w(0);
      w_tphase              <= w(0) * (2.0*MATH_PI*tphase);
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
      sigys_pi(0)           <= sigys * MATH_PI;
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
      w_2_tsd               <= w_square * tsd**2;
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
          shilb_im(0)       <= '0';     -- i
        else
          shilb_im(0)       <= '1';     -- -i
        end if;
      else
        if (vf_int(2)       <= grad) then
          shilb_im(0)       <= '0';     -- i
        else
          shilb_im(0)       <= '1';     -- -i
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
      s_2_pi                <= (2.0 * MATH_PI) * s;
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
        hz_0                <= 0.001;
      else
        hz_0                <= hz;
      end if;
      xc1                   <= scale(4)*(2.22/60.0);
      xc2                   <= scale(4)*(4.97/60.0);
      xs1                   <= scale(4)*(15.36/60.0);
      xs2                   <= scale(4)*(17.41/60.0);
      sf_pi2(0)             <= sf * MATH_PI*MATH_PI;
      for i in 1 to N_STAGES_SFPI2-1 loop
        sf_pi2(i)           <= sf_pi2(i-1);
      end loop;  -- i
      udash_s_pi            <= udash(1) * s_2_pi;
      vdash_sx2             <= -(vdash_s * vdash_s);
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
      hz_kratio             <= hz_abs * kratio;
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
      xc22_exp              <= -(exp(xc22_sfpi2));
      xs22_exp              <= -(exp(xs22_sfpi2));
      xc12_exp              <= -(exp(xc12_sfpi2));
      xs12_exp              <= -(exp(xs12_sfpi2));
      temp7_im              <= kratio * temp6_im;
      temp7_re              <= kratio * temp6_re;
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
      r                     <= xc22_exp * kc2;
      t                     <= xs22_exp * ks2;
      p                     <= xc12_exp * kc1;
      q                     <= xs12_exp * ks1;
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
      scale_s_g             <= scale_s(3) * 1.2 * g;
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
      p1_square_scale_c     <= -scale_c_p1_x2 + p1_square(2);
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
  -- stage 21        FIX SHILB, REMOVE MULTIPLYER
  -----------------------------------------------------------------------------
  p_stage_21         : process (clk)
  begin
    if clk'event and clk = '1' then
      if shilb_im(17) = '1' then
        osust_int_re(0)     <= -esust_int_im(0);
        osust_int_im(0)     <= -esust_int_re(0);
        shilb_esptrans_im   <= -esptrans;
      else
        osust_int_re(0)     <= esust_int_im(0);
        osust_int_im(0)     <= esust_int_re(0);
        shilb_esptrans_im   <= esptrans;
      end if;
      emain_im              <= esptrans * ettrans_im(11);
      emain_re              <= esptrans * ettrans_re(11);
      for i in 1 to N_STAGES_OSUST_INT-1 loop
        osust_int_im(i)     <= osust_int_im(i-1);
        osust_int_im(i)     <= osust_int_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_21;
  -----------------------------------------------------------------------------
  -- stage 22        FIX SHILB, how to add a i or -i to an imaginary number
  -----------------------------------------------------------------------------
  p_stage_22         : process (clk)
  begin
    if clk'event and clk = '1' then
      if shilb_im(18) = '1' then
        shilb_esptrans_re   <= -shilb_esptrans_im;
      else
        shilb_esptrans_re   <= shilb_esptrans_im;
      end if;
      emain_neg_re          <= -emain_re;
      emain_neg_im          <= -emain_im;
      ehilb_re              <= thilb_ettrans_im(11) * shilb_esptrans_im;
      ehilb_im              <= thilb_ettrans_re(11) * shilb_esptrans_im;
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
      ohilb_re              <= shilb_esptrans_re * thilb_ettrans_re(12);
      ohilb_im              <= shilb_esptrans_re * thilb_ettrans_im(12);
      etrans_int_re(0)      <= -(emain_neg_re + ehilb_re);
      etrans_int_im(0)      <= -(emain_neg_im + ehilb_im);
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
      otrans_int_re         <= -(ohilb_re + omain_re(1));
      otrans_int_im         <= -(ohilb_im + omain_im(1));
    end if;
  end process p_stage_24;







end Behavioral;
