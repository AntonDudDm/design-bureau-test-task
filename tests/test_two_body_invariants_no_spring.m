function test_two_body_invariants_no_spring()
  addpath("../src");

  % Parameters
  P.mu = 3.986004418e14;
  P.m_lv = 3500; P.m_sc = 3100;
  P.k = 0;               % disable spring
  P.L_free = 0.220; P.L0 = 0.110; P.L_end = 0.195;

  % Orbit
  a = 6700e3; e = 0.003;
  i = deg2rad(80); Om = deg2rad(-15); w = deg2rad(30); M0 = 0;

  [r0, v0] = kepler2rv(P.mu, a, e, i, Om, w, M0);
  P.u = v0 / norm(v0);

  x0 = [r0; v0; r0 + P.L0*P.u; v0];

  t = (0:0.01:5)';  % same as TS
  [t, X, R] = simulate_sep(t, x0, P);

  r_lv = X(:,1:3); v_lv = X(:,4:6);
  r_sc = X(:,7:9); v_sc = X(:,10:12);

  % invariants for each body in central gravity
  eps_lv = 0.5*sum(v_lv.^2,2) - P.mu ./ sqrt(sum(r_lv.^2,2));
  eps_sc = 0.5*sum(v_sc.^2,2) - P.mu ./ sqrt(sum(r_sc.^2,2));

  h_lv = sqrt(sum(cross(r_lv, v_lv, 2).^2,2));
  h_sc = sqrt(sum(cross(r_sc, v_sc, 2).^2,2));

  % check drift (numerical)
  tol_eps = 1e-3;   % J/kg-level tolerance (can tighten if needed)
  tol_h   = 1e-3;   % (m^2/s) tolerance

  if max(abs(eps_lv - eps_lv(1))) > tol_eps
    error("LV energy not conserved enough");
  end
  if max(abs(eps_sc - eps_sc(1))) > tol_eps
    error("SC energy not conserved enough");
  end
  if max(abs(h_lv - h_lv(1))) > tol_h
    error("LV angular momentum not conserved enough");
  end
  if max(abs(h_sc - h_sc(1))) > tol_h
    error("SC angular momentum not conserved enough");
  end

  fprintf("  [OK] two-body invariants (k=0)\n");
end

