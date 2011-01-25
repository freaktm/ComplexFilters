-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity filters_tb is

end filters_tb;

-------------------------------------------------------------------------------

architecture tb of filters_tb is

  component filters
    port (
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
      mtspeed   : in  real;
      fps       : in  real);
  end component;

  signal esust_im_i  : real;
  signal esust_re_i  : real;
  signal osust_re_i  : real;
  signal osust_im_i  : real;
  signal etrans_re_i : real;
  signal etrans_im_i : real;
  signal otrans_re_i : real;
  signal otrans_im_i : real;
  signal uf_i        : real;
  signal vf_i        : real;
  signal wf_i        : real;
  signal theta_i     : real;
  signal oeval_i     : real;
  signal stval_i     : real;
  signal mtspeed_i   : real;
  signal fps_i       : real;

begin  -- tb

  DUT: filters
    port map (
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
        mtspeed   => mtspeed_i,
        fps       => fps_i);

  

end tb;

-------------------------------------------------------------------------------
