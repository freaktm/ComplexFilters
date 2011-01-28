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
  signal wvals       : real      := 0.0;
  signal x1, y1      : real      := 0.0;
  signal nk          : integer   := 1;
  signal wimang      : real      := 0.0;
  signal clk         : std_logic := '0';


  DUT : filters
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

  clk <= not clk after 10 ns;

  p_increment_values : process (clk)
  begin  -- process p_increment_values
    if clk'event and clk = '1' then     -- rising clock edge
      if theta = 330 then
        theta_i <= 0;
      else
        theta_i <= theta_i + 30;
      end if;

      if x1 >= umax then
        x1 <= -1 * umax;
      else
        x1 <= x1 + deltu;
      end if;
      
    end if;
  end process p_increment_values;

  -- theta <= [0 30 60 90 120 150 180 210 240 270 300 330];

  wvals <= [-thalf : thalf-1];
--  x1    <= [-umax     : deltu : umax];
  y1    <= [-umax     : deltu : umax];

  nk <= 1;



  for ntheta = 1 : length(theta)
    [mtspeed theta(ntheta)]

    wimang = <= theta * ntheta;
  ang = wimang * con;
  for nn = 1 : 8
    wf = wvals(nn);
  for ny = 1 : ysize
    vf = y1(ny);
  for nx = 1 : xsize
    uf = x1(nx);
  [esust, osust, etrans, otrans] = createComplexFiltervals(uf, vf, wf, ang, 0, 0, mtspeed, 40);
  nspectSe(nn, ny, nx) = esust * 4;
  nspectSo(nn, ny, nx) = osust * 4;
  nspectTe(nn, ny, nx) = etrans * 4 * 2;
  nspectTo(nn, ny, nx) = otrans * 4 * 2;
end
end

end
  fnspectSe = (fftshift(nspectSe));
fnspectSo = (fftshift(nspectSo));
fnspectTe = (fftshift(nspectTe));
fnspectTo = (fftshift(nspectTo));

str4 = num2str(nk);
str5 = strcat(str1, str3, '.', str4, str2);
fid1 = fopen(str5, 'wb');
for nf = 1 : nframes
  fwrite(fid1, real((fnspectSe((nf), : , : ))), 'float32');
fwrite(fid1, imag((fnspectSe((nf), : , : ))), 'float32');
fwrite(fid1, real((fnspectSo((nf), : , : ))), 'float32');
fwrite(fid1, imag((fnspectSo((nf), : , : ))), 'float32');
fwrite(fid1, real((fnspectTe((nf), : , : ))), 'float32');
fwrite(fid1, imag((fnspectTe((nf), : , : ))), 'float32');
fwrite(fid1, real((fnspectTo((nf), : , : ))), 'float32');
fwrite(fid1, imag((fnspectTo((nf), : , : ))), 'float32');
end
  fclose(fid1);
clear nspectSe;
clear nspectTe;
clear nspectSo;
clear nspectTo;

nk = nk + 1;
end




end tb;

-------------------------------------------------------------------------------
