function dx = sde_of_motion(~, x, P)
  % x = [r_lv(3); v_lv(3); r_sc(3); v_sc(3)]
  r_lv = x(1:3);
  v_lv = x(4:6);
  r_sc = x(7:9);
  v_sc = x(10:12);

  % Gravity accelerations
  a_lv_g = -P.mu * r_lv / (norm(r_lv)^3);
  a_sc_g = -P.mu * r_sc / (norm(r_sc)^3);

  % Spring force (magnitude)
  [F, ~] = spring_force(r_lv, r_sc, P);

  % Action-reaction along axis u
  a_lv_s = -(F / P.m_lv) * P.u;
  a_sc_s = +(F / P.m_sc) * P.u;

  dx = zeros(12,1);
  dx(1:3)   = v_lv;
  dx(4:6)   = a_lv_g + a_lv_s;
  dx(7:9)   = v_sc;
  dx(10:12) = a_sc_g + a_sc_s;
end

