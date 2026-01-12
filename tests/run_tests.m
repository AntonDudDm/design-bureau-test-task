function run_tests()
  addpath("../src");

  fprintf("Running tests...\n");

  test_kepler_residual();
  test_two_body_invariants_no_spring();
  test_momentum_conservation_no_gravity();

  fprintf("ALL TESTS PASSED\n");

  plot_orbit_eci();

end


