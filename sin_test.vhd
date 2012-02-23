-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.float_pkg.all;

-------------------------------------------------------------------------------

entity sin_tb is

end sin_tb;

-------------------------------------------------------------------------------

architecture tb of sin_tb is

  component sin
    port (
      clk       : in  std_logic;
    theta_out : out float32;
    theta_in  : in  float32 ); 
  end component;

  signal clk_i       : std_logic := '1';
  signal theta_in_i  : float32;
    signal theta_out_i  : float32;


begin  -- tb



  DUT : sin
    port map (
      clk       => clk_i,
      theta_out  => theta_out_i,
      theta_in  => theta_in_i);


  -- clock generation
  clk_i <= not clk_i after 10 ns;



  -- set theta to 30 
  theta_in_i <= to_float(30.0);




end tb;

-------------------------------------------------------------------------------
