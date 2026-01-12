function R = rotmat(axis, ang)
  % ROTMAT  Rotation matrix about a principal axis.
%
%   R = ROTMAT(AXIS, ANG) returns a 3x3 right-handed rotation matrix
%   by angle ANG (radians) about the specified principal axis.
%
%   AXIS:
%     1 - rotation about X-axis (R1)
%     3 - rotation about Z-axis (R3)
%
%   The matrix multiplies column vectors: v_rot = R * v


  c = cos(ang); s = sin(ang);
  switch axis
    case 1
      R = [1 0 0;
           0 c -s;
           0 s c];
    case 3
      R =  [c -s 0;
            s c 0;
            0 0 1];
    otherwise
      error("rotmat: axis must be 1 or 3");
  end
end

