insert into Silver.erp_CUST_AZ12
(
	CID,
	BDATE,
	GEN
)
select
case when CID like 'NAS%' then SUBSTRING(CID, 4, len(CID))
	 else CID 
end as CID,
case when BDATE > GETDATE() then NUll
	 else BDATE
end as BDATE,
case when upper(trim(GEN)) = 'M' then 'Male'
	 when upper(trim(GEN)) = 'F' then 'Female'
	 when GEN like '% %' or Gen is null then 'N/A'
	 else GEN 
end as GEN
from Bronze.erp_CUST_AZ12 
