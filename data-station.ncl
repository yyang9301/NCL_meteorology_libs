begin 
  nstat = 160 ; 160վ
  year_s = 1951 
  year_e = 2011 
  nyear  = year_e - year_s + 1
  
  ; (1) ����6/7/8�����µĽ�ˮ
  path6 = "./data/r1606.TXT"
  path7 = "./data/r1607.TXT"  
  path8 = "./data/r1608.TXT" 

  
  ; �趨meta data
  m6!0 = "year"
  m6!1 = "stations"
  m6&year = ispan(year_s,year_e,1)
  m6&stations = ispan(1,nstat,1)
  
  m7 = m6  ; �����µı���
  m8 = m6  


  
  ;(2) ������1979����2008�������JJAƽ��
  mm = m6({1979:2008},:) ; �����µı���
  mm = m6({1979:2008},:) + m7({1979:2008},:) + m8({1979:2008},:)
  
  ;(3) ���Ϊ�޸�ʽ�������ļ�
  
  ;(4) ���ΪASCII�ļ�

  
end 
 
 