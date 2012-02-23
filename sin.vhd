library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.float_pkg.all;
use ieee.math_real.all;


entity sin is

  port (
    clk       : in  std_logic;
    theta_out : out float32;
    theta_in  : in  float32    
    );

end sin;


architecture Behavioral of sin is


  
  -----------------------------------------------------------------------------
  -- constants
  -----------------------------------------------------------------------------
  type float_vec is array (natural range <>) of float32;
  constant fact3   : float32 := to_float(1.0/6.0);
  constant fact5   : float32 := to_float(1.0/120.0);
  constant fact7   : float32 := to_float(1.0/5040.0);
  constant fact9   : float32 := to_float(1.0/362880.0);
  constant fact11  : float32 := to_float(1.0/39916800.0);
  constant N_STAGES_THETA     : integer := 11;
  constant N_TAYLOR_LENGTH    : integer := 5;


  -----------------------------------------------------------------------------
  -- theta signals
  -----------------------------------------------------------------------------
  signal theta_val            : float_vec(N_STAGES_THETA downto 0);
  signal theta_pow            : float_vec(N_STAGES_THETA-2 downto 0);
  signal theta_org            : float_vec(N_STAGES_THETA downto 0);
  signal taylor_data          : float_vec(N_TAYLOR_LENGTH-1 downto 0);
  
  --synthesis translate_off
  signal theta_real        : real;
  signal fact3_r : real;
  signal fact5_r : real;
  signal fact7_r : real;
  signal fact9_r : real;
  signal fact11_r : real;
  --synthesis translate_on

begin  -- Behavioral
  -----------------------------------------------------------------------------
  -- input/output signals
  -----------------------------------------------------------------------------
  p_data_registers  : process (clk)
  begin
    if clk'event and clk = '1' then
      theta_out <= theta_val(N_STAGES_THETA);
      theta_org(0) <= theta_in;    
      for i in 1 to N_STAGES_THETA loop
        theta_org(i)           <= theta_org(i-1);
      end loop;  -- i   
    end if;
  end process p_data_registers;
  -----------------------------------------------------------------------------
  -- power series signals
  -----------------------------------------------------------------------------
  p_power_series  : process (clk)
  begin
    if clk'event and clk = '1' then
      theta_pow(0)  <= theta_in*theta_in; 
      for i in 1 to N_STAGES_THETA-2 loop
        theta_pow(i)           <= theta_pow(i-1) * theta_org(i-1);
      end loop;  -- i
    end if;
  end process p_power_series;
  
  -----------------------------------------------------------------------------
  -- stage 0
  -----------------------------------------------------------------------------
  p_stage_0        : process (clk)  
  begin
    if clk'event and clk = '1' then
    theta_val(0) <= theta_in;    
    end if;
  end process p_stage_0;
  
    -----------------------------------------------------------------------------
  -- stage 1
  -----------------------------------------------------------------------------
  p_stage_1        : process (clk)  
  begin
    if clk'event and clk = '1' then
    theta_val(1) <= theta_val(0);    
    end if;
  end process p_stage_1;
  
    -----------------------------------------------------------------------------
  -- stage 2
  -----------------------------------------------------------------------------
  p_stage_2        : process (clk)  
  begin
    if clk'event and clk = '1' then
      theta_val(2) <= theta_val(1);
    taylor_data(0) <= theta_pow(1) * fact3;    
    end if;
  end process p_stage_2;
  
      -----------------------------------------------------------------------------
  -- stage 3
  -----------------------------------------------------------------------------
  p_stage_3        : process (clk)  
  begin
    if clk'event and clk = '1' then
    theta_val(3) <= theta_val(2) - taylor_data(0);    
    end if;
  end process p_stage_3;
  
      -----------------------------------------------------------------------------
  -- stage 4
  -----------------------------------------------------------------------------
  p_stage_4        : process (clk)  
  begin
    if clk'event and clk = '1' then
      theta_val(4) <= theta_val(3);
    taylor_data(1) <= theta_pow(3) * fact5;    
    end if;
  end process p_stage_4;
  
    
      -----------------------------------------------------------------------------
  -- stage 5
  -----------------------------------------------------------------------------
  p_stage_5        : process (clk)  
  begin
    if clk'event and clk = '1' then
    theta_val(5) <= theta_val(4) + taylor_data(1);    
    end if;
  end process p_stage_5;
  
      -----------------------------------------------------------------------------
  -- stage 6
  -----------------------------------------------------------------------------
  p_stage_6        : process (clk)  
  begin
    if clk'event and clk = '1' then
      theta_val(6) <= theta_val(5);
    taylor_data(2) <= theta_pow(5) * fact7;    
    end if;
  end process p_stage_6;
  
    
      -----------------------------------------------------------------------------
  -- stage 7
  -----------------------------------------------------------------------------
  p_stage_7        : process (clk)  
  begin
    if clk'event and clk = '1' then
    theta_val(7) <= theta_val(6) - taylor_data(2);    
    end if;
  end process p_stage_7;
  
      -----------------------------------------------------------------------------
  -- stage 8
  -----------------------------------------------------------------------------
  p_stage_8        : process (clk)  
  begin
    if clk'event and clk = '1' then
      theta_val(8) <= theta_val(7);
    taylor_data(3) <= theta_pow(7) * fact9;    
    end if;
  end process p_stage_8;
  
    
      -----------------------------------------------------------------------------
  -- stage 9
  -----------------------------------------------------------------------------
  p_stage_9        : process (clk)  
  begin
    if clk'event and clk = '1' then
    theta_val(9) <= theta_val(8) + taylor_data(3);    
    end if;
  end process p_stage_9;
  
      -----------------------------------------------------------------------------
  -- stage 10
  -----------------------------------------------------------------------------
  p_stage_10        : process (clk)  
  begin
    if clk'event and clk = '1' then
      theta_val(10) <= theta_val(9);
    taylor_data(4) <= theta_pow(9) * fact11;    
    end if;
  end process p_stage_10;
  
  
          -----------------------------------------------------------------------------
  -- stage 11
  -----------------------------------------------------------------------------
  p_stage_11        : process (clk)  
  begin
    if clk'event and clk = '1' then
    theta_val(11) <= theta_val(10) - taylor_data(4);     
    end if;
  end process p_stage_11;


  --synthesis translate_off
  theta_real    <= To_real(theta_val(11));
  fact3_r <= To_real(fact3);
  fact5_r <= To_real(fact5);
  fact7_r <= To_real(fact7);
  fact9_r <= To_real(fact9);
  fact11_r <= To_real(fact11);
  --synthesis translate_on

end Behavioral;

