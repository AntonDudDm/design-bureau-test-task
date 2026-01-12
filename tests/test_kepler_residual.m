function test_kepler_residual()
  addpath("../src");

  e = 0.6;
  M = 1.0;
  E = kepler_E(M, e);

  res = E - e*sin(E) - M;
  if abs(res) > 1e-12
    error("Kepler residual too large: %.3e", abs(res));
  end

  fprintf("  [OK] kepler_E residual\n");
end

