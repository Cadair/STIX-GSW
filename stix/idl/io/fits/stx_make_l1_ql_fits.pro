
function stx_make_l0_header, header = header, filename=filename, obt_beg=obt_beg, obt_end=obt_end, $
  integration_time = integration_time, history=history

  ;  fxhmake, header, /date, /init, /extend, errmsg = errmsg

  currtime = anytim(!stime, /ccsds)

  ;ToDo: OBT time and date
  sxaddpar, header, 'COMMENT','------------------------------------------------------------------------'
  sxaddpar, header, 'FILENAME',filename,'FITS filename'
  sxaddpar, header, 'DATE',currtime,'FITS file creation date in UTC'
  sxaddpar, header, 'OBT-BEG',trim(string(obt_beg)),'Start of acquisition time in OBT'
;  sxaddpar, header, 'OBT-END',trim(string(obt_end)),'End of acquisition time in OBT'
  sxaddpar, header, 'TIMESYS','OBT','System used for time keywords'
;  sxaddpar, header, 'COMMENT','------------------------------------------------------------------------'
  sxaddpar, header, 'LEVEL','L1','Processing level of the data'
  sxaddpar, header, 'CREATOR','mwrfits','FITS creation software'
  sxaddpar, header, 'ORIGIN','Solar Orbiter SOC, ESAC','Location where file has been generated'
  sxaddpar, header, 'VERS_SW','2.4','Software version'
  sxaddpar, header, 'VERSION','201810121423','Version of data product'
  ;  sxaddpar, header, 'COMPLETE',complete_flag,'C if data complete, I if incomplete'
  sxaddpar, header, 'COMMENT','------------------------------------------------------------------------'
  sxaddpar, header, 'OBSRVTRY','Solar Orbiter','Satellite name'
  sxaddpar, header, 'TELESCOP','SOLO/STIX','Telescope/Sensor name'
  sxaddpar, header, 'INSTRUME','STIX','Instrument name'
  ;  sxaddpar, header, 'OBS_MODE',obs_mode,'Observation mode'
  sxaddpar, header, 'EXPOSURE',string(fix(integration_time)),'[s] Integration time'
;  sxaddpar, header, 'COMMENT','------------------------------------------------------------------------'
  sxaddpar, header, 'HISTORY',history,'Example of SW and runID that created file'
  return, header
end

function stx_make_l1_ql_lightcurve_fits, tm_reader
  tm_reader->getdata, asw_ql_lightcurve=processed_lc, solo=solo

  unprocessed_lc = *solo['stx_tmtc_ql_light_curves',0,0].source_data

  integration_time = unprocessed_lc.INTEGRATION_TIME

  stx_telemetry_util_time2scet, coarse_time = unprocessed_lc.coarse_time, fine_time = unprocessed_lc.fine_time, stx_time_obj=obt_beg, /reverse

  obt_beg = stx_time2any(obt_beg)

  stx_km_compression_schema_to_params, unprocessed_lc.COMPRESSION_SCHEMA_LIGHT_CURVES, k=lc_k, m=lc_m, s=lc_s
  stx_km_compression_schema_to_params, unprocessed_lc.COMPRESSION_SCHEMA_TRIGGER, k=tr_k, m=tr_m, s=tr_s

  strucures = stx_l1_ql_lightcurve_structures(unprocessed_lc.DYNAMIC_NBR_OF_DATA_POINTS)
  control_struc = strucures.control
  data_struc  = strucures.data

  control_struc.integration_time = integration_time
  control_struc.detector_mask = processed_lc[0].detector_mask
  control_struc.pixel_mask = processed_lc[0].pixel_mask
  control_struc.energy_bin_mask = stx_mask2bits(unprocessed_lc.ENERGY_BIN_MASK, /reverse, mask_length=33)
  control_struc.compression_scheme_counts = [lc_k, lc_m, lc_s]
  control_struc.compression_scheme_triggers = [tr_k, tr_m, tr_s]

  data_struc.counts = processed_lc[0].counts
  data_struc.triggers = processed_lc[0].triggers
  data_struc.rate_control_regeime = processed_lc[0].RATE_CONTROL_REGIME

  cur_time = anytim(!stime, /ccsds)
  tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 5)+strmid(cur_time, 14, 2)+strmid(cur_time, 17, 2)

  filename = 'solo_l1_stix-lightcurve_'+trim(string(obt_beg))+'_V'+trim(tstamp)+'.fits'

  mwrfits, !NULL, filename, /create, status=stat0
  mwrfits, control_struc, filename, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2

  primary_header = headfits(filename, exten=0)
  control_header = headfits(filename, exten=1)
  data_header = headfits(filename, exten=2)

  fxaddpar, control_header, 'EXTNAME', 'Control', 'Extension name'
  fxaddpar, data_header, 'EXTNAME', 'Data', 'Extension name'

  primary_header = stx_make_l0_header(header=primary_header, filename=filename, obt_beg=obt_beg, obt_end=obt_end, $
    integration_time=integration_time, history='test')

  mwrfits, !NULL, filename, primary_header, /create, status=stat0
  mwrfits, control_struc,filename,control_header, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2
end

function stx_make_l1_ql_calibraion_spectra_fits, tm_reader
  tm_reader->getdata, asw_ql_calibration_spectrum=processed_calspec, solo=solo

  unprocessed_calspec = *solo['stx_tmtc_ql_calibration_spectrum',0,0].source_data

  stx_telemetry_util_time2scet, coarse_time = unprocessed_calspec.coarse_time, fine_time = 0, stx_time_obj=obt_beg, /reverse

  obt_beg = stx_time2any(obt_beg)
  obt_end = obt_beg + unprocessed_calspec.DURATION

  ; TODO allways 8 sub sepectra or use sub_spectra_mask
  strucures = stx_l1_ql_calibration_spectra_structures(8)
  control_struc = strucures.control
  data_struc  = strucures.data

  control_struc.detector_mask = stx_mask2bits(unprocessed_calspec.DETECTOR_MASK, /reverse, mask_length=32)
  control_struc.pixel_mask = stx_mask2bits(unprocessed_calspec.PIXEL_MASK, /reverse, mask_length=16)
  control_struc.duration = unprocessed_calspec.DURATION
  control_struc.quiet_time = unprocessed_calspec.QUIET_TIME
  control_struc.live_time = unprocessed_calspec.LIVE_TIME
  control_struc.average_temperature = unprocessed_calspec.AVERAGE_TEMPERATURE

  all_sub_specta = processed_calspec[0].subspectra

  for i=0, N_ELEMENTS(all_sub_specta)-1 do begin
    data_struc[i].detecotr_mask = all_sub_specta[i].DETECTOR_MASK
    data_struc[i].pixel_mask = all_sub_specta[i].PIXEL_MASK
    data_struc[i].lower_energy_bound_channel = all_sub_specta[i].LOWER_ENERGY_BOUND_CHANNEL
    data_struc[i].number_of_summed_channels = all_sub_specta[i].NUMBER_OF_SUMMED_CHANNELS
    data_struc[i].number_of_spectral_points = all_sub_specta[i].NUMBER_OF_SPECTRAL_POINTS
  endfor

  cur_time = anytim(!stime, /ccsds)
  tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 5)+strmid(cur_time, 14, 2)+strmid(cur_time, 17, 2)

  filename = 'solo_l1_stix-calibration-spectra'+trim(string(obt_beg))+'_V'+trim(tstamp)+'.fits'

  mwrfits, !NULL, filename, /create, status=stat0
  mwrfits, control_struc, filename, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2

  primary_header = headfits(filename, exten=0)
  control_header = headfits(filename, exten=1)
  data_header = headfits(filename, exten=2)

  fxaddpar, control_header, 'EXTNAME', 'Control', 'Extension name'
  fxaddpar, data_header, 'EXTNAME', 'Data', 'Extension name'

  primary_header = stx_make_l0_header(header=primary_header, filename=filename, obt_beg=obt_beg, obt_end=obt_end, $
    integration_time=unprocessed_calspec.DURATION, history='test')

  mwrfits, !NULL, filename, primary_header, /create, status=stat0
  mwrfits, control_struc,filename,control_header, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2
end

function stx_make_l1_ql_variance_fits, tm_reader
  tm_reader->getdata, asw_ql_variance=processed_var, solo=solo

  unprocessed_var = *solo['stx_tmtc_ql_variance',0,0].source_data

  integration_time = unprocessed_var.INTEGRATION_TIME

  stx_telemetry_util_time2scet, coarse_time = unprocessed_var.coarse_time, fine_time = unprocessed_var.fine_time, stx_time_obj=obt_beg, /reverse

  obt_beg = stx_time2any(obt_beg)
  ; TODO how to calculate obt_end
  obt_end = obt_beg + INTEGRATION_TIME

  stx_km_compression_schema_to_params, unprocessed_var.COMPRESSION_SCHEMA_ACCUM, k=var_k, m=var_m, s=var_s

  strucures = stx_l1_ql_variance_structures(unprocessed_var.NUMBER_OF_SAMPLES)
  control_struc = strucures.control
  data_struc  = strucures.data

  control_struc.integration_time = integration_time
  control_struc.samples_per_variance = processed_var[0].SAMPLES_PER_VARIANCE
  control_struc.detector_mask = processed_var[0].DETECTOR_MASK
  control_struc.energy_mask = stx_mask2bits(unprocessed_var.ENERGY_MASK, /reverse, mask_length=32)
  control_struc.pixel_mask = processed_var[0].PIXEL_MASK
  control_struc.compression_scheme_variance = [var_k, var_m, var_s]

  data_struc.variance = processed_var[0].VARIANCE

  cur_time = anytim(!stime, /ccsds)
  tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 5)+strmid(cur_time, 14, 2)+strmid(cur_time, 17, 2)

  filename = 'solo_l1_stix-variance_'+trim(string(obt_beg))+'_V'+trim(tstamp)+'.fits'

  mwrfits, !NULL, filename, /create, status=stat0
  mwrfits, control_struc, filename, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2

  primary_header = headfits(filename, exten=0)
  control_header = headfits(filename, exten=1)
  data_header = headfits(filename, exten=2)

  fxaddpar, control_header, 'EXTNAME', 'Control', 'Extension name'
  fxaddpar, data_header, 'EXTNAME', 'Data', 'Extension name'

  primary_header = stx_make_l0_header(header=primary_header, filename=filename, obt_beg=obt_beg, obt_end=obt_end, $
    integration_time=integration_time, history='test')

  mwrfits, !NULL, filename, primary_header, /create, status=stat0
  mwrfits, control_struc,filename,control_header, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2
end

function stx_make_l1_ql_spectra_fits, tm_reader
  tm_reader->getdata, stx_asw_ql_spectra=processed_spec, solo=solo

  unprocessed_spec = *solo['stx_tmtc_ql_spectra',0,0].source_data

  integration_time = unprocessed_spec.INTEGRATION_TIME

  stx_telemetry_util_time2scet, coarse_time = unprocessed_spec.coarse_time, fine_time = unprocessed_spec.fine_time, stx_time_obj=obt_beg, /reverse

  obt_beg = stx_time2any(obt_beg)
  obt_end = obt_beg + integration_time * unprocessed_spec.NUMBER_OF_STRUCTURES

  stx_km_compression_schema_to_params, unprocessed_spec.COMPRESSION_SCHEMA_SPECTRUM, k=sp_k, m=sp_m, s=sp_s
  stx_km_compression_schema_to_params, unprocessed_spec.COMPRESSION_SCHEMA_TRIGGER, k=tr_k, m=tr_m, s=tr_s

  ; TODO Why is the number of spectra in processed and unproccesed different?
  structures = stx_l1_ql_spectrum_structures((size(processed_spec[0].spectrum, /dim))[-1])
  control_struc = structures.control
  data_struc = structures.data

  control_struc.pixel_mask = processed_spec[0].PIXEL_MASK
  control_struc.integration_time = integration_time
  control_struc.compression_scheme_spec = [sp_k, sp_m, sp_s]
  control_struc.compression_scheme_trigger = [tr_k, tr_m, tr_s]

  data_struc.detector_mask = processed_spec[0].DETECTOR_MASK
  data_struc.triggers = processed_spec[0].TRIGGERS
  data_struc.spectrum = processed_spec[0].SPECTRUM

  cur_time = anytim(!stime, /ccsds)
  tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 5)+strmid(cur_time, 14, 2)+strmid(cur_time, 17, 2)

  filename = 'solo_l1_stix-spectra_'+trim(string(obt_beg))+'_V'+tstamp+'.fits'

  mwrfits, !NULL, filename, /create, status=stat0
  mwrfits, control_struc, filename, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2

  primary_header = headfits(filename, exten=0)
  control_header = headfits(filename, exten=1)
  data_header = headfits(filename, exten=2)

  fxaddpar, control_header, 'EXTNAME', 'Control', 'Extension name'
  fxaddpar, data_header, 'EXTNAME', 'Data', 'Extension name'

  primary_header = stx_make_l0_header(header=primary_header, filename=filename, obt_beg=obt_beg, obt_end=obt_end, $
    integration_time=integration_time, history='test')

  mwrfits, !NULL, filename, primary_header, /create, status=stat0
  mwrfits, control_struc,filename,control_header, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2
end

function stx_make_l1_ql_background_fits, tm_reader
  tm_reader->getdata, asw_ql_background_monitor=processed_bg, solo=solo

  unprocessed_bg = *solo['stx_tmtc_ql_background_monitor',0,0].source_data

  integration_time = unprocessed_bg.INTEGRATION_TIME

  stx_telemetry_util_time2scet, coarse_time = unprocessed_bg.coarse_time, fine_time = unprocessed_bg.fine_time, stx_time_obj=obt_beg, /reverse

  obt_beg = stx_time2any(obt_beg)
  obt_end = obt_beg + integration_time

  stx_km_compression_schema_to_params, unprocessed_bg.COMPRESSION_SCHEMA_BACKGROUND, k=bg_k, m=bg_m, s=bg_s
  stx_km_compression_schema_to_params, unprocessed_bg.COMPRESSION_SCHEMA_TRIGGER, k=tr_k, m=tr_m, s=tr_s

  structures = stx_l1_ql_background_structures( unprocessed_bg[0].NUMBER_OF_ENERGIES, unprocessed_bg[0].DYNAMIC_NBR_OF_DATA_POINTS)
  control_struc = structures.control
  data_struc = structures.data

  control_struc.integration_time = integration_time
  control_struc.energy_bin_mask = (stx_mask2bits(unprocessed_bg.ENERGY_BIN_MASK, /reverse, mask_length=33))[0:-2]
  control_struc.compression_schema_background = [bg_k, bg_m, bg_s]
  control_struc.compression_schema_trigger = [tr_k, tr_m, tr_s]

  data_struc.triggers = processed_bg[0].TRIGGERS
  data_struc.background = processed_bg[0].BACKGROUND

  cur_time = anytim(!stime, /ccsds)
  tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 5)+strmid(cur_time, 14, 2)+strmid(cur_time, 17, 2)

  filename = 'solo_l1_stix-background_'+trim(string(obt_beg))+'_V'+tstamp+'.fits'

  mwrfits, !NULL, filename, /create, status=stat0
  mwrfits, control_struc, filename, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2

  primary_header = headfits(filename, exten=0)
  control_header = headfits(filename, exten=1)
  data_header = headfits(filename, exten=2)

  fxaddpar, control_header, 'EXTNAME', 'Control', 'Extension name'
  fxaddpar, data_header, 'EXTNAME', 'Data', 'Extension name'

  primary_header = stx_make_l0_header(header=primary_header, filename=filename, obt_beg=obt_beg, obt_end=obt_end, $
    integration_time=integration_time, history='test')

  mwrfits, !NULL, filename, primary_header, /create, status=stat0
  mwrfits, control_struc,filename,control_header, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2
end

function stx_make_l1_ql_flareflag_location_fits, tm_reader
  tm_reader->getdata, asw_ql_flare_flag_location=processed_fl, solo=solo

  unprocessed_fl = *solo['stx_tmtc_ql_flare_flag_location',0,0].source_data

  integration_time = unprocessed_fl.INTEGRATION_TIME

  stx_telemetry_util_time2scet, coarse_time = unprocessed_fl.coarse_time, fine_time = unprocessed_fl.fine_time, stx_time_obj=obt_beg, /reverse

  obt_beg = stx_time2any(obt_beg)
  obt_end = obt_beg + integration_time

  structures = stx_l1_ql_flare_flag_location(unprocessed_fl.NUMBER_OF_SAMPLES)
  control_struc = structures.control
  data_struc = structures.data

  control_struc.integration_time = integration_time
  control_struc.n_samples = unprocessed_fl.NUMBER_OF_SAMPLES

  data_struc.flare_flag = processed_fl[0].FLARE_FLAG
  data_struc.loc_z = processed_fl[0].X_POS
  data_struc.loc_y = processed_fl[0].Y_POS

  cur_time = anytim(!stime, /ccsds)
  tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 5)+strmid(cur_time, 14, 2)+strmid(cur_time, 17, 2)

  filename = 'solo_l1_stix-flareflag_location_'+trim(string(obt_beg))+'_V'+tstamp+'.fits'

  mwrfits, !NULL, filename, /create, status=stat0
  mwrfits, control_struc, filename, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2

  primary_header = headfits(filename, exten=0)
  control_header = headfits(filename, exten=1)
  data_header = headfits(filename, exten=2)

  fxaddpar, control_header, 'EXTNAME', 'Control', 'Extension name'
  fxaddpar, data_header, 'EXTNAME', 'Data', 'Extension name'

  primary_header = stx_make_l0_header(header=primary_header, filename=filename, obt_beg=obt_beg, obt_end=obt_end, $
    integration_time=integration_time, history='test')

  mwrfits, !NULL, filename, primary_header, /create, status=stat0
  mwrfits, control_struc,filename,control_header, status=stat1
  mwrfits, data_struc, filename, data_header, status=stat2
end

;+
; :project:
;       STIX
;
; :name:
;       stx_make_l1_ql_fits
;
; :purpose:
;       Creates STIX internal l1 fits file from TM data
;
; :categories:
;       telemetry, fits, io
;
; :keyword:
;    scenario_name : in, type="str"
;             Folder containing the TMTC binary
;
; :returns:
;
;
; :examples:
;    stx_make_l1_ql_fits, scenario_name='stx_scenario2'
;
; :history:
;       02-May-2018 – SAM (TCD) init
;
;-
pro stx_make_l1_ql_fits, scenario_name=scenario_name
  default, scenario_name, 'stx_scenario_2'

  tm_reader = stx_telemetry_reader(filename=scenario_name + '/tmtc.bin')

  tm_reader.getdata, solo_packets=solo_packets

  if solo_packets.haskey('stx_tmtc_ql_light_curves') then ql_lc = stx_make_l1_ql_lightcurve_fits(tm_reader)
  if solo_packets.haskey('stx_tmtc_ql_calibration_spectrum') then ql_cal_spectra = stx_make_l1_ql_calibraion_spectra_fits(tm_reader)
  if solo_packets.haskey('stx_tmtc_ql_variance') then ql_variance = stx_make_l1_ql_variance_fits(tm_reader)
  if solo_packets.haskey('stx_tmtc_ql_spectra') then ql_spectra = stx_make_l1_ql_spectra_fits(tm_reader)
  if solo_packets.haskey('stx_tmtc_ql_background_monitor') then ql_background = stx_make_l1_ql_background_fits(tm_reader)
  if solo_packets.haskey('stx_tmtc_ql_flare_flag_location') then ql_flarelist = stx_make_l1_ql_flareflag_location_fits(tm_reader)

end
