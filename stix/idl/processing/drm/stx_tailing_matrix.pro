;+
; :description:
;    This procedure calculates the tailing due to incomplete charge collection as a single matrix.
;
; :categories:
;    detector
;
; :params:
;
;    energy        : in, required, type="float"
;                    energy binning of energy loss matrix in keV
;
; :keywords:
;
;    depth         : in, type="float"
;                    depth of  detector in cm
;
;    detector      : in, type = "string", default = 'cdte'
;                    type of detector, can be any accepted by det_xsec
;
;    trap_length_e : in, type= "float", default =  0.66/depth
;                    electron trapping length [cm] = electron mobility * electron lifetime  * electric field strength.
;                                                  = 1100 [cm2/V*s]    * 3x10-6 [s]         * (200 [V] /detector depth [cm])
;
;    trap_length_h : in, type= "float", default = 0.02/depth
;                    hole trapping length [cm] = hole mobility * hole lifetime  * electric field strength.
;                                              = 100 [cm2/V*s] * 1x10-6 [s]     * (200 [V] /detector depth [cm])
; :returns:
;    strarr[10, 15] with text in it
;
; :examples:
;    mat = stx_tailing_matrix(findgen(100)+1.)
;
;
; :history:
;    14-Jun-2017 - ECMD (Graz), initial release
;
;-
function  stx_tailing_matrix, energy, depth=depth, trap_length_h = trap_length_h, trap_length_e = trap_length_e, detector = detector, include_damage = include_damage , damage_layer_depth = damage_layer_depth

  nen = n_elements(energy)
  
  tailing_matrix = fltarr(nen,nen)
  
  default, depth, 0.1 ; detector depth in cm
  default, n_layers, 1000l ;  number of layers to use in calculation
  default, trap_length_h, 0.36*1e4 ; mean free path for holes in cm
  default, trap_length_e, 24*1e4 ; mean free path for electrons in cm
  default, include_damage, 1 ;  if true include a damage layer of reduced charge collecting efficiency
  default, damage_layer_depth, 15 ; depth of damage layer in micrometres
  default, detector, 'cdte'
  
  ;distance into detector in micrometres for the edge of each layer
  x = 1e4*depth*findgen(n_layers)/n_layers
  
  ;convert depth to micrometers
  d = depth*1d4
  
  ;use the hecht equation to estimate the charge collecting efficiency
  h = (trap_length_h*(1.-exp(-x/trap_length_h)) + trap_length_e*(1.- exp(-(d-x)/trap_length_e)))/d
  
  
  if include_damage then begin
    ; as effieencly changed rapidly in the damage layer a large number of finer
    ;layers are used
    n_damage = long(n_layers/2)
    
    tm = damage_layer_depth/2. ; the mean depth of the damage layer
    
    a = 1  ; parameter representing the speed of the drop off
    
    idx_damage_layer = where(x lt damage_layer_depth,  complement = comp)
    t = damage_layer_depth*findgen(n_damage)/n_damage
    
    ;the sharp drop off in efficiency in the damage layer is modelled
    ;using a complementary error function
    damage_layer_efficiency = 0.5 * erfc((t - tm)*a/damage_layer_depth)
    
    x = [t, x[comp]]
    h = [reverse(damage_layer_efficiency), h[comp]]
    
  endif
  
  edge_products, energy, edges_2 = ein, mean = emin
  edge_products, x, width = dx, mean = mx
  
  s_pe  = det_xsec( emin, det = detector, TYP='PE', error = error )  ;photoelectric xsec in 1/cm
  s_cmp = det_xsec( emin, det = detector, TYP='SI', error = error )  ;compton xsec  in 1/cm
  
  stot = ( s_pe + s_cmp ) / 1e4 ;total cross section in 1/micrometres
  
  ;loop over the layers in depth
  for i = 0,  n_layers-2 do begin
  
    ;output energy is given by input energy x charge collection efficiency
    f = energy*h[i]
    
    ;loop over energy
    for j = 0, nen-2 do begin
    
      ;the fraction of interactions in a given slice is calculated as
      ;P(interaction hasn’t occurred by depth x)*P(interaction will occur in slice of with dx)/P(interaction will occur in depth of detector)
      pslice = exp(-stot[j]*mx[i])*(1.- exp(-stot[j]*dx[i]))/(1.- exp(-stot[j]*d))
      
      ;find the bins in energy where
      g = value_locate(energy, f[j:j+1])
      case 1 of
      
        ;if output falls entirely within one energy bin
        g[0] eq g[1] and g[0] ge 0 : tailing_matrix[j,g[0]] += pslice
        
        ;if output falls entirely below the lowest energy bin
        g[0] eq g[1] and g[0] lt 0 : break
        
        ;if output straddles the lowest energy bin
        g[0] ne g[1] and g[0] lt 0 : tailing_matrix[j, g[1]] +=  abs((f[j+1] - energy[g[1]])/(f[j+1]-f[j]))*pslice
        
        ;otherwise split the faction proportionally  between the two valid energy bins
        else: tailing_matrix[j, g] +=  abs((f[j:j+1] - energy[g[1]])/(f[j+1]-f[j]))*pslice
        
      endcase
      
    endfor
  endfor
  
  return, transpose(tailing_matrix)
  
end