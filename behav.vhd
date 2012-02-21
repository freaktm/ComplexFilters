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
  signal u0                : real := 0.0;  
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
  signal w_square          : real := 0.0;
  signal w_tphase          : real := 0.0;
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
  signal uf_i              : real := 1.0;
  signal vf_i              : real := 1.0;
  signal wf_i              : real := 1.0;
  signal theta_int         : real := 1.0;
  signal oeval_int         : real := 1.0;
  signal stval_int         : real := 1.0;
  signal mtspeed_int       : real := 1.0;





begin  -- Behavioral
  -----------------------------------------------------------------------------
  -- input stage
  -----------------------------------------------------------------------------
  p_input_registers  : process (clk)
  begin
    if clk'event and clk = '1' then
      uf_i                  <= uf;
      vf_i                  <= vf;
      wf_i                  <= wf;
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
      thilb_im_temp         <= SIGN(wf_i);
     w(0)                   <= wInterval * wf_i;
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






end Behavioral;
