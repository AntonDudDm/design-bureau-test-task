clear; close all; clc;
addpath("src");

% ==============================
% INPUT DATA
% ==============================

% --- Physical constant (Earth) ---
P.mu = 3.986004418e14;      % [m^3/s^2]

% --- Masses ---
P.m_lv = 3500;              % [kg] stage
P.m_sc = 3100;              % [kg] spacecraft

% --- Spring / pusher ---
P.k      = 30000;           % [N/m]
P.L_free = 0.220;           % [m]
P.L0     = 0.110;           % [m] initial length
P.L_end  = 0.195;           % [m] disengage length

% --- Orbit ---
a_km   = 6700;              % [km]
e      = 0.003;
i_deg  = 80;
Om_deg = -15;
w_deg  = 30;
M0_deg = 0;

a  = a_km * 1e3;            % [m]
i  = deg2rad(i_deg);
Om = deg2rad(Om_deg);
w  = deg2rad(w_deg);
M0 = deg2rad(M0_deg);

% --- Simulation time ---
dt = 0.01;                  % output step <= 0.01 s (TS requirement)
t0 = 0.0;
tf = 5.0;

% --- Output ---
outdir = "output";
outfile = fullfile(outdir, "results.csv");

% ==============================
% RUN
% ==============================
if ~exist(outdir, "dir"), mkdir(outdir); end

% Convert elements to ECI state at t=0
[r0, v0] = kepler2rv(P.mu, a, e, i, Om, w, M0);
fprintf("||r0|| = %.3f km\n", norm(r0)/1e3);
fprintf("||v0|| = %.3f km/s\n", norm(v0)/1e3);

% Direction of separation (fixed in ECI)
P.u = v0 / norm(v0);

% Initial conditions for two bodies
r_lv0 = r0;
v_lv0 = v0;

r_sc0 = r0 + P.L0 * P.u;
v_sc0 = v0;

x0 = [r_lv0; v_lv0; r_sc0; v_sc0];

% Time grid for output
t = (t0:dt:tf)';

% Simulate
[t, X, R] = simulate_sep(t, x0, P);

% Export CSV
export_csv(outfile, t, X, R);
fprintf("Saved: %s\n", outfile);

% Plot results
postprocess(t, X, R, outdir);

