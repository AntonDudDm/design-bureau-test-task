function [t, X, R] = simulate_sep(t, x0, P)
  % Integrate separation dynamics and compute derived outputs.
  %
  % Inputs:
  %   t  - column vector of output times (uniform, dt<=0.01)
  %   x0 - initial state (12x1)
  %   P  - parameters struct
  %
  % Outputs:
  %   X  - state history (Nx12) at times t
  %   R  - derived outputs struct with fields:
  %        d, vrel, F, L  (Nx1 each)

  opts = odeset("RelTol", 1e-9, "AbsTol", 1e-9);

  % Integrate with adaptive solver, then evaluate on exact grid t
  [t, X] = ode45(@(tt,xx) sde_of_motion(tt, xx, P), t, x0, opts);


  r_lv = X(:, 1:3); v_lv = X(:, 4:6);
  r_sc = X(:, 7:9); v_sc = X(:,10:12);

  n = rows(X);
  d    = zeros(n,1);
  vrel = zeros(n,1);
  F    = zeros(n,1);
  L    = zeros(n,1);

  for k = 1:n
    d(k)    = norm(r_sc(k,:) - r_lv(k,:));
    vrel(k) = norm(v_sc(k,:) - v_lv(k,:));
    [Fk, Lk] = spring_force(r_lv(k,:)', r_sc(k,:)', P);
    F(k) = Fk; L(k) = Lk;
  end

  R.d = d;
  R.vrel = vrel;
  R.F = F;
  R.L = L;
end

