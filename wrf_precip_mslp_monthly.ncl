load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$VAPOR_HOME/share/examples/NCL/wrf2geotiff.ncl"
;load "./WRFUserARW.ncl"

 res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ .2, 5.,10., 20., 50., 100., 250., 500., /)
  res@cnFillColors         = (/2,11,10,6,7,8,4,5,17/)
  res@gsnDraw         = False
  res@gsnFrame        = False
; Add map resources
  res@mpFillOn              = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
  res@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res@mpLeftCornerLatF   = -50. 
  res@mpLeftCornerLonF   = 130.
  res@mpRightCornerLatF  = -20.
  res@mpRightCornerLonF  = 180. 
  res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  res@mpProjection = "CylindricalEquidistant"
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012
  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = False    ; Maximize plot in frame

    opts_psl = True          
     opts_psl@cnLineColor       = "Blue"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 1.5
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSpacingF = 2.0

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

  outfile="mslp_prlr_test"
  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
  
    FILES1 = "/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/WRF_d01_monthly_uvpr.nc" 
  f1 = addfile(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"SLP_d01",-1)    ; slp
    slp@lat2d = lat1
    slp@lon2d = lon1
    slp@description = ""
    slp@units = ""

  rain = wrf_user_getvar(f1,"PRCP_d01",-1)    ; slp
    rain@lat2d = lat1
    rain@lon2d = lon1
    rain@description = ""
    rain@units = ""

    contour_psl = gsn_csm_contour(wks,slp(:,:,0),opts_psl)    
    map = gsn_csm_contour_map(wks, rain(:,:,0), res)
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
