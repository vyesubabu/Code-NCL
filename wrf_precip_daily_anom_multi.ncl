load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

;CONTDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R1_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R1_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R3_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R3_nudging/out/"/)

CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default/out/" 

OUTDIRS=(/"/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST-2/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST-1/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST+1/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST+2/out/"/)
dlist=(/"SST-2","SST-1","SST+1","SST+2"/)

n=0
do while(n.lt.dimsizes(OUTDIRS))

  DATADir = OUTDIRS(n)
;  CONTDir = CONTDIRS(n)
  OUTDir = DATADir

  outfile=OUTDir+"D01_prlr_default_"+dlist(n)

  wks = gsn_open_wks("pdf", outfile+"_dailyanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfhrly_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  FILES1a = systemfunc (" ls -1 " + CONTDir + "wrfhrly_d01_200?-??-??_00:00:00")
  f1a = addfiles(FILES1a+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)

  rain_exp1a=wrf_user_getvar(f1,"RAINNC",-1)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",-1)
  rain_con1a=wrf_user_getvar(f1,"RAINC",-1)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",-1)
  var_in1 = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b
 
  lat1 = wrf_user_getvar(f1,"XLAT",-1)
  lon1 = wrf_user_getvar(f1,"XLONG",-1)
  numDAYS = dimsizes(times)/24
  len=dimsizes(times)-1 

  res                 = True

; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ -50., -25., -10., -5., -2., -1., 1., 2., 5., 10., 25., 50./)
  res@gsnDraw         = False
  res@gsnFrame        = False

  res2 = res

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
  res@gsnMaximize     = True    ; Maximize plot in frame


; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02
  do ip = 1,numDAYS-1      

    print("Working on date : " + times(ip*24) )

    var1 = (var_in1(ip*24,:,:) - var_in1((ip-1)*24,:,:))
    var1@description = "24hr average rainfall difference ("+ times(ip*24) +")"
    var1@units = "mm"
    var1@lat2d = lat1(ip,:,:)
    var1@lon2d = lon1(ip,:,:)
    
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)
    delete(var1)
  
  end do

delete(wks)
  wks = gsn_open_wks("pdf", outfile+"_monthlyanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")     
  res@cnLevels             = (/ -200.,-100., -50., -25., -10., -5., 5., 10., 25., 50.,100.,200./)
    var1 = (var_in1(len,:,:) - var_in1(0,:,:))
    var1@description = "Total Precipitation to " + times(len)
    var1@units = "mm"
    var1@lat2d = lat1(0,:,:)
    var1@lon2d = lon1(0,:,:)
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)


  delete([/FILES1,rain_exp1a,rain_con1a/])
  delete([/FILES1a,rain_exp1b,rain_con1b/])
  delete([/wks,var_in1,lat1,lon1,times/])

n=n+1
end do
end
