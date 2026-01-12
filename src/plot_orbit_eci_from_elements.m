function plot_orbit_eci_from_elements(a, e, i, Om, w, M0)
  % Plot Keplerian orbit in ECI (J2000) from Keplerian elements
  %
  % INPUT:
  %   a  - semi-major axis [m]
  %   e  - eccentricity [-]
  %   i  - inclination [rad]
  %   Om - RAAN [rad]
  %   w  - argument of pericenter [rad]
  %   M0 - mean anomaly at epoch [rad]
  %
  % OUTPUT:
  %   Figure with 3D orbit and ECI axes

  try, graphics_toolkit("qt"); catch, end

  N = 600;
  M = linspace(0, 2*pi, N)';

  r_eci = zeros(N,3);

  % Rotation PQW -> ECI
  Q = rotmat(3, Om) * rotmat(1, i) * rotmat(3, w);

  for k = 1:N
    E = kepler_E(M(k), e);

    r_pqw = [ a*(cos(E) - e);
              a*sqrt(1 - e^2)*sin(E);
              0 ];

    r_eci(k,:) = (Q * r_pqw)';
  end

  % Initial point
  E0 = kepler_E(M0, e);
  r0_pqw = [ a*(cos(E0) - e);
             a*sqrt(1 - e^2)*sin(E0);
             0 ];
  r0 = Q * r0_pqw;

  % --- Plot ---
  figure(200); clf;
  plot3(r_eci(:,1), r_eci(:,2), r_eci(:,3), "k-", "LineWidth", 2);
  hold on; grid on; axis equal;

  plot3(r0(1), r0(2), r0(3), "ro", "MarkerFaceColor", "r");
  text(r0(1), r0(2), r0(3), "  M_0");

  xlabel("ECI X, m");
  ylabel("ECI Y, m");
  zlabel("ECI Z, m");
  title("Кеплерова орбита в системе ECI (J2000)");

  % Draw ECI axes
  L = 1.2 * a;
  plot3([0 L], [0 0], [0 0], "r", "LineWidth", 1.5);
  plot3([0 0], [0 L], [0 0], "g", "LineWidth", 1.5);
  plot3([0 0], [0 0], [0 L], "b", "LineWidth", 1.5);
  text(L,0,0," X"); text(0,L,0," Y"); text(0,0,L," Z");

  rotate3d on;
end


