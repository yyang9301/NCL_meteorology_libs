begin
  ;�Ͼ���γ��
  lat_nj = 32.03  
  lon_nj = 118.46              

  ;�ٶ�һ��ѹϵͳ������ĳ5���еľ�γ��λ�� 
  lat_line = (/20,21,22,24,27,29/)
  lon_line = (/124,122.5,120,119,120,121/)
    
  ;�ٶ��õ�ѹϵͳ�ں�4���е�Ӱ�췶Χ����
  center_lat = 25     
  center_lon = 120   
  maxlat_region = center_lat+5
  minlat_region = center_lat-5
  maxlon_region = center_lon+3  
  minlon_region = center_lon-3 
  
  wks = gsn_open_wks("eps","poly_ex")

  res           = True                        ; plot mods desired
  res@gsnFrame    = False
  res@gsnDraw     = False                     ; don't draw plot yet

  res@mpMinLatF   = 15                      ; zoom in on a subregion
  res@mpMaxLatF   = 40
  res@mpMinLonF   = 110
  res@mpMaxLonF   = 130
  
  res@pmTickMarkDisplayMode = "Always"
  
  map = gsn_csm_map(wks,res)    

  ;;���Ӷ���Ρ�ע�⣬Ҫʹͼ�αպϣ������һ�����λ�������һ�����غ�
  boxlat = (/ maxlat_region,  maxlat_region, minlat_region,  minlat_region, maxlat_region/)
  boxlon = (/minlon_region, maxlon_region,maxlon_region, minlon_region,minlon_region/)   

  gonres                  = True             
  
  ;;������������(����ѹ���ĵ��ƶ�·��) 
  lnres                   = True                      

  ;;����marker������ѹ����λ�ã�
  mkres                  = True             

    
  ;;����marker(�Ͼ�λ��)          


  ;;��������

  
  draw(map)
  frame(wks)
    
end