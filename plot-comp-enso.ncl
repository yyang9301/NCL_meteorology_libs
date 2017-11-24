load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
year=ispan(1979,2013,1)  ; 79/80 - 13/14

it_s=197912  ;��ʼ����
it_e=201411  ;��������

refmag = 3   ;�ο���ͷ����ʾ�ķ��ٴ�С

;;;read data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
   ;;  sst


   time   = f_sst->time              ; ��ȡ������
       ; ת���ɹ�������

          ; ��ȡָ��ʱ���
          ;
    ;

   ;; h300 
   f_h300 = addfile("./data/h300-197901-201412.nc", "r")
   h300   = short2flt(f_h300->hgt(rec_s:rec_e,0,{-90:90},:))  

   ;; u850 
   f_u850 = addfile("./data/u850-197901-201412.nc", "r")
   u850   = short2flt(f_u850->uwnd(rec_s:rec_e,0,{-90:90},:))  ; 850 hPa    
   
   ;; v850 
   f_v850 = addfile("./data/v850-197901-201412.nc", "r")
   v850   = short2flt(f_v850->vwnd(rec_s:rec_e,0,{-90:90},:))  ; 850 hPa

   ;; air2m 
   f_air2m = addfile("./data/air2m-197901-201412.nc", "r")
   air2m   = short2flt(f_air2m->air(rec_s:rec_e,0,{-90:90},:))  ; T at 2m    

;;;DJF ƽ�� & �쳣 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ;JFM����ƽ����ʵ����12/1/2��������ƽ������Ϊ��1979��12�¿�ʼ��ȡ
  copy_VarMeta(sst(0,:,:),sst_DJF(0,:,:))
  sst_DJF!0 = "year"
  sst_DJF&year=year 
  
  sst_ano = dim_rmvmean_n_Wrap(sst_DJF,0)
   
  ;; h300
  h300_DJF = month_to_season(h300, "JFM") 
  copy_VarMeta(h300(0,:,:),h300_DJF(0,:,:))
  h300_DJF!0 = "year"
  h300_DJF&year=year 

  h300_ano = dim_rmvmean_n_Wrap(h300_DJF,0)

  ;; u850 ��h300 ͬά  
  u850_DJF = month_to_season(u850, "JFM") 
  copy_VarMeta(h300_DJF,u850_DJF)

  u850_ano = dim_rmvmean_n_Wrap(u850_DJF,0)
  
  ;; v850 ��h300 ͬά  
  v850_DJF = month_to_season(v850, "JFM") 
  copy_VarMeta(h300_DJF,v850_DJF)   

  v850_ano = dim_rmvmean_n_Wrap(v850_DJF,0)
    
  ;; air2m
  air2m_DJF = month_to_season(air2m, "JFM") 
  copy_VarMeta(air2m(0,:,:),air2m_DJF(0,:,:))
  air2m_DJF!0   ="year"
  air2m_DJF&year=year   
    
  air2m_ano = dim_rmvmean_n_Wrap(air2m_DJF,0)
    
;;;(3) enso index (5N-5S, 170-120W);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
     ; 0��ʾ���÷�ȱʡ����ֵ���м��� 
     ;1 ��ʾ��׼��ʱ���Ե���[N] ; ��0��ʾ����[N-1]
  
  ;; �����netcdf�ļ�
  path_out = "ENSO-index.nc"
  system("rm -f "+ path_out)      ; ����ǰ·������ͬ���ļ�����ɾ��
  ncdf = addfile(path_out,"c")    ; "c" ��ʾ���� netCDF �ļ�
  ncdf->ensoi = ensoi
  
;;;(4) composite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  nnumb = dimsizes(irec_positive) 
  
    
  h300_comp  = dim_avg_n_Wrap(h300_ano(irec_positive,:,:),0) 
  u850_comp  = dim_avg_n_Wrap(u850_ano(irec_positive,:,:),0)    
  v850_comp  = dim_avg_n_Wrap(v850_ano(irec_positive,:,:),0) 
  air2m_comp = dim_avg_n_Wrap(air2m_ano(irec_positive,:,:),0)  

;;; (5) t-test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; sst


  ;; h300
  h300_std = dim_variance_n_Wrap(h300_ano(irec_positive,:,:),0)
  h300_std = sqrt(h300_std/nnumb)
  t_h300   = h300_comp/h300_std       
  confi_h300 = h300_comp
  confi_h300 = student_t(t_h300, nnumb-1)   

  ;; air2m
  air2m_std = dim_variance_n_Wrap(air2m_ano(irec_positive,:,:),0)
  air2m_std = sqrt(air2m_std/nnumb)
  t_air2m   = air2m_comp/air2m_std       
  confi_air2m = air2m_comp
  confi_air2m = student_t(t_air2m, nnumb-1) 
    
;;; (5) plot
  wks = gsn_open_wks("eps","plot-comp-enso")
  gsn_define_colormap(wks,"rainbow+gray")  ; ����rainbow+grayɫ��,������ɫ�����������http://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml
  
  base = new(3,"graphic")
  plot = new(3,"graphic")  
        
  res                   = True   ; ������ͼ�������Ե�ֵ��, ÿ����ͼ�����res
  res@gsnAddCyclic      = True   ; ����ѭ���㣬�������0�Ⱦ���������һ������
  res@gsnDraw           = False        
  res@gsnFrame          = False        
  res@gsnLeftString     = ""
  res@gsnRightString    = ""
  
  resc = res  ;����
  resv = res  ;
  rest = res  ;
  
  res@mpFillOn             = False        ; ����ɫ��ͼ
  res@mpCenterLonF         = 180          ; ��ͼ�����ľ��� 
  res@mpGeophysicalLineThicknessF = 0.5   ; ��ͼ�߽�Ĵ�ϸ
  res@pmTickMarkDisplayMode= "Always"     ; �����ϱ�ǩ�����Ӷȷ���
  res@mpGridAndLimbOn      = True         ; ���ƾ�γ����
             ; ��γ���߼��
             ;
              ; ��γ��������ȡΪ����Ϊ2�����ߡ���17�����͹�ѡ��
            ; ���ϸ
              
  res@cnFillOn             = True         ; ��ɫ��ֵ��
  res@cnLinesOn            = True         ; ���Ƶ�ֵ��
  res@cnLineColor          = "white"      ; ��ɫ
  res@cnLineThicknessF     = 0.3          ; ��ϸ
  res@cnLineLabelsOn       = False        ; �رձ�ǩ

  
  
    ; ��GMT_gray ������ɫ���������˵�2��ɫ��
    ; -1 Ϊ͸�� 
  res@cnInfoLabelOn         = False       ; �ر�ͼ���·��ĵ�ֵ����Ϣ��ǩ
  res@lbLabelBarOn          = False       ; �ر�labelbar
 
  resc@cnLevelSelectionMode  = "ExplicitLevels"                ; ָ��ÿ������Ƶĵ�ֵ��
  resc@cnLevels              = (/-0.75,-0.25,0.25,0.75,1.25/)  ;   
  resc@cnFillOn              = False     ; �رյ�ֵ����ɫ 
  resc@cnLineThicknessF      = 2.        ; ��ֵ�ߴ�ϸ  
  resc@gsnContourZeroLineThicknessF = 0. ; ����0ֵ�ߴ�ϸ��0�򲻻�
  resc@cnLineLabelsOn        = False     ; �رձ�ǩ
  resc@cnLineDashPattern     = 16        ; ����Ϊ16������
  resc@cnInfoLabelOn         = True      ; ��ͼ���·��ĵ�ֵ����Ϣ��ǩ
  resc@cnInfoLabelOrthogonalPosF = 0.05  ; �ƶ���ֵ����Ϣ��ǩ��λ��

  resv@vcPositionMode            = "ArrowTail"  ;��ͷβ����Ӧ�Ÿ���λ��
  resv@vcGlyphStyle              = "Fillarrow"  ;��������ѡ��Ϊ��LineArrow������WindBarb�� ����CurlyVector��
  resv@vcFillArrowEdgeThicknessF = 2         ; ��ͷ�߽��ϸ
  resv@vcFillArrowEdgeColor      = "white"   ; ����ɫ
  resv@vcFillArrowFillColor      = "black"  ; ��ͷ�ڲ������ɫ
  resv@vcFillArrowWidthF         = 0.1       ; ��ͷ����
  resv@vcFillArrowHeadXF         = 0.6       ; ��ο���¼��Fillarrow��ͷʾ��ͼ
  resv@vcFillArrowHeadYF         = 0.2       ;
  resv@vcFillArrowHeadInteriorXF = 0.25      ; 
           
  resv@vcMinDistanceF            = 0.03    ; ��ͷ֮�����С���루�ڵ�λƽ���У�
  resv@vcMinMagnitudeF           = 1.0     ; Ҫ���Ƽ�ͷ����ʾ����С��ֵ����С�ڸ���ֵ�򲻻���

  resv@vcFillArrowMinFracWidthF =1.0 
  resv@vcFillArrowHeadMinFracXF =1.0  
  resv@vcFillArrowHeadMinFracYF =1.0 
  
    ;****�趨�ο���ͷ****
    resv@vcRefAnnoOn               = True  
    resv@vcRefMagnitudeF           = refmag  ;��׼���ȼ�ͷ����ʾ�Ĵ�С
    resv@vcRefLengthF              = 0.045   ;��׼���ȼ�ͷ�ڵ�λƽ���еĴ�С
    resv@vcRefAnnoBackgroundColor  = "white" ;������ɫ     
    resv@vcRefAnnoPerimOn          = False   ;�رձ߿�    
                                        
    resv@vcRefAnnoFontHeightF      = 0.015   ;�ο���ͷ��ǩ�����С      
    
    resv@vcRefAnnoString1On     = False   ;�趨�ο���ͷ�ϡ��µ��ַ�        
    resv@vcRefAnnoString2On     = True    ; ������趨���·����ַ�
    resv@vcRefAnnoString2       = refmag+" m/s"  
           
    resv@vcRefAnnoSide            = "Top" ; �ο���ͷ����ͼ���Ϸ�
    resv@vcRefAnnoOrthogonalPosF  = -0.12 ; ������λ��
    resv@vcRefAnnoParallelPosF    = 0.95 
    

  res@gsnCenterString            = "sst" ;��ͼ�������� 
  res@gsnCenterStringFontHeightF = 0.03  ; ��������Ĵ�С�����ں���û���޸ĸ�ֵ����ÿ��ͼ��������������Ǵ˴�С
    ; ֻ�е�ͼ���е�ͼ��map��  
        ; ���õĻ�ͼ�������ɴ���map��
  plot(0) = ColorNegDashZeroPosContour(plot(0),"blue","white","red") ; ��ֵ����ɫ���߱�ʾ��0���ð�ɫʵ�ߣ���ֵ��ɫʵ��
       ; ����ͼ��ͼ�����������ͼ��

  ; ���ƶ���μ������Ա���nino 3.4�� 
  plres                  = True
  plres@gsLineColor      = "black"
  plres@gsLineThicknessF = 1.0
  
  gres                   = True
  gres@gsFillColor       = "yellow"
  gres@gsFillOpacityF    = 0.5
  gres@gsLineColor       = "black"
   
  latx = (/-5,    5,  5, -5, -5/)    ; nino3.4��������λ��
  lonx = (/190, 190,240, 240, 190/)  ;
  dum1 = gsn_add_polyline(wks, base(0),lonx,latx,plres)   
  dum2 = gsn_add_polygon(wks,base(0),lonx,latx,gres)
  
  res@gsnCenterString = "h300&V850"  
  resc@cnLevelSelectionMode  = "AutomaticLevels" 
  resc@cnLevelSpacingF = 15.
  base(1) = gsn_csm_contour_map(wks,confi_h300,res)  
  plot(1) = gsn_csm_contour(wks,h300_comp,resc) 
  plot(1) = ColorNegDashZeroPosContour(plot(1),"blue","white","red")
  overlay(base(1),plot(1))
  
  plotv   = gsn_csm_vector(wks,u850_comp,v850_comp,resv) 
  overlay(base(1),plotv)  ; Ҳ����gsn_csm_vector_map(wks,h300_comp,u850,v850,res_new)

  res@gsnCenterString       = "air2m"  
  resc@cnLevelSelectionMode = "ManualLevels" 
  resc@cnMaxLevelValF       = 2
  resc@cnMinLevelValF       = -2 
  resc@cnLevelSpacingF      = 0.5    
  base(2) = gsn_csm_contour_map(wks,confi_air2m,res)  
  plot(2) = gsn_csm_contour(wks,air2m_comp,resc) 
  plot(2) = ColorNegDashZeroPosContour(plot(2),"blue","black","red")
  overlay(base(2),plot(2))  
  
  resP = True                        ; ����panelͼ
  resP@txString       = "El nino"    ; ����������
  resP@txFontHeightF  = 0.03         ; �޸����С  

 ; resP@gsnPanelFigureStrings= (/"a)","b)","c)"/)  ;������ͼ�ı��
  resP@gsnPanelFigureStringsFontHeightF = 0.015   ;����Ĵ�С 
  resP@amJust = "TopLeft"                         ;�ڷŵ�λ�ã�Ĭ���ǡ�BottomRight��
  
          ; ָ��ÿ�л��Ƶ���ͼ�ĸ���
          ; ��1�л���1������2�л���2��
end