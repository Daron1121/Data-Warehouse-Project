-- Check for Nulls or Duplicates in Primary Key
-- Expectation: no result

select 
cst_id,
count(*)
from Silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null

-- Check for unwanted Spaces
-- Expectation: No Result
Select cst_key
from Silver.crm_cust_info
where cst_key != trim(cst_key)

-- Data Standardization & Consistency
select distinct
cst_gndr
from Silver.crm_cust_info

select * from Silver.crm_cust_info


-- Check for unwanted Spaces
-- Expectation: No Result
Select prd_nm
from Bronze.crm_prd_info
where prd_nm != trim(prd_nm)

-- crm_prd_info

--Check for Nulls or negative numbers
-- Expectation: No Result
select
prd_cost
from Silver.crm_prd_info
where prd_cost is null or prd_cost < 0

-- Data Standardization & Consistency
select distinct
prd_line
from Silver.crm_prd_info

-- check for invalid date orders
select *
from Silver.crm_prd_info
where prd_end_dt < prd_start_dt

select * from Silver.crm_prd_info

-- crm_sales_details

-- Check for Nulls or Duplicates in Primary Key
-- Expectation: no result

select
nullif(sls_due_dt, 0)
from Bronze.crm_sales_details
where 
sls_due_dt <= 0
or len(sls_due_dt) != 8
or sls_due_dt > 20600101
or sls_due_dt < 19000101

--Check Data Consistency: Between Sales, Quantity and Price
-- >> Values must not be Null, zero or negative
-- >> Sales = Price * Quantity

select distinct
	sls_sales as old_sls_sales,
	sls_quantity,
	sls_price
from Silver.crm_sales_details
where sls_price * sls_quantity != sls_sales 
or sls_price is null 
or sls_quantity is null
or sls_sales is null
or sls_quantity <= 0
or sls_price <= 0
or sls_sales <= 0
