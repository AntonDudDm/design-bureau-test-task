function postprocess(t, X, R, outdir, P)
  r_lv = X(:, 1:3);
  v_lv = X(:, 4:6);
  r_sc = X(:, 7:9);
  v_sc = X(:,10:12);

  % 3D trajectories
  figure(1);
  plot3(r_lv(:,1), r_lv(:,2), r_lv(:,3), "b-"); hold on;
  plot3(r_sc(:,1), r_sc(:,2), r_sc(:,3), "r-");
  grid on; axis equal;
  xlabel("x, m"); ylabel("y, m"); zlabel("z, m");
  legend("LV", "SC");
  title("3D trajectories in ECI (J2000)");
  set(gcf, "Name", "3D trajectories in ECI (J2000)", "NumberTitle", "off");

  % Relative distance
  figure(2);
  plot(t, R.d); grid on;
  xlabel("t, s"); ylabel("d(t), m");
  title("Relative distance");
  set(gcf, "Name", "Relative distance", "NumberTitle", "off");


  % Relative speed
  figure(3);
  plot(t, R.vrel); grid on;
  xlabel("t, s"); ylabel("v_{rel}(t), m/s");
  title("Relative speed");
  set(gcf, "Name", "Relative speed", "NumberTitle", "off");

  % Pusher force
  figure(4);
  plot(t, R.F); grid on;
  xlabel("t, s"); ylabel("F(t), N");
  title("Pusher force");
  set(gcf, "Name", "Pusher force", "NumberTitle", "off");

  % ----------------------------
  % Position and velocity
  % ----------------------------

  plot_xyz_figure(5, t, r_sc, "SC position vector components (ECI J2000)", ...
                  {"x, m", "y, m", "z, m"}, ...
                  {"SC r_x(t)", "SC r_y(t)", "SC r_z(t)"});

  plot_xyz_figure(6, t, v_sc, "SC velocity vector components (ECI J2000)", ...
                  {"v_x, m/s", "v_y, m/s", "v_z, m/s"}, ...
                  {"SC v_x(t)", "SC v_y(t)", "SC v_z(t)"});

  plot_xyz_figure(7, t, r_lv, "LV stage position vector components (ECI J2000)", ...
                  {"x, m", "y, m", "z, m"}, ...
                  {"LV r_x(t)", "LV r_y(t)", "LV r_z(t)"});

  plot_xyz_figure(8, t, v_lv, "LV stage velocity vector components (ECI J2000)", ...
                  {"v_x, m/s", "v_y, m/s", "v_z, m/s"}, ...
                  {"LV v_x(t)", "LV v_y(t)", "LV v_z(t)"});


  % ----------------------------
  % Relative trajectory
  % ----------------------------
  r_rel = r_sc - r_lv;   % Nx3, meters

  figure(9);
  plot3(r_rel(:,1), r_rel(:,2), r_rel(:,3), "k-", "LineWidth", 2);
  grid on; axis equal;
  xlabel("\Deltax, m"); ylabel("\Deltay, m"); zlabel("\Deltaz, m");
  title("Relative trajectory: SC w.r.t. LV (ECI)");
  % (optional) mark start/end
  hold on;
  plot3(r_rel(1,1), r_rel(1,2), r_rel(1,3), "go", "MarkerSize", 6, "MarkerFaceColor", "g");
  plot3(r_rel(end,1), r_rel(end,2), r_rel(end,3), "ro", "MarkerSize", 6, "MarkerFaceColor", "r");
  legend("r_{SC}-r_{LV}", "start", "end", "Location", "best");

  % ----------------------------
  % Motion in Center-of-Mass frame
  % ----------------------------
  m_tot = P.m_lv + P.m_sc;

  r_cm = (P.m_lv * r_lv + P.m_sc * r_sc) / m_tot;   % Nx3

  r_lv_cm = r_lv - r_cm;
  r_sc_cm = r_sc - r_cm;

  figure(10);
  plot3(r_lv_cm(:,1), r_lv_cm(:,2), r_lv_cm(:,3), "b-", "LineWidth", 2); hold on;
  plot3(r_sc_cm(:,1), r_sc_cm(:,2), r_sc_cm(:,3), "r-", "LineWidth", 2);
  grid on; axis equal;
  xlabel("x_{CM}, m"); ylabel("y_{CM}, m"); zlabel("z_{CM}, m");
  title("Trajectories in Center-of-Mass frame");
  legend("LV - r_{CM}", "SC - r_{CM}", "Location", "best");


  % ----------------------------
  % Save figures
  % ----------------------------
  if nargin >= 4 && ~isempty(outdir)
    try
      saveas(1, fullfile(outdir, "traj3d.png"));
      saveas(2, fullfile(outdir, "distance.png"));
      saveas(3, fullfile(outdir, "vrel.png"));
      saveas(4, fullfile(outdir, "force.png"));

      saveas(5, fullfile(outdir, "sc_position_xyz.png"));
      saveas(6, fullfile(outdir, "sc_velocity_xyz.png"));
      saveas(7, fullfile(outdir, "lv_position_xyz.png"));
      saveas(8, fullfile(outdir, "lv_velocity_xyz.png"));

      saveas(9,  fullfile(outdir, "relative_traj_sc_wrt_lv.png"));
      saveas(10, fullfile(outdir, "traj_center_of_mass_frame.png"));
    catch

    end
  end
end


function plot_xyz_figure(fig_id, t, A, fig_title, ylabels, titles)
  % A is Nx3 matrix: columns are x,y,z components.
  figure(fig_id); clf;

  comps = {"x", "y", "z"};
  for k = 1:3
    subplot(3, 1, k);
    plot(t, A(:,k));
    grid on;
    xlabel("t, s");
    ylabel(ylabels{k});
    title(titles{k});
  end

  set(gcf, "Name", fig_title, "NumberTitle", "off");
end

