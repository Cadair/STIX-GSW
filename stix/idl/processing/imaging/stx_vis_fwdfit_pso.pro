;+
;
; NAME:
;   stx_vis_fwdfit_pso
;
; PURPOSE:
;   Wrapper around vis_fwdfit_pso
;
;-
;
function stx_vis_fwdfit_pso, type, vis, $
  lower_bound = lower_bound, upper_bound = upper_bound, $
  param_opt = param_opt, $
  n_birds = n_birds, tolerance = tolerance, maxiter = maxiter, $
  uncertainty = uncertainty, $
  imsize=imsize, pixel=pixel, $
  silent = silent, $
  srcstr = srcstr, $
  fitsigmas =fitsigmas, $
  seedstart = seedstart
  
  phi= max(abs(vis.obsvis))
  
  ; stix view  
  this_vis = vis
  this_vis.xyoffset[0] = vis.xyoffset[1]
  this_vis.xyoffset[1] = - vis.xyoffset[0]
  
  case type of
    'circle': begin
      
      default, param_opt, ['fit', 'fit', 'fit', 'fit']
      default, lower_bound, [0.1*phi, -100., -100., 1.]
      default, upper_bound, [1.5*phi, 100., 100., 100.]
      
      if (n_elements(param_opt) ne 4) or (n_elements(lower_bound) ne 4) or (n_elements(upper_bound) ne 4) then begin
        UNDEFINE, lower_bound
        UNDEFINE, upper_bound
        UNDEFINE, param_opt
        message, 'Wrong number of elements of lower bound, upper bound or parameter mask'
      endif
      
      this_param_opt = param_opt
      this_upper_bound = upper_bound
      this_lower_bound = lower_bound

      this_upper_bound[1] = upper_bound[2]
      this_upper_bound[2] = - lower_bound[1]
      
      this_lower_bound[1] = lower_bound[2]
      this_lower_bound[2] = - upper_bound[1]
                  
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        x_stix_c:
        flag=0
        this_param_opt[1] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, x_stix_c
      ; Cause type conversion error.
      if flag then this_param_opt[1] = string(double(param_opt[2]))
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        y_stix_c:
        flag=0
        this_param_opt[2] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, y_stix_c
      ; Cause type conversion error.
      if flag then this_param_opt[2] = string( - double(param_opt[1]))

    end

    'ellipse': begin    
      
      default, param_opt, ['fit', 'fit', 'fit', 'fit', 'fit', 'fit']
      default, lower_bound, [0.1*phi,  1., -5., 0., -100., -100.]
      default, upper_bound, [1.5*phi, 100., 5., 1., 100., 100.]
      
      if (n_elements(param_opt) ne 6) or (n_elements(lower_bound) ne 6) or (n_elements(upper_bound) ne 6) then begin
        UNDEFINE, lower_bound
        UNDEFINE, upper_bound
        UNDEFINE, param_opt
        message, 'Wrong number of elements of lower bound, upper bound or parameter mask'
      endif
            
      this_param_opt = param_opt
      this_upper_bound = upper_bound
      this_lower_bound = lower_bound
      
      this_upper_bound[4] = upper_bound[5]
      this_upper_bound[5] = - lower_bound[4]

      this_lower_bound[4] = lower_bound[5]
      this_lower_bound[5] = - upper_bound[4]
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        pa_stix_e:
        flag=0
        this_param_opt[3] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, pa_stix_e
      ; Cause type conversion error.
      if flag then this_param_opt[3] = string(double(param_opt[3])-90.)
                  
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        x_stix_e:
        flag=0
        this_param_opt[4] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, x_stix_e
      ; Cause type conversion error.
      if flag then this_param_opt[4] = string(double(param_opt[5]))
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        y_stix_e:
        flag=0
        this_param_opt[5] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, y_stix_e
      ; Cause type conversion error.
      if flag then this_param_opt[5] = string(- double(param_opt[4]))
      
    end

    'multi': begin
      default, param_opt, ['fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit']
      default, lower_bound, [0.,  0.1*phi, 0.,  0.1*phi, -100., -100., -100., -100.]
      default, upper_bound, [100., 1.5*phi, 100., 1.5*phi, 100., 100., 100., 100.]
      
      if (n_elements(param_opt) ne 8) or (n_elements(lower_bound) ne 8) or (n_elements(upper_bound) ne 8) then begin
        UNDEFINE, lower_bound
        UNDEFINE, upper_bound
        UNDEFINE, param_opt
        message, 'Wrong number of elements of lower bound, upper bound or parameter mask'
      endif
      
      this_param_opt = param_opt
      this_upper_bound = upper_bound
      this_lower_bound = lower_bound
      
      this_upper_bound[4] = upper_bound[5]
      this_upper_bound[5] = - lower_bound[4]
      this_upper_bound[6] = upper_bound[7]
      this_upper_bound[7] = - lower_bound[6]

      this_lower_bound[4] = lower_bound[5]
      this_lower_bound[5] = - upper_bound[4]
      this_lower_bound[6] = lower_bound[7]
      this_lower_bound[7] = - upper_bound[6]
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        x1_stix_m:
        flag=0
        this_param_opt[4] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, x1_stix_m
      ; Cause type conversion error.
      if flag then this_param_opt[4] = string(double(param_opt[5]))
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        y1_stix_m:
        flag=0
        this_param_opt[5] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, y1_stix_m
      ; Cause type conversion error.
      if flag then this_param_opt[5] = string(- double(param_opt[4]))
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        x2_stix_m:
        flag=0
        this_param_opt[6] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, x2_stix_m
      ; Cause type conversion error.
      if flag then this_param_opt[6] = string(double(param_opt[7]))

      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        y2_stix_m:
        flag=0
        this_param_opt[7] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, y2_stix_m
      ; Cause type conversion error.
      if flag then this_param_opt[7] = string(- double(param_opt[6]))
      
    end

    'loop': begin
      default, param_opt, ['fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit']
      default, lower_bound, [0.1*phi,  1., -5., 0., -100., -100., -180.]
      default, upper_bound, [1.5*phi, 100., 5., 1., 100., 100., 180.]
      
      if (n_elements(param_opt) ne 7) or (n_elements(lower_bound) ne 7) or (n_elements(upper_bound) ne 7) then begin
        UNDEFINE, lower_bound
        UNDEFINE, upper_bound
        UNDEFINE, param_opt
        message, 'Wrong number of elements of lower bound, upper bound or parameter mask'
      endif
      
      this_param_opt = param_opt
      this_upper_bound = upper_bound
      this_lower_bound = lower_bound
      
      this_upper_bound[4] = upper_bound[5]
      this_upper_bound[5] = - lower_bound[4]

      this_lower_bound[4] = lower_bound[5]
      this_lower_bound[5] = - upper_bound[4]
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        pa_stix_l:
        flag=0
        this_param_opt[3] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, pa_stix_l
      ; Cause type conversion error.
      if flag then this_param_opt[3] = string(double(param_opt[3])-90.)
      
      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        x_stix_l:
        flag=0
        this_param_opt[4] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, x_stix_l
      ; Cause type conversion error.
      if flag then this_param_opt[4] = string(double(param_opt[5]))

      flag=1
      Catch, theError
      IF theError NE 0 THEN BEGIN
        Catch, /Cancel
        y_stix_l:
        flag=0
        this_param_opt[5] = 'fit'
      ENDIF
      ; Set up file I/O error handling.
      ON_IOError, y_stix_l
      ; Cause type conversion error.
      if flag then this_param_opt[5] = string(- double(param_opt[4]))
    end

  endcase
  
  
  param_out = vis_fwdfit_pso(type, this_vis, $
    lower_bound = this_lower_bound, upper_bound = this_upper_bound, $
    param_opt = this_param_opt, $
    n_birds = n_birds, tolerance = tolerance, maxiter = maxiter, $
    uncertainty = uncertainty, $
    imsize=imsize, pixel=pixel, $
    silent = silent, $
    seedstart = seedstart)
  
  srcstr = param_out.srcstr
  fitsigmas = param_out.fitsigmas
  fwdfit_pso_map = make_map(param_out.data);, xcen=xyoffset[0],ycen=xyoffset[1], dx = pixel[0], dy = pixel[1], id = 'STIX PSO' )
  this_estring=strtrim(fix(vis[0].energy_range[0]),2)+'-'+strtrim(fix(vis[0].energy_range[1]),2)+' keV'
  fwdfit_pso_map.ID = 'STIX VIS_PSO '+this_estring+': '
  fwdfit_pso_map.dx = pixel[0]
  fwdfit_pso_map.dy = pixel[1]

  this_time_range = stx_time2any(vis[0].time_range,/vms)
  
  fwdfit_pso_map.xc = vis[0].xyoffset[0]
  fwdfit_pso_map.yc = vis[0].xyoffset[1]  

  fwdfit_pso_map.time = anytim((anytim(this_time_range[1])+anytim(this_time_range[0]))/2.,/vms)
  fwdfit_pso_map.DUR  = anytim(this_time_range[1])-anytim(this_time_range[0])
  
  if ~keyword_set(silent) then begin

    PRINT
    PRINT, 'COMPONENT    TYPE          FLUX       FWHM MAX    FWHM MIN      Angle     X loc      Y loc      Loop FWHM'
    PRINT, '                         cts/s/keV     arcsec      arcsec        deg      arcsec     arcsec        deg   '
    PRINT

  endif

  nsrc = N_ELEMENTS(srcstr)
  FOR n = 0, nsrc-1 DO BEGIN

    ; heliocentric view
    x_new = srcstr[n].srcy - this_vis[0].xyoffset[1]
    y_new = srcstr[n].srcx - this_vis[0].xyoffset[0]

    ;; Center of the sources corrected for Frederic's mean shift values
    srcstr[n].srcx        = - x_new + vis[0].xyoffset[0] + 26.1
    srcstr[n].srcy        = y_new + vis[0].xyoffset[1]  + 58.2

    srcstr[n].SRCPA += 90.

    if ~keyword_set(silent) then begin

    temp        = [ srcstr[n].srcflux,srcstr[n].srcfwhm_max,  srcstr[n].srcfwhm_min, $
      srcstr[n].srcpa, srcstr[n].srcx, srcstr[n].srcy, srcstr[n].loop_angle]
    PRINT, n+1, srcstr[n].srctype, temp, FORMAT="(I5, A13, F13.2, 1F13.1, F12.1, 2F11.1, F11.1, 2F12.1)"

    temp        = [ fitsigmas[n].srcflux,fitsigmas[n].srcfwhm_max, fitsigmas[n].srcfwhm_min, $
      fitsigmas[n].srcpa, fitsigmas[n].srcy, fitsigmas[n].srcx, fitsigmas[n].loop_angle]
    PRINT, ' ', '(std)', temp, FORMAT="(A7, A11, F13.2, 1F13.1, F12.1, 2F11.1, F11.1, 2F12.1)"
    PRINT, ' '

    endif

  endfor
  
  undefine, param_opt
  undefine, upper_bound
  undefine, lower_bound
  
  ;rotate map to heliocentric view
  fwdfit_pso__map = fwdfit_pso_map
  fwdfit_pso__map.data = rotate(fwdfit_pso_map.data,1) 
    
  ;; Mapcenter corrected for Frederic's mean shift values
  fwdfit_pso__map.xc = vis[0].xyoffset[0] + 26.1
  fwdfit_pso__map.yc = vis[0].xyoffset[1] + 58.2
  
  data = stx_get_l0_b0_rsun_roll_temp(this_time_range[0])

  fwdfit_pso__map.roll_angle    = data.ROLL_ANGLE
  add_prop,fwdfit_pso__map,rsun = data.RSUN
  add_prop,fwdfit_pso__map,B0   = data.B0
  add_prop,fwdfit_pso__map,L0   = data.L0
  
return, fwdfit_pso__map

end
