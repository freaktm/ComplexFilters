library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.float_pkg.all;
use ieee.math_real.all;


entity sqrt is

  port (
    clk       : in  std_logic;
    val_out : out float32;
    val_in  : in  float32    
    );

end sqrt;


architecture Behavioral of sqrt is


  
  -----------------------------------------------------------------------------
  -- constants
  -----------------------------------------------------------------------------
  type float_vec is array (natural range <>) of float32;
  constant N_TAYLOR_LENGTH    : integer := 9;
  type series_arr is array (natural range <>) of float32;
  CONSTANT sqrt_r : series_arr := (  
  to_float(0.5),
  to_float(0.125),
  to_float(0.0625),
  to_float(0.0390625),
  to_float(0.02734375),
  to_float(0.020507812),
  to_float(0.016113281),
  to_float(0.013092041),  
  to_float(0.010910034),
  to_float(34459425.0/3715891200.0),
  to_float(0.0),
  to_float(0.0),
  to_float(0.0),
  to_float(0.0),
  to_float(0.0)  
  );

  -----------------------------------------------------------------------------
  -- value signals
  -----------------------------------------------------------------------------
  signal currentVal            : float_vec(N_TAYLOR_LENGTH+1 downto 2);
  signal val_pow            : float_vec(N_TAYLOR_LENGTH-1 downto 1);
  signal val_org            : float_vec(N_TAYLOR_LENGTH+1 downto 0);
  signal taylor_data          : float_vec(N_TAYLOR_LENGTH-1 downto 0);
  signal val_in_i : float32;
  signal val_out_i : float32;
  signal val_y : float_vec(N_TAYLOR_LENGTH*2 downto 0);
  
  --synthesis translate_off
  signal value_real        : real;
  --synthesis translate_on


begin  -- Behavioral 


  -----------------------------------------------------------------------------
  -- input/output signals
  -----------------------------------------------------------------------------
  p_data_registers  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_in_i <= val_in;
      val_out <= val_out_i;
    end if;
  end process p_data_registers;
  
    -----------------------------------------------------------------------------
  -- stage 0
  -----------------------------------------------------------------------------
  p_stage_0  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_out_i <= 1 + currentVal(N_TAYLOR_LENGTH+1);
      val_org(0) <= val_in_i; -- initial value of x
      val_y(0) <= val_in_i-1; -- x-1 array (y)
      for i in 1 to N_TAYLOR_LENGTH+1 loop -- update val_y and val_org arrays
        val_org(i)           <= val_org(i-1); 
        val_y(i)           <= val_y(i-1);               
      end loop;  -- i   
    end if;
  end process p_stage_0;

  -----------------------------------------------------------------------------
  -- stage 1
  -----------------------------------------------------------------------------
  p_stage_1        : process (clk)  
  begin
    if clk'event and clk = '1' then
      val_pow(1)<= val_y(0)*val_y(0); -- compute y squared
      taylor_data(0) <= sqrt_r(0)*val_y(0); -- 0.5 times y 
    end if;
  end process p_stage_1;
  
  -----------------------------------------------------------------------------
  -- stage 2
  -----------------------------------------------------------------------------
  p_stage_2  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_pow(2)<= val_pow(1)*val_y(1); -- compute y to 3
      taylor_data(1) <= sqrt_r(1)*val_pow(1); -- compute 2nd degree
      currentVal(2) <= 1.0 + taylor_data(0); -- 1st degree of series
    end if;
  end process p_stage_2;
  
    -----------------------------------------------------------------------------
  -- stage 3
  -----------------------------------------------------------------------------
  p_stage_3        : process (clk)  
  begin
    if clk'event and clk = '1' then
      val_pow(3)<= val_pow(2)*val_y(2); -- compute y to 4
      taylor_data(2) <= sqrt_r(2)*val_pow(2); -- compute 3rd degree
      currentVal(3) <= currentVal(2) - taylor_data(1); -- 2nd degree of series
    end if;
  end process p_stage_3;
  
  -----------------------------------------------------------------------------
  -- stage 4
  -----------------------------------------------------------------------------
  p_stage_4  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_pow(4)<= val_pow(3)*val_y(3); -- compute y to 5
      taylor_data(3) <= sqrt_r(3)*val_pow(3); -- compute 4th degree
      currentVal(4) <= currentVal(3) + taylor_data(2); -- 3rd degree of series
    end if;
  end process p_stage_4;
  
  
  
    -----------------------------------------------------------------------------
  -- stage 5
  -----------------------------------------------------------------------------
  p_stage_5  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_pow(5)<= val_pow(4)*val_y(4); -- compute y to 6
      taylor_data(4) <= sqrt_r(4)*val_pow(4); -- compute 5th degree
      currentVal(5) <= currentVal(4) - taylor_data(3); -- 4th degree of series
    end if;
  end process p_stage_5;
  
  
    -----------------------------------------------------------------------------
  -- stage 6
  -----------------------------------------------------------------------------
  p_stage_6  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_pow(6)<= val_pow(5)*val_y(5); -- compute y to 7
      taylor_data(5) <= sqrt_r(5)*val_pow(5); -- compute 6th degree
      currentVal(6) <= currentVal(5) + taylor_data(4); -- 5th degree of series
    end if;
  end process p_stage_6;
  
    -----------------------------------------------------------------------------
  -- stage 7
  -----------------------------------------------------------------------------
  p_stage_7  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_pow(7)<= val_pow(6)*val_y(6); -- compute y to 8
      taylor_data(6) <= sqrt_r(6)*val_pow(6); -- compute 7th degree
      currentVal(7) <= currentVal(6) - taylor_data(5); -- 6th degree of series
    end if;
  end process p_stage_7;
  
    -----------------------------------------------------------------------------
  -- stage 8
  -----------------------------------------------------------------------------
  p_stage_8  : process (clk)
  begin
    if clk'event and clk = '1' then
      val_pow(8)<= val_pow(7)*val_y(7); -- compute y to 9
      taylor_data(7) <= sqrt_r(7)*val_pow(7); -- compute 8th degree
      currentVal(8) <= currentVal(7) + taylor_data(6); -- 7th degree of series
    end if;
  end process p_stage_8;

  
    -----------------------------------------------------------------------------
  -- stage 9
  -----------------------------------------------------------------------------
  p_stage_9        : process (clk)  
  begin
    if clk'event and clk = '1' then
      taylor_data(8) <= sqrt_r(8)*val_pow(8); -- compute 10th degree
      currentVal(9) <= currentVal(8) - taylor_data(7); -- 9th degree of series
    end if;
  end process p_stage_9;
  
  -----------------------------------------------------------------------------
  -- stage 10
  -----------------------------------------------------------------------------
  p_stage_10  : process (clk)
  begin
    if clk'event and clk = '1' then
      currentVal(10) <= currentVal(9) + taylor_data(8); -- 9th degree of series
    end if;
  end process p_stage_10;
  
  
  --synthesis translate_off
  value_real    <= To_real(currentVal(N_TAYLOR_LENGTH+1));
  --synthesis translate_on

end Behavioral;





