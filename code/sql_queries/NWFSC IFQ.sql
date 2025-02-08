select * from IFQ.VMS_VESSEL_POS_NW_V where to_char(UTC_TIME, 'YYYY') = 2021;
select * from IFQ.VMS_VESSEL_POS_NW_V where DATA_LOAD_DATE >= to_date('9/1/2021', 'mm/dd/yyyy')
order by UTC_TIME;
select * from IFQ.VMS_VESSEL_POS_NW_V where UTC_TIME between to_date('1/1/2009', 'mm/dd/yyyy') and to_date('12/31/2023', 'mm/dd/yyyy') order by UTC_TIME