function [F, L] = spring_force(r_lv, r_sc, P)
  % Compute spring/pusher force magnitude F >= 0 and current axial length L.
  %
  % L is defined as projection of relative position onto fixed axis u:
  %   L = (r_sc - r_lv) · u
  %
  % Spring force acts only while:
  %   (1) spring is compressed: L < L_free
  %   (2) pusher is engaged:    L < L_end

  dr = r_sc - r_lv;
  L  = dot(dr, P.u);

  if (L < P.L_end) && (L < P.L_free)
    F = P.k * (P.L_free - L);
  else
    F = 0;
  end
end

