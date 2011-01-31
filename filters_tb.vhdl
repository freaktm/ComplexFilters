-------------------------------------------------------------------------------
-- Title      : Testbench for design "filters"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : filters_tb.vhdl
-- Author     : Aaron Storey  <freaktm@freaktm>
-- Company    : 
-- Created    : 2011-01-29
-- Last update: 2011/02/01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-29  1.0      freaktm Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library floatfixlib;
use floatfixlib.float_pkg.all;

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
      uf        : in  real;
      vf        : in  real;
      wf        : in  real;
      theta     : in  real;
      oeval     : in  real;
      stval     : in  real;
      mtspeed   : in  real
      );
  end component;

  -- component ports
  signal esust_im  : float32;
  signal esust_re  : float32;
  signal osust_re  : float32;
  signal osust_im  : float32;
  signal etrans_re : float32;
  signal etrans_im : float32;
  signal otrans_re : float32;
  signal otrans_im : float32;
  signal uf        : real := -20.0;
  signal vf        : real := -20.0;
  signal wf        : real := -4.0;
  signal theta     : real := 0.0;
  signal oeval     : real := 0.0;
  signal stval     : real := 0.0;
  signal mtspeed   : real := 1.0;

  -- clock
  signal Clk : std_logic := '1';

  constant X_SIZE : integer := 128;
  constant Y_SIZE : integer := 128;

  type frame_t is array (X_SIZE-1 downto 0, Y_SIZE-1 downto 0) of real;

  signal frame_esust_re  : frame_t;
  signal frame_esust_im  : frame_t;
  signal frame_osust_re  : frame_t;
  signal frame_osust_im  : frame_t;
  signal frame_etrans_re : frame_t;
  signal frame_etrans_im : frame_t;
  signal frame_otrans_re : frame_t;
  signal frame_otrans_im : frame_t;

  type filter_set_t is
  record
    esust_re  : frame_t;
    esust_im  : frame_t;
    osust_re  : frame_t;
    osust_im  : frame_t;
    etrans_re : frame_t;
    etrans_im : frame_t;
    otrans_re : frame_t;
    otrans_im : frame_t;
  end record;


  impure function load_filter_set_from_file(filename : in string)
    return filter_set_t is

    type real_file is file of real;
    file my_file : real_file;

    variable filter_set_0 : filter_set_t;
    
  begin
    file_open(my_file, filename, read_mode);

    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.esust_im(i, j));
      end loop;
    end loop;
    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.esust_im(i, j));
      end loop;
    end loop;
    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.osust_re(i, j));
      end loop;
    end loop;
    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.osust_im(i, j));
      end loop;
    end loop;
    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.etrans_re(i, j));
      end loop;
    end loop;
    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.etrans_im(i, j));
      end loop;
    end loop;
    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.otrans_re(i, j));
      end loop;
    end loop;
    for i in 0 to X_SIZE-1 loop
      for j in 0 to Y_SIZE-1 loop
        read(my_file, filter_set_0.otrans_im(i, j));
      end loop;
    end loop;


    file_close(my_file);
    return filter_set_0;
    
  end function;


  signal filter_set_0 : filter_set_t := load_filter_set_from_file("nFilter1.1.dat");


begin  -- tb

  -- component instantiation
  DUT : filters
    port map (
      clk => clk,
      esust_im  => esust_im,
      esust_re  => esust_re,
      osust_re  => osust_re,
      osust_im  => osust_im,
      etrans_re => etrans_re,
      etrans_im => etrans_im,
      otrans_re => otrans_re,
      otrans_im => otrans_im,
      uf        => uf,
      vf        => vf,
      wf        => wf,
      theta     => theta,
      oeval     => oeval,
      stval     => stval,
      mtspeed   => mtspeed
      );

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here

    wait for 100 ns;
    wait until Clk = '1';
    report "simulation finished" severity warning;
    wait;
  end process WaveGen_Proc;


  
end tb;

-------------------------------------------------------------------------------

configuration filters_tb_tb_cfg of filters_tb is
  for tb
  end for;
end filters_tb_tb_cfg;

-------------------------------------------------------------------------------
