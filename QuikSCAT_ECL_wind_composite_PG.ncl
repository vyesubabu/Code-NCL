load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data40/z3444417/ECLs/Browning/3_FILTERED_EVENTS/v14p1_in-v14p1_out/1990-2010/PG3/AMS_LAND/WRF-N50/txt/"
DATADIR="/srv/ccrc/data40/z3444417/Data/QuikSCATM/global/"
OUTDIR="/srv/ccrc/data37/z3478332/ECL_evaluation/"
syear=1988

source="JRA55" ;"ERAI-75-6"
sres="50-6"
res=50
thresh="PG3"
duration="D3"

; This is the dimensions of the output grid
; Unlike mLDB, where all rounded to nearest 0.5-1 degree so points never match, for this one they can be centred anywhere so centre on the closest point
  lon0=fspan(-10,10,81)
  lon0!0="lon"
  lon0@units="degrees_E"
  lat0=fspan(-10,10,81)
  lat0!0="lat"
  lat0@units="degrees_N"

  filename = ECLDIR+source+"-"+sres+"-global-present-"+res+"-6_v14p1-"+duration+"-"+thresh+".csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  quote = inttochar(34) 
  delim=","+quote
  date1 = tointeger(str_get_field(data,3,delim))
  I=ind(date1.ge.syear)
  date = tointeger(str_get_field(data(I),3,delim))*10000+tointeger(str_get_field(data(I),4,delim))*100+tointeger(str_get_field(data(I),5,delim))

  time = tointeger(str_get_field(data(I),6,delim))/6
  lat = tofloat(str_get_field(data(I),7,delim))
  lon= tofloat(str_get_field(data(I),8,delim))
  len=dimsizes(date)  

  ECL_U10=new((/len,dimsizes(lat0),dimsizes(lon0)/),"float")
  ECL_U10!0="Time"
  ECL_U10!1="lat"
  ECL_U10!2="lon"
  ECL_V10=ECL_U10
  ECL_U10@description="6-hour instantaneous 10m zonal wind within 1000km radius of low centre"
  ECL_V10@description="6-hour instantaneous 10m meridional wind within 1000km radius of low centre"

; Get info about the 
  f1=addfile(DATADIR+"U10/raw/analysis_19880101_v11l30flk.nc","r")
  lat1=f1->lat
  lon1=f1->lon

  I=ind_nearest_coord(lat,lat1,0)
  J=ind_nearest_coord(lon,lon1,0)

; Now, load in the data for each of our time steps.

  do ip=0,len-1
      if(mod(ip,100).eq.0)
         print(date(ip))
      end if
      FILE1=addfile(DATADIR+"U10/raw/analysis_"+date(ip)+"_v11l30flk.nc","r")
      FILE2=addfile(DATADIR+"V10/raw/analysis_"+date(ip)+"_v11l30flk.nc","r")

      u=short2flt(FILE1->uwnd(time(ip),:,:))
      v=short2flt(FILE2->vwnd(time(ip),:,:))     
      ECL_U10(ip,:,:)=u((I(ip)-40):(I(ip)+40),(J(ip)-40):(J(ip)+40))
      ECL_V10(ip,:,:)=v((I(ip)-40):(I(ip)+40),(J(ip)-40):(J(ip)+40))
      
      delete([/FILE1,FILE2,u,v/])
  end do

; Finally, write me a netcdf file
ECL_WS10=(ECL_U10^2+ECL_V10^2)^0.5
print(max(ECL_WS10))
copy_VarMeta(ECL_U10,ECL_WS10)
ECL_WS10@description="6-hour instantaneous wind speed within 500km radius of low centre"

fout=OUTDIR+"ECLwind_QuikSCAT_"+source+"-"+res+"-"+duration+"-"+thresh+".nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_U10=ECL_U10
out->ECL_V10=ECL_V10
out->ECL_WS10=ECL_WS10
