function gui_app()
  % Simple GUI for the separation simulation (GNU Octave)
  %
  % Buttons:
  %   1) Run simulation  - computes trajectories and saves CSV
  %   2) Show plots      - calls postprocess for the last run
  %   3) Run tests       - runs tests/run_tests.m
  %   4) Show orbit      - runs src/plot_orbit_eci_from_elements.m
  %
  % Usage:
  %   >> gui_app

  % --- paths ---
  this_dir = fileparts(mfilename("fullpath"));
  addpath(fullfile(this_dir, "src"));

  % --- GUI state (stored in figure appdata) ---
  state = struct();
  state.has_results = false;
  state.t = [];
  state.X = [];
  state.R = [];
  state.P = struct();
  state.outdir = fullfile(this_dir, "output");
  state.csvpath = fullfile(state.outdir, "results.csv");

  if ~exist(state.outdir, "dir")
    mkdir(state.outdir);
  end

  % --- Create window ---
  f = figure("Name", "Separation simulation (Octave GUI)", ...
             "NumberTitle", "off", ...
             "MenuBar", "none", ...
             "ToolBar", "none", ...
             "Position", [200 120 560 700]);

  set(f, "HandleVisibility", "callback");

  movegui(f, "center");

  % --- Helper: label + edit field ---
  function h = addField(y, label, default_str)
    uicontrol(f, "Style", "text", ...
              "String", label, ...
              "HorizontalAlignment", "left", ...
              "Position", [20 y 280 20]);
    h = uicontrol(f, "Style", "edit", ...
                  "String", default_str, ...
                  "Position", [320 y 160 24]);
  end

  % --- Orbit parameters ---
  uicontrol(f, "Style", "text", "String", "Параметры орбиты (ECI / J2000)", ...
            "FontWeight", "bold", "HorizontalAlignment", "left", ...
            "Position", [20 670 480 20]);

  y = 640;
  h_a   = addField(y, "a, км (большая полуось)", "6700"); y -= 30;
  h_e   = addField(y, "e (эксцентриситет)", "0.003"); y -= 30;
  h_i   = addField(y, "i, град (наклонение)", "80"); y -= 30;
  h_Om  = addField(y, "Ω, град (RAAN)", "-15"); y -= 30;
  h_w   = addField(y, "ω, град (аргумент перицентра)", "30"); y -= 30;
  h_M0  = addField(y, "M0, град (средняя аномалия)", "0"); y -= 40;

  % --- Time parameters ---
  uicontrol(f, "Style", "text", "String", "Время моделирования", ...
            "FontWeight", "bold", "HorizontalAlignment", "left", ...
            "Position", [20 y 480 20]);
  y -= 30;

  h_t0  = addField(y, "t0, c", "0"); y -= 30;
  h_tf  = addField(y, "tf, c", "5"); y -= 30;
  h_dt  = addField(y, "dt, c (шаг вывода, ≤ 0.01)", "0.01"); y -= 40;

  % --- (Optional) Pusher & masses: keep TS defaults but show fields ---
  uicontrol(f, "Style", "text", "String", "Толкатель и массы (по ТЗ, можно менять)", ...
            "FontWeight", "bold", "HorizontalAlignment", "left", ...
            "Position", [20 y 480 20]);
  y -= 30;

  h_mlv = addField(y, "m_LV, кг", "3500"); y -= 30;
  h_msc = addField(y, "m_SC, кг", "3100"); y -= 30;
  h_k   = addField(y, "k, Н/м", "30000"); y -= 30;
  h_Lf  = addField(y, "L_free, м", "0.220"); y -= 30;
  h_L0  = addField(y, "L0, м", "0.110"); y -= 30;
  h_Le  = addField(y, "L_end, м", "0.195"); y -= 50;

  % --- Status text ---
  h_status = uicontrol(f, "Style", "text", ...
                       "String", "Готово. Задайте параметры и нажмите «Начать расчёт».", ...
                       "HorizontalAlignment", "left", ...
                       "Position", [20 100 480 30]);

  % --- Buttons ---
  uicontrol(f, "Style", "pushbutton", "String", "Начать расчёт", ...
            "FontWeight", "bold", ...
            "Position", [20 60 150 35], ...
            "Callback", @onRun);

  uicontrol(f, "Style", "pushbutton", "String", "Вывести графики", ...
            "Position", [190 60 150 35], ...
            "Callback", @onPlots);

  uicontrol(f, "Style", "pushbutton", "String", "Тестирование", ...
            "Position", [360 60 140 35], ...
            "Callback", @onTests);

  uicontrol(f, "Style", "pushbutton", ...
          "String", "Показать орбиту (ECI)", ...
          "Position", [20 20 200 36], ...
          "Callback", @onShowOrbit);

  % Store initial state
  setappdata(f, "state", state);

  % -----------------------
  % Callbacks
  % -----------------------

  function onRun(~, ~)
    try
      set(h_status, "String", "Расчёт...");

      st = getappdata(f, "state");

      % Read numeric inputs
      a_km = str2double(get(h_a, "String"));
      e    = str2double(get(h_e, "String"));
      i    = deg2rad(str2double(get(h_i, "String")));
      Om   = deg2rad(str2double(get(h_Om,"String")));
      w    = deg2rad(str2double(get(h_w, "String")));
      M0   = deg2rad(str2double(get(h_M0,"String")));

      t0   = str2double(get(h_t0,"String"));
      tf   = str2double(get(h_tf,"String"));
      dt   = str2double(get(h_dt,"String"));

      if dt <= 0 || dt > 0.01
        error("dt должен быть > 0 и ≤ 0.01 (по ТЗ).");
      end
      if tf <= t0
        error("tf должен быть больше t0.");
      end

      % Parameters struct P (same fields as in your code)
      P = struct();
      P.mu   = 3.986004418e14;          % [m^3/s^2]
      P.m_lv = str2double(get(h_mlv,"String"));
      P.m_sc = str2double(get(h_msc,"String"));

      P.k      = str2double(get(h_k, "String"));
      P.L_free = str2double(get(h_Lf,"String"));
      P.L0     = str2double(get(h_L0,"String"));
      P.L_end  = str2double(get(h_Le,"String"));

      % Kepler -> r0,v0
      a = a_km * 1e3;
      [r0, v0] = kepler2rv(P.mu, a, e, i, Om, w, M0);

      % Separation axis u = along initial velocity (fixed in ECI)
      P.u = v0 / norm(v0);

      % Initial states: LV at (r0,v0), SC shifted by L0 along u
      x0 = [r0; v0; (r0 + P.L0*P.u); v0];

      % Time grid (exact output nodes)
      t = (t0:dt:tf)';

      % Simulate
      [t, X, R] = simulate_sep(t, x0, P);

      % Export
      export_csv(st.csvpath, t, X, R);

      % Save to state
      st.has_results = true;
      st.t = t; st.X = X; st.R = R; st.P = P;
      setappdata(f, "state", st);

      set(h_status, "String", sprintf("Расчёт завершён. CSV: %s", st.csvpath));
    catch err
      set(h_status, "String", ["Ошибка: " err.message]);
      disp(err);
    end
  end

  function onPlots(~, ~)
    try
      st = getappdata(f, "state");
      if ~st.has_results
        set(h_status, "String", "Сначала выполните расчёт (кнопка «Начать расчёт»).");
        return;
      end

      set(h_status, "String", "Построение графиков...");
      % If your postprocess signature is postprocess(t,X,R,outdir)
      % use: postprocess(st.t, st.X, st.R, st.outdir);
      %
      % If you updated it to accept P (recommended for CM plots):
      % postprocess(st.t, st.X, st.R, st.outdir, st.P);

      % --- Try the 5-arg version first, fallback to 4-arg ---
      try
        postprocess(st.t, st.X, st.R, st.outdir, st.P);
      catch
        postprocess(st.t, st.X, st.R, st.outdir);
      end

      set(h_status, "String", "Графики построены и сохранены в output/.");
    catch err
      set(h_status, "String", ["Ошибка: " err.message]);
      disp(err);
    end
  end

  function onTests(~, ~)
    try
      set(h_status, "String", "Запуск тестов...");
      % Run tests in tests/ folder
      tests_dir = fullfile(this_dir, "tests");
      if ~exist(tests_dir, "dir")
        error("Папка tests/ не найдена.");
      end

      olddir = pwd();
      cd(tests_dir);
      run_tests;     % should exist: tests/run_tests.m
      cd(olddir);

      set(h_status, "String", "Тесты выполнены: OK (см. вывод в консоли).");
    catch err
      try, cd(olddir); catch, end
      set(h_status, "String", ["Ошибка тестов: " err.message]);
      disp(err);
    end
  end

  function onShowOrbit(~, ~)
    try
      % Read elements from GUI
      a  = str2double(get(h_a,  "String")) * 1e3;  % km -> m
      e  = str2double(get(h_e,  "String"));
      i  = deg2rad(str2double(get(h_i,  "String")));
      Om = deg2rad(str2double(get(h_Om, "String")));
      w  = deg2rad(str2double(get(h_w,  "String")));
      M0 = deg2rad(str2double(get(h_M0, "String")));

      plot_orbit_eci_from_elements(a, e, i, Om, w, M0);

      set(h_status, "String", ...
          "Построена кеплерова орбита в ECI (вращение мышью).");

    catch err
      set(h_status, "String", ["Ошибка построения орбиты: " err.message]);
      disp(err);
    end
  end


end





