-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library floatfixlib;
use floatfixlib.float_pkg.all;
use floatfixlib.fixed_pkg.all;

-------------------------------------------------------------------------------

entity filters_tb is

end filters_tb;

-------------------------------------------------------------------------------

architecture tb of filters_tb is

  component filters
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
      mtspeed   : in  float32);
  end component;

  signal clk_i       : std_logic := '1';
  signal esust_im_i  : float32;
  signal esust_re_i  : float32;
  signal osust_re_i  : float32;
  signal osust_im_i  : float32;
  signal etrans_re_i : float32;
  signal etrans_im_i : float32;
  signal otrans_re_i : float32;
  signal otrans_im_i : float32;
  signal uf_i        : float32;
  signal vf_i        : float32;
  signal wf_i        : float32;
  signal theta_i     : float32;
  signal oeval_i     : float32;
  signal stval_i     : float32;
  signal mtspeed_i   : float32;


  --synthesis translate_off
  signal mtspeed_i_real : real := 0.0;
  signal sigys_real     : real := 0.0;
  signal theta_i_real   : real := 0.0;
  --synthesis translate_on
begin  -- tb



  DUT : filters
    port map (
      clk       => clk_i,
      esust_im  => esust_im_i,
      esust_re  => esust_re_i,
      osust_re  => osust_re_i,
      osust_im  => osust_im_i,
      etrans_re => etrans_re_i,
      etrans_im => etrans_im_i,
      otrans_re => otrans_re_i,
      otrans_im => otrans_im_i,
      uf        => uf_i,
      vf        => vf_i,
      wf        => wf_i,
      theta     => theta_i,
      oeval     => oeval_i,
      stval     => stval_i,
      mtspeed   => mtspeed_i);


  -- clock generation
  clk_i <= not clk_i after 10 ns;


  -- set mtspeed to 1
  mtspeed_i <= to_float(1.0);

  -- set theta to 30 
  theta_i <= to_float(30.0);


  -- synthesis translate_off 
  mtspeed_i_real <= To_real(mtspeed_i);
  theta_i_real   <= To_real(theta_i);
  -- synthesis translate_on






end tb;

-------------------------------------------------------------------------------
