function test_momentum_conservation_no_gravity()
  addpath("../src");

  % Parameters
  P.mu = 0;                  % disable gravity
  P.m_lv = 3500; P.m_sc = 3100;

  P.k = 30000;
  P.L_free = 0.220;
  P.L0 = 0.110;
  P.L_end = 0.195;

  % Initial state: pick any reasonable r0, v0
  % Use the same orbital conversion but mu=0 would break kepler2rv,
  % so here keep a fixed inertial setup:
  r0 = [6700e3; 0; 0];
  v0 = [0; 7700; 0];
  P.u = v0 / norm(v0);

  x0 = [r0; v0; r0 + P.L0*P.u; v0];

  t = (0:0.001:1)';  % short test
  [t, X, R] = simulate_sep(t, x0, P);

  v_lv = X(:,4:6);
  v_sc = X(:,10:12);

  p = P.m_lv*v_lv + P.m_sc*v_sc;     % total momentum
  dp = p - p(1,:);

  tol_p = 1e-6; % N*s scale; tighten/loosen depending on solver
  if max(abs(dp(:))) > tol_p
    error("Total momentum not conserved enough (mu=0)");
  end

  fprintf("  [OK] momentum conservation (mu=0)\n");
end

