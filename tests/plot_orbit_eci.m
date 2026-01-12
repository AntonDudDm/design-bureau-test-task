function plot_orbit_eci()
  % Plot a Keplerian orbit in ECI (J2000) for the given elements.
  % The orbit is built by sweeping mean anomaly M from 0 to 2*pi,
  % solving Kepler's equation, computing r in PQW, and rotating to ECI.
  %
  % Usage (from project root):
  %   addpath("src");
  %   plot_orbit_eci();
  %
  % Output:
  %   A 3D plot of the orbit in ECI with ECI axes drawn.

  % --- paths ---
  this_dir = fileparts(mfilename("fullpath"));
  addpath(fullfile(this_dir, "..", "src"));

  % --- constants ---
  mu = 3.986004418e14;       % [m^3/s^2] Earth GM (not strictly needed to plot r)

  % --- Keplerian elements (from TS) ---
  a  = 6700e3;               % [m]
  e  = 0.003;                % [-]
  i  = deg2rad(80);          % [rad]
  Om = deg2rad(-15);         % [rad] RAAN
  w  = deg2rad(30);          % [rad] arg of pericenter
  M0 = deg2rad(0);           % [rad] mean anomaly at start

  % --- sample the orbit ---
  N = 600;
  M = linspace(0, 2*pi, N)';

  r_eci = zeros(N,3);

  % Rotation PQW -> ECI:
  % Q = R3(Om) * R1(i) * R3(w)
  Q = rotmat(3, Om) * rotmat(1, i) * rotmat(3, w);

  for k = 1:N
    Ek = kepler_E(M(k), e);

    % Position in PQW using eccentric anomaly E
    r = a * (1 - e*cos(Ek));

    r_pqw = [ a*(cos(Ek) - e);
              a*sqrt(1 - e^2)*sin(Ek);
              0 ];

    % Rotate to ECI
    r_eci(k,:) = (Q * r_pqw)';
  end

  % --- compute the start point at M0 ---
  E0 = kepler_E(M0, e);
  r0_pqw = [ a*(cos(E0) - e);
             a*sqrt(1 - e^2)*sin(E0);
             0 ];
  r0_eci = Q * r0_pqw;

  % --- plot ---
  figure(101); clf;
  plot3(r_eci(:,1), r_eci(:,2), r_eci(:,3), "k-", "LineWidth", 2);
  grid on; axis equal;
  xlabel("ECI X, m"); ylabel("ECI Y, m"); zlabel("ECI Z, m");
  title("Keplerian orbit in ECI (J2000) for заданных элементов");

  hold on;
  plot3(r0_eci(1), r0_eci(2), r0_eci(3), "ro", "MarkerSize", 7, "MarkerFaceColor", "r");
  text(r0_eci(1), r0_eci(2), r0_eci(3), "  start (M0)");

  % --- draw ECI axes ---

  L = 1.2 * a;
  plot3([0 L], [0 0], [0 0], "r-", "LineWidth", 1.5);
  plot3([0 0], [0 L], [0 0], "g-", "LineWidth", 1.5);
  plot3([0 0], [0 0], [0 L], "b-", "LineWidth", 1.5);
  text(L, 0, 0, "  X");
  text(0, L, 0, "  Y");
  text(0, 0, L, "  Z");

  % --- optional: show Earth center marker ---
  plot3(0,0,0,"ko","MarkerSize",5,"MarkerFaceColor","k");
  legend("Orbit", "Start point", "Location", "best");

  rotate3d on;
  set(gcf, "WindowButtonMotionFcn", "");


  % --- quick note in console ---
  fprintf("Orbit plotted. a=%.1f km, e=%.4f, i=%.1f deg, Om=%.1f deg, w=%.1f deg\n", ...
          a/1e3, e, rad2deg(i), rad2deg(Om), rad2deg(w));
end


