function [r_eci, v_eci] = kepler2rv(mu, a, e, i, Om, w, M)
  % Convert Keplerian elements to Cartesian state (r,v) in ECI.
  %
  % Inputs:
  %   mu [m^3/s^2], a [m], e, i [rad], Om [rad], w [rad], M [rad]
  % Outputs:
  %   r_eci [m] (3x1), v_eci [m/s] (3x1)

  % 1) Solve Kepler equation for eccentric anomaly E
  E = kepler_E(M, e);

  % 2) Convert E -> true anomaly nu and radius r
  nu = 2*atan2( sqrt(1+e)*sin(E/2), sqrt(1-e)*cos(E/2) );
  r  = a*(1 - e*cos(E));

  % 3) Orbit parameter
  p = a*(1 - e^2);

  % 4) State in PQW
  r_pqw = [r*cos(nu); r*sin(nu); 0];
  v_pqw = sqrt(mu/p) * [-sin(nu); e + cos(nu); 0];

  % 5) PQW -> ECI rotation
  Q = rotmat(3, Om) * rotmat(1, i) * rotmat(3, w);

  r_eci = Q * r_pqw;
  v_eci = Q * v_pqw;
end

