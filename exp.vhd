library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.float_pkg.all;
use ieee.math_real.all;


entity exp is

  port (
    clk       : in  std_logic;
    val_out : out float32;
    val_in  : in  float32    
    );

end exp;


architecture Behavioral of exp is


  
  -----------------------------------------------------------------------------
  -- constants
  -----------------------------------------------------------------------------
  type float_vec is array (natural range <>) of float32;
  constant N_TAYLOR_LENGTH    : integer := 15;
  type factorial_arr is array (natural range <>) of float32;
  CONSTANT fact_r : factorial_arr := (  
  to_float(0.5),
  to_float(1.0/6.0),
  to_float(1.0/24.0),
  to_float(1.0/120.0),
  to_float(1.0/720.0),
  to_float(1.0/5040.0),
  to_float(1.0/40320.0),
  to_float(1.0/362880.0),  
  to_float(1.0/3628800),
  to_float(1.0/39916800),
  to_float(1.0/479001600.0),
  to_float(1.0/6227020800.0),
  to_float(1.0/87178291200.0),
  to_float(1.0/1307674368000.0),
  to_float(1.0/20922789888000.0)  
  );

  -----------------------------------------------------------------------------
  -- value signals
  -----------------------------------------------------------------------------
  signal currentVal            : float_vec(N_TAYLOR_LENGTH*2 downto 0);
  signal val_pow            : float_vec(N_TAYLOR_LENGTH*2 downto 0);
  signal val_org            : float_vec(N_TAYLOR_LENGTH*2 downto 0);
  signal taylor_data          : float_vec(N_TAYLOR_LENGTH-1 downto 0);
  signal val_in_i : float32;
  signal val_out_i : float32;
  
  --synthesis translate_off
  signal value_real        : real;
  signal value_org : real;
  signal value_start : real;
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
      val_out_i <= 1 + currentVal(30);
      currentVal(0) <= val_in_i;
      val_org(0) <= val_in_i;   
      val_pow(0)  <= val_in_i*val_in_i;  
      for i in 1 to N_TAYLOR_LENGTH*2 loop
        val_org(i)           <= val_org(i-1);
      end loop;  -- i   
    end if;
  end process p_stage_0;

  -----------------------------------------------------------------------------
  -- stage 1
  -----------------------------------------------------------------------------
  p_stage_1        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(1) <= currentVal(0);
      val_pow(1)<= val_pow(0);
      taylor_data(0) <= fact_r(0)*val_pow(0); 
    end if;
  end process p_stage_1;
  
  -----------------------------------------------------------------------------
  -- stage 2
  -----------------------------------------------------------------------------
  p_stage_2  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(2) <= taylor_data(0)+currentVal(1);
      val_pow(2)<= val_pow(1)*val_org(1);
    end if;
  end process p_stage_2;
  
    -----------------------------------------------------------------------------
  -- stage 3
  -----------------------------------------------------------------------------
  p_stage_3        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(3) <= currentVal(2);
      val_pow(3)<= val_pow(2);
      taylor_data(1) <= fact_r(1)*val_pow(2); 
    end if;
  end process p_stage_3;
  
  -----------------------------------------------------------------------------
  -- stage 4
  -----------------------------------------------------------------------------
  p_stage_4  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(4) <= taylor_data(1)+currentVal(3);
      val_pow(4)<= val_pow(3)*val_org(3);
    end if;
  end process p_stage_4;
  
    -----------------------------------------------------------------------------
  -- stage 5
  -----------------------------------------------------------------------------
  p_stage_5        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(5) <= currentVal(4);
      val_pow(5)<= val_pow(4);
      taylor_data(2) <= fact_r(2)*val_pow(4); 
    end if;
  end process p_stage_5;
  
  -----------------------------------------------------------------------------
  -- stage 6
  -----------------------------------------------------------------------------
  p_stage_6  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(6) <= taylor_data(2)+currentVal(5);
      val_pow(6)<= val_pow(5)*val_org(5);
    end if;
  end process p_stage_6;
  
  -----------------------------------------------------------------------------
  -- stage 7
  -----------------------------------------------------------------------------
  p_stage_7        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(7) <= currentVal(6);
      val_pow(7)<= val_pow(6);
      taylor_data(3) <= fact_r(3)*val_pow(6); 
    end if;
  end process p_stage_7;
  
  -----------------------------------------------------------------------------
  -- stage 8
  -----------------------------------------------------------------------------
  p_stage_8  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(8) <= taylor_data(3)+currentVal(7);
      val_pow(8)<= val_pow(7)*val_org(7);
    end if;
  end process p_stage_8;
  
    -----------------------------------------------------------------------------
  -- stage 9
  -----------------------------------------------------------------------------
  p_stage_9        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(9) <= currentVal(8);
      val_pow(9)<= val_pow(8);
      taylor_data(4) <= fact_r(4)*val_pow(8); 
    end if;
  end process p_stage_9;
  
  -----------------------------------------------------------------------------
  -- stage 8
  -----------------------------------------------------------------------------
  p_stage_10  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(10) <= taylor_data(4)+currentVal(9);
      val_pow(10)<= val_pow(9)*val_org(9);
    end if;
  end process p_stage_10;
  
    -----------------------------------------------------------------------------
  -- stage 11
  -----------------------------------------------------------------------------
  p_stage_11        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(11) <= currentVal(10);
      val_pow(11)<= val_pow(10);
      taylor_data(5) <= fact_r(5)*val_pow(10); 
    end if;
  end process p_stage_11;
  
  -----------------------------------------------------------------------------
  -- stage 12
  -----------------------------------------------------------------------------
  p_stage_12  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(12) <= taylor_data(5)+currentVal(11);
      val_pow(12)<= val_pow(11)*val_org(11);
    end if;
  end process p_stage_12;
  
      -----------------------------------------------------------------------------
  -- stage 13
  -----------------------------------------------------------------------------
  p_stage_13        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(13) <= currentVal(12);
      val_pow(13)<= val_pow(12);
      taylor_data(6) <= fact_r(6)*val_pow(12); 
    end if;
  end process p_stage_13;
  
  -----------------------------------------------------------------------------
  -- stage 12
  -----------------------------------------------------------------------------
  p_stage_14  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(14) <= taylor_data(6)+currentVal(13);
      val_pow(14)<= val_pow(13)*val_org(13);
    end if;
  end process p_stage_14;
  
      -----------------------------------------------------------------------------
  -- stage 15
  -----------------------------------------------------------------------------
  p_stage_15        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(15) <= currentVal(14);
      val_pow(15)<= val_pow(14);
      taylor_data(7) <= fact_r(7)*val_pow(14); 
    end if;
  end process p_stage_15;
  
  -----------------------------------------------------------------------------
  -- stage 16
  -----------------------------------------------------------------------------
  p_stage_16  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(16) <= taylor_data(7)+currentVal(15);
      val_pow(16)<= val_pow(15)*val_org(15);
    end if;
  end process p_stage_16;
  
      -----------------------------------------------------------------------------
  -- stage 17
  -----------------------------------------------------------------------------
  p_stage_17        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(17) <= currentVal(16);
      val_pow(17)<= val_pow(16);
      taylor_data(8) <= fact_r(8)*val_pow(16); 
    end if;
  end process p_stage_17;
  
  -----------------------------------------------------------------------------
  -- stage 18
  -----------------------------------------------------------------------------
  p_stage_18  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(18) <= taylor_data(8)+currentVal(17);
      val_pow(18)<= val_pow(17)*val_org(17);
    end if;
  end process p_stage_18;
  
      -----------------------------------------------------------------------------
  -- stage 19
  -----------------------------------------------------------------------------
  p_stage_19        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(19) <= currentVal(18);
      val_pow(19)<= val_pow(18);
      taylor_data(9) <= fact_r(9)*val_pow(18); 
    end if;
  end process p_stage_19;
  
  -----------------------------------------------------------------------------
  -- stage 20
  -----------------------------------------------------------------------------
  p_stage_20  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(20) <= taylor_data(9)+currentVal(19);
      val_pow(20)<= val_pow(19)*val_org(19);
    end if;
  end process p_stage_20;

      -----------------------------------------------------------------------------
  -- stage 21
  -----------------------------------------------------------------------------
  p_stage_21        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(21) <= currentVal(20);
      val_pow(21)<= val_pow(20);
      taylor_data(10) <= fact_r(10)*val_pow(20); 
    end if;
  end process p_stage_21;
  
  -----------------------------------------------------------------------------
  -- stage 22
  -----------------------------------------------------------------------------
  p_stage_22  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(22) <= taylor_data(10)+currentVal(21);
      val_pow(22)<= val_pow(21)*val_org(21);
    end if;
  end process p_stage_22;

 
      -----------------------------------------------------------------------------
  -- stage 23
  -----------------------------------------------------------------------------
  p_stage_23        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(23) <= currentVal(22);
      val_pow(23)<= val_pow(22);
      taylor_data(11) <= fact_r(11)*val_pow(22); 
    end if;
  end process p_stage_23;
  
  -----------------------------------------------------------------------------
  -- stage 24
  -----------------------------------------------------------------------------
  p_stage_24  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(24) <= taylor_data(11)+currentVal(23);
      val_pow(24)<= val_pow(23)*val_org(23);
    end if;
  end process p_stage_24;
  
        -----------------------------------------------------------------------------
  -- stage 25
  -----------------------------------------------------------------------------
  p_stage_25        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(25) <= currentVal(24);
      val_pow(25)<= val_pow(24);
      taylor_data(12) <= fact_r(12)*val_pow(24); 
    end if;
  end process p_stage_25;
  
  -----------------------------------------------------------------------------
  -- stage 26
  -----------------------------------------------------------------------------
  p_stage_26  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(26) <= taylor_data(12)+currentVal(25);
      val_pow(26)<= val_pow(25)*val_org(25);
    end if;
  end process p_stage_26;
  
        -----------------------------------------------------------------------------
  -- stage 27
  -----------------------------------------------------------------------------
  p_stage_27        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(27) <= currentVal(26);
      val_pow(27)<= val_pow(26);
      taylor_data(13) <= fact_r(13)*val_pow(26); 
    end if;
  end process p_stage_27;
  
  -----------------------------------------------------------------------------
  -- stage 28
  -----------------------------------------------------------------------------
  p_stage_28  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(28) <= taylor_data(13)+currentVal(27);
      val_pow(28)<= val_pow(27)*val_org(27);
    end if;
  end process p_stage_28;
  
        -----------------------------------------------------------------------------
  -- stage 29
  -----------------------------------------------------------------------------
  p_stage_29        : process (clk)  
  begin
    if clk'event and clk = '1' then
      currentVal(29) <= currentVal(28);
      val_pow(29)<= val_pow(28);
      taylor_data(14) <= fact_r(14)*val_pow(28); 
    end if;
  end process p_stage_29;
  
  -----------------------------------------------------------------------------
  -- stage 30
  -----------------------------------------------------------------------------
  p_stage_30  : process (clk)
  begin
    if clk'event and clk = '1' then 
      currentVal(30) <= taylor_data(14)+currentVal(29);
      val_pow(30)<= val_pow(29)*val_org(29);
    end if;
  end process p_stage_30;


  --synthesis translate_off
  value_real    <= To_real(val_out_i);
  value_org    <= To_real(val_org(30));
  value_start <= To_real(val_in_i);
  --synthesis translate_on

end Behavioral;



