function E = kepler_E(M, e)
  % Solve Kepler equation M = E - e*sin(E) for elliptic orbits (0<=e<1)
  % using Newton-Raphson iterations.
  %
  % Inputs:
  %   M [rad] - mean anomaly
  %   e       - eccentricity
  % Output:
  %   E [rad] - eccentric anomaly


  M = mod(M, 2*pi);

  if e < 0.8
    E = M;
  else
    E = pi;
  end

  for it = 1:60
    f  = E - e*sin(E) - M;
    fp = 1 - e*cos(E);       % derivative
    dE = -f / fp;
    E  = E + dE;
    if abs(dE) < 1e-14
      return;
    end
  end

  warning("kepler_E: Newton not fully converged (last dE=%.3e)", dE);
end

