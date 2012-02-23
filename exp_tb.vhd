-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.float_pkg.all;

-------------------------------------------------------------------------------

entity exp_tb is

end exp_tb;

-------------------------------------------------------------------------------

architecture tb of exp_tb is

  component exp
    port (
      clk       : in  std_logic;
    val_out : out float32;
    val_in  : in  float32 ); 
  end component;

  signal clk_i       : std_logic := '1';
  signal val_in_i  : float32;
    signal val_out_i  : float32;

constant lastValue    : integer := 99; 

begin  -- tb



  DUT : exp
    port map (
      clk       => clk_i,
      val_out  => val_out_i,
      val_in  => val_in_i);


  -- clock generation
  clk_i <= not clk_i after 10 ns;

  


process
begin
    val_in_i <= to_float(50);
  for i in 0 to 99 loop
    val_in_i <= to_float(i);
    wait for 10 ns;
  end loop;
  wait;  -- simulation stops here
end process;



end tb;

-------------------------------------------------------------------------------


