function postprocess(t, X, R, outdir)
  r_lv = X(:, 1:3);
  v_lv = X(:, 4:6);
  r_sc = X(:, 7:9);
  v_sc = X(:,10:12);

  % ----------------------------
  % Existing plots (kept)
  % ----------------------------

  % 3D trajectories
  figure(1);
  plot3(r_lv(:,1), r_lv(:,2), r_lv(:,3), "b-"); hold on;
  plot3(r_sc(:,1), r_sc(:,2), r_sc(:,3), "r-");
  grid on; axis equal;
  xlabel("x, m"); ylabel("y, m"); zlabel("z, m");
  legend("LV", "SC");
  title("3D trajectories in ECI (J2000)");

  % Relative distance
  figure(2);
  plot(t, R.d); grid on;
  xlabel("t, s"); ylabel("d(t), m");
  title("Relative distance");

  % Relative speed
  figure(3);
  plot(t, R.vrel); grid on;
  xlabel("t, s"); ylabel("v_{rel}(t), m/s");
  title("Relative speed");

  % Pusher force
  figure(4);
  plot(t, R.F); grid on;
  xlabel("t, s"); ylabel("F(t), N");
  title("Pusher force");

  % ----------------------------
  % NEW: 4 figures, each with 3 subplots (x/y/z)
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
    catch
      % ignore saving errors in some Octave builds
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

  % Set figure title (simple and robust for Octave)
  set(gcf, "Name", fig_title, "NumberTitle", "off");
end

