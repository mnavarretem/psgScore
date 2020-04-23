function vt_coef = fn_linecoef(vt_x,vt_y)

vt_coef(1) = (vt_y(2)-vt_y(1))/(vt_x(2)-vt_x(1));
vt_coef(2) = vt_y(1) - vt_x(1)*vt_coef(1);
