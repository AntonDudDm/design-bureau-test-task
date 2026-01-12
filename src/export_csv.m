function export_csv(filename, t, X, R)
  % CSV columns:
  % time |
  % r_lv(3) v_lv(3) r_sc(3) v_sc(3) |
  % d vrel F L
  M = [t, X, R.d, R.vrel, R.F, R.L];
  dlmwrite(filename, M, "delimiter", ",", "precision", 15);
end
