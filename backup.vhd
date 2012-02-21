


  -----------------------------------------------------------------------------
  -- stage 4
  -----------------------------------------------------------------------------
  p_stage_4          : process (clk)
  begin
    if clk'event and clk = '1' then
      hz                    <= speed(1) * udash(0);
      sf                    <= udash(0) * udash(0);
      s_2_pi                <= (2.0 * MATH_PI) * s;
      vdash_s               <= vdash * sigys_pi(1);
      exp_w_2               <= exp(w_2_tsd_div);
    end if;
  end process p_stage_4;
  -----------------------------------------------------------------------------
  -- stage 5
  -----------------------------------------------------------------------------
  p_stage_5          : process (clk)
  begin
    if clk'event and clk = '1' then
      if (hz = 0.0) then
        hz_0                <= 0.001;
      else
        hz_0                <= hz;
      end if;
      xc1                   <= scale(4)*(2.22/60.0);
      xc2                   <= scale(4)*(4.97/60.0);
      xs1                   <= scale(4)*(15.36/60.0);
      xs2                   <= scale(4)*(17.41/60.0);
      sf_pi2(0)             <= sf * MATH_PI*MATH_PI;
      for i in 1 to N_STAGES_SFPI2-1 loop
        sf_pi2(i)           <= sf_pi2(i-1);
      end loop;  -- i
      udash_s_pi            <= udash(1) * s_2_pi;
      vdash_sx2             <= -(vdash_s * vdash_s);
      temp3                 <= tphase_c(2) * exp_w_2;
      tphase_exp_s          <= tphase_s(2) * exp_w_2;
    end if;
  end process p_stage_5;
  -----------------------------------------------------------------------------
  -- stage 6
  -----------------------------------------------------------------------------
  p_stage_6          : process (clk)
  begin
    if clk'event and clk = '1' then
      hz_abs                <= abs(hz_0);
      xc22                  <= xc2*xc2;
      scale_s(0)            <= sin(udash_s_pi);
      scale_c(0)            <= cos(udash_s_pi);
      xs22                  <= xs2*xs2;
      xc12                  <= xc1*xc1;
      vdash_exp             <= exp(vdash_sx2);
      xs12                  <= xs1*xs1;
      etsust_re(0)          <= temp3;
      etsust_im(0)          <= tphase_exp_s;
      for i in 1 to N_STAGES_ETSUST-1 loop
        etsust_re(i)        <= etsust_re(i-1);
        etsust_im(i)        <= etsust_im(i-1);
      end loop;  -- i
      for i in 1 to N_STAGES_SCALES-1 loop
        scale_s(i)          <= scale_s(i-1);
      end loop;  -- i
      for i in 1 to N_STAGES_SCALEC-1 loop
        scale_c(i)          <= scale_c(i-1);
      end loop;  -- i
    end if;
  end process p_stage_6;
  -----------------------------------------------------------------------------
  -- stage 7
  -----------------------------------------------------------------------------
  p_stage_7          : process (clk)
  begin
    if clk'event and clk = '1' then
      xs12_sfpi2            <= sf_pi2(1) * xs12;
      xc12_sfpi2            <= sf_pi2(1) * xc12;
      xs22_sfpi2            <= sf_pi2(1) * xs22;
      xc22_sfpi2            <= sf_pi2(1) * xc22;
      temp4(0)              <= sigys_pi(4) * vdash_exp;
      hz_kratio             <= hz_abs * kratio;
      temp6_re              <= w(6) * etsust_re(0);
      temp6_im              <= w(6) * etsust_im(0);
    end if;
  end process p_stage_7;
  -----------------------------------------------------------------------------
  -- stage 8
  -----------------------------------------------------------------------------
  p_stage_8          : process (clk)
  begin
    if clk'event and clk = '1' then
      stratio(0)            <= 1.0 / hz_kratio;
      xc22_exp              <= -(exp(xc22_sfpi2));
      xs22_exp              <= -(exp(xs22_sfpi2));
      xc12_exp              <= -(exp(xc12_sfpi2));
      xs12_exp              <= -(exp(xs12_sfpi2));
      temp7_im              <= kratio * temp6_im;
      temp7_re              <= kratio * temp6_re;
      for i in 1 to N_STAGES_STRATIO-1 loop
        stratio(i)          <= stratio(i-1);
      end loop;  -- i
    end if;
  end process p_stage_8;
  -----------------------------------------------------------------------------
  -- stage 9
  -----------------------------------------------------------------------------
  p_stage_9          : process (clk)
  begin
    if clk'event and clk = '1' then
      r                     <= xc22_exp * kc2;
      t                     <= xs22_exp * ks2;
      p                     <= xc12_exp * kc1;
      q                     <= xs12_exp * ks1;
      ettrans_im(0)         <= temp7_re;
      ettrans_re(0)         <= temp7_im;
      for i in 1 to N_STAGES_ETTRANS-1 loop
        ettrans_re(i)       <= ettrans_re(i-1);
        ettrans_im(i)       <= ettrans_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_9;
  -----------------------------------------------------------------------------
  -- stage 10
  -----------------------------------------------------------------------------
  p_stage_10         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_s_g             <= scale_s(3) * 1.2 * g;
      r1                    <= r - t;
      p1(0)                 <= p - q;
      for i in 1 to N_STAGES_P1-1 loop
        p1(i)               <= p1(i-1);
      end loop;  -- i 
      if thilb_re(8) = '0' then
        thilb_ettrans_im(0) <= thilb_im(8) * ettrans_re(0);
        thilb_ettrans_re(0) <= thilb_im(8) * ettrans_im(0);
      else
        thilb_ettrans_re(0) <= ettrans_re(0);
        thilb_ettrans_im(0) <= ettrans_im(0);
      end if;
      for i in 1 to N_STAGES_THILB_ETTRANS-1 loop
        thilb_ettrans_re(i) <= thilb_ettrans_re(i-1);
        thilb_ettrans_im(i) <= thilb_ettrans_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_10;
  -----------------------------------------------------------------------------
  -- stage 11
  -----------------------------------------------------------------------------
  p_stage_11         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_s_r1            <= scale_s_g * r1;
      scale_c_r1            <= scale_c(4) * r1;
      p1_square(0)          <= p1(0) * p1(0);
      for i in 1 to N_STAGES_P1SQUARE-1 loop
        p1_square(i)        <= p1_square(i-1);
      end loop;  -- i
    end if;
  end process p_stage_11;
  -----------------------------------------------------------------------------
  -- stage 12
  -----------------------------------------------------------------------------
  p_stage_12         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_SG1(0)          <= scale_s_r1 * scale_s_r1;
      for i in 1 to N_STAGES_SG1-1 loop
        scale_SG1(i)        <= scale_SG1(i-1);
      end loop;  -- i
      scale_c_p1            <= scale_c_r1 * p1(1);
    end if;
  end process p_stage_12;
  -----------------------------------------------------------------------------
  -- stage 13
  -----------------------------------------------------------------------------
  p_stage_13         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_c_p1_x2         <= scale_c_p1 + scale_c_p1;
    end if;
  end process p_stage_13;
  -----------------------------------------------------------------------------
  -- stage 14
  -----------------------------------------------------------------------------
  p_stage_14         : process (clk)
  begin
    if clk'event and clk = '1' then
      p1_square_scale_c     <= -scale_c_p1_x2 + p1_square(2);
    end if;
  end process p_stage_14;
  -----------------------------------------------------------------------------
  -- stage 15
  -----------------------------------------------------------------------------
  p_stage_15         : process (clk)
  begin
    if clk'event and clk = '1' then
      scale_cc              <= p1_square_scale_c + scale_c(8);
    end if;
  end process p_stage_15;
  -----------------------------------------------------------------------------
  -- stage 16
  -----------------------------------------------------------------------------
  p_stage_16         : process (clk)
  begin
    if clk'event and clk = '1' then
      temp1                 <= scale_cc * scale_cc;
    end if;
  end process p_stage_16;
  -----------------------------------------------------------------------------
  -- stage 17
  -----------------------------------------------------------------------------
  p_stage_17         : process (clk)
  begin
    if clk'event and clk = '1' then
      temp2                 <= temp1 + scale_SG1(4);
    end if;
  end process p_stage_17;
  -----------------------------------------------------------------------------
  -- stage 18
  -----------------------------------------------------------------------------
  p_stage_18         : process (clk)
  begin
    if clk'event and clk = '1' then
      tempx                 <= SQRT(temp2);
      tempy                 <= SQRT(temp4(10));
    end if;
  end process p_stage_18;
  -----------------------------------------------------------------------------
  -- stage 19
  -----------------------------------------------------------------------------
  p_stage_19         : process (clk)
  begin
    if clk'event and clk = '1' then
      espsust               <= tempx * tempy;
    end if;
  end process p_stage_19;
  -----------------------------------------------------------------------------
  -- stage 20
  -----------------------------------------------------------------------------
  p_stage_20         : process (clk)
  begin
    if clk'event and clk = '1' then
      esptrans              <= stratio(11) * espsust;
      esust_int_re(0)       <= espsust * etsust_re(13);
      esust_int_im(0)       <= espsust * etsust_im(13);
      for i in 1 to N_STAGES_ESUST_INT-1 loop
        esust_int_re(i)     <= esust_int_re(i-1);
        esust_int_im(i)     <= esust_int_im(i-1);
      end loop;  -- i     
    end if;
  end process p_stage_20;
  -----------------------------------------------------------------------------
  -- stage 21        FIX SHILB, REMOVE MULTIPLYER
  -----------------------------------------------------------------------------
  p_stage_21         : process (clk)
  begin
    if clk'event and clk = '1' then
      if shilb_im(17) = '1' then
        osust_int_re(0)     <= -esust_int_im(0);
        osust_int_im(0)     <= -esust_int_re(0);
        shilb_esptrans_im   <= -esptrans;
      else
        osust_int_re(0)     <= esust_int_im(0);
        osust_int_im(0)     <= esust_int_re(0);
        shilb_esptrans_im   <= esptrans;
      end if;
      emain_im              <= esptrans * ettrans_im(11);
      emain_re              <= esptrans * ettrans_re(11);
      for i in 1 to N_STAGES_OSUST_INT-1 loop
        osust_int_im(i)     <= osust_int_im(i-1);
        osust_int_im(i)     <= osust_int_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_21;
  -----------------------------------------------------------------------------
  -- stage 22        FIX SHILB, how to add a i or -i to an imaginary number
  -----------------------------------------------------------------------------
  p_stage_22         : process (clk)
  begin
    if clk'event and clk = '1' then
      if shilb_im(18) = '1' then
        shilb_esptrans_re   <= -shilb_esptrans_im;
      else
        shilb_esptrans_re   <= shilb_esptrans_im;
      end if;
      emain_neg_re          <= -emain_re;
      emain_neg_im          <= -emain_im;
      ehilb_re              <= thilb_ettrans_im(11) * shilb_esptrans_im;
      ehilb_im              <= thilb_ettrans_re(11) * shilb_esptrans_im;
      omain_re(0)           <= ettrans_im(12) * shilb_esptrans_im;
      omain_im(0)           <= ettrans_re(12) * shilb_esptrans_im;
      for i in 1 to N_STAGES_OMAIN-1 loop
        omain_re(i)         <= omain_re(i-1);
        omain_im(i)         <= omain_im(i-1);
      end loop;  -- i
    end if;
  end process p_stage_22;
  -----------------------------------------------------------------------------
  -- stage 23
  -----------------------------------------------------------------------------
  p_stage_23         : process (clk)
  begin
    if clk'event and clk = '1' then
      ohilb_re              <= shilb_esptrans_re * thilb_ettrans_re(12);
      ohilb_im              <= shilb_esptrans_re * thilb_ettrans_im(12);
      etrans_int_re(0)      <= -(emain_neg_re + ehilb_re);
      etrans_int_im(0)      <= -(emain_neg_im + ehilb_im);
      for i in 1 to N_STAGES_ETRANS_INT-1 loop
        etrans_int_im(i)    <= etrans_int_im(i-1);
        etrans_int_re(i)    <= etrans_int_re(i-1);
      end loop;  -- i
    end if;
  end process p_stage_23;
  -----------------------------------------------------------------------------
  -- stage 24
  -----------------------------------------------------------------------------
  p_stage_24         : process (clk)
  begin
    if clk'event and clk = '1' then
      otrans_int_re         <= -(ohilb_re + omain_re(1));
      otrans_int_im         <= -(ohilb_im + omain_im(1));
    end if;
  end process p_stage_24;


