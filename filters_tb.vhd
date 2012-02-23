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
      mtspeed   : in  real);
  end component;

  signal clk_i       : std_logic := '1';
  signal esust_im_i  : real := 1.0;
  signal esust_re_i  : real := 1.0;
  signal osust_re_i  : real := 1.0;
  signal osust_im_i  : real := 1.0;
  signal etrans_re_i : real := 1.0;
  signal etrans_im_i : real := 1.0;
  signal otrans_re_i : real := 1.0;
  signal otrans_im_i : real := 1.0;
  signal uf_i        : real := 1.0;
  signal vf_i        : real := 1.0;
  signal wf_i        : real := 1.0;
  signal theta_i     : real := 1.0;
  signal oeval_i     : real := 1.0;
  signal stval_i     : real := 1.0;
  signal mtspeed_i   : real := 1.0;



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



process
  variable cnt : real := 1.0;
begin
  wait for 20 ns;
  for i in 2 to 99 loop
    cnt := cnt + 1.0;
    wf_i <= cnt;
    wait for 10 ns;
  end loop;
  wait;  -- simulation stops here
end process;





end tb;

-------------------------------------------------------------------------------
