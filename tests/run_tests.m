function run_tests()
  addpath("../src");

  fprintf("Running tests...\n");

  test_kepler_residual();
  test_two_body_invariants_no_spring();
  test_momentum_conservation_no_gravity();

  fprintf("ALL TESTS PASSED\n");
end

function assert_close(val, ref, tol, msg)
  if any(abs(val - ref) > tol)
    error("TEST FAILED: %s | max err = %.3e (tol %.3e)", msg, max(abs(val-ref)), tol);
  end
end

