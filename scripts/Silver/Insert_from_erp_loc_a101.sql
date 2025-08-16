insert into silver.erp_LOC_A101 (CID, CNTRY)

select
concat(substring(CIN, 1, 2), substring(CIN, 4, len(CIN))) as CID,
case 
	 when trim(cntry) = 'DE' then 'Germany'
	 when trim(CNTRY) in ('USA', 'US') then 'United States'

	 when trim(CNTRY) like '' or CNTRY is null then 'N/A'
	 else trim(CNTRY)
end as CNTRY
from bronze.erp_loc_a101
