Create or alter procedure Silver.load_silver as 
Begin
	declare @start_insert datetime, @end_insert datetime
	BEGIN TRY

		
		print '=================================================='
		print '		 Inserting Data From Bronze Layer
			     to Silver Layer'
		print '=================================================='


		set @start_insert = getdate()
		Print '>> Truncating Table: Silver.crm_cust_info'
		Truncate Table Silver.crm_cust_info
		Print '>> Inserting Data Into Table: Silver.crm_cust_info'
		INSERT INTO Silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		select
			cst_id,
			cst_key,
			trim(cst_firstname)as cst_firstname,
			trim(cst_lastname) as cst_lastname,
			case when upper(trim(coalesce(cst_marital_status, ''))) = 'S' then 'Single'
				 when upper(trim(coalesce(cst_marital_status, ''))) = 'M' then 'Married' 
				 else 'N/A'
			end cst_marital_status,
			case when upper(trim(cst_gndr)) = 'M' then 'Male' 
				 when upper(trim(cst_gndr)) = 'F' then 'Female' 
				 else 'N/A' 
			end cst_gndr,
			cst_create_date
		from(
			select 
				*,
				row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
			from Bronze.crm_cust_info
			where cst_id is not null
		)t where flag_last = 1 
		set @end_insert = getdate()
		Print'Load Duration:' + cast(datediff(second, @end_insert, @start_insert) as nvarchar)

		set @start_insert = getdate()
		print '----------------------------------------------'
		Print '>> Truncating Table: silver.crm_prd_info'
		Truncate Table silver.crm_prd_info
		Print '>> Inserting Data Into Table: silver.crm_prd_info'
		insert into silver.crm_prd_info(
			prd_id,	
			cat_id,
			prd_key,
			prd_nm,		
			prd_cost,
			prd_line,		
			prd_start_dt,	
			prd_end_dt
		)

		select
			prd_id,
			replace(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
			replace(SUBSTRING(prd_key, 7, LEN(prd_key)), '-', '_') as prd_key,
			prd_nm,
			coalesce(prd_cost, 0) as prd_cost,
			case upper(trim(prd_line))
				 when 'R' then 'Road'
				 when 'M' then 'Mountain'
				 when 'T' then 'Touring'
				 when 'S' then 'Other Sales' 
				 else 'n/a'
			end as prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) - 1 as date) as prd_end_dt
		from Bronze.crm_prd_info
		set @end_insert = getdate()
		Print'Load Duration:' + cast(datediff(second, @end_insert, @start_insert) as nvarchar)

		set @start_insert = getdate()
		print '----------------------------------------------'
		Print '>> Truncating Table: crm_sales_details'
		Truncate Table Silver.crm_sales_details
		Print '>> Inserting Data Into Table: crm_sales_details'
		insert into silver.crm_sales_details(
			sls_ord_num,		
			sls_prd_key,		
			sls_cust_id,		
			sls_order_dt,	
			sls_ship_dt,		
			sls_due_dt,		
			sls_sales,		
			sls_quantity,	
			sls_price	

		)

		select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case 
				when sls_order_dt <= 0 or len(sls_order_dt) != 8 then null
				else cast(cast(sls_order_dt as nvarchar) as date)
			end as sls_order_dt,
			case 
				when sls_ship_dt <= 0 or len(sls_ship_dt) != 8 then null
				else cast(cast(sls_ship_dt as nvarchar) as date)
			end as sls_ship_dt,
			case 
				when sls_due_dt <= 0 or len(sls_due_dt) != 8 then null
				else cast(cast(sls_due_dt as nvarchar) as date)
			end as sls_due_dt,
			case 
				when sls_sales is null or sls_sales <=0 or sls_sales != abs(sls_price) * sls_quantity then abs(sls_price) * sls_quantity
				else sls_sales
			end as sls_sales,
			sls_quantity,
			case 
				when sls_price is null or sls_price <= 0 then sls_sales / nullif(sls_quantity, 0)
				else sls_price
			end as sls_price
		from Bronze.crm_sales_details
		set @end_insert = getdate()
		Print'Load Duration:' + cast(datediff(second, @end_insert, @start_insert) as nvarchar)

		set @start_insert = getdate()
		print '----------------------------------------------'
		Print '>> Truncating Table: Silver.erp_CUST_AZ12'
		Truncate Table Silver.erp_CUST_AZ12
		Print '>> Inserting Data Into Table: Silver.erp_CUST_AZ12'
		insert into Silver.erp_CUST_AZ12 (CID, BDATE, GEN)

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

		set @start_insert = getdate()
		print '----------------------------------------------'
		Print '>> Truncating Table: silver.erp_LOC_A101'
		Truncate Table silver.erp_LOC_A101
		Print '>> Inserting Data Into Table: silver.erp_LOC_A101'
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
		set @end_insert = getdate()
		Print'Load Duration:' + cast(datediff(second, @end_insert, @start_insert) as nvarchar)

		set @start_insert = getdate()
		print '----------------------------------------------'
		Print '>> Truncating Table: Silver.erp_PX_CAT_G1V2'
		Truncate Table Silver.erp_PX_CAT_G1V2
		Print '>> Inserting Data Into Table: Silver.erp_PX_CAT_G1V2'
		insert into Silver.erp_PX_CAT_G1V2 (id, cat, SUBCAT, MAINTENANCE)

		select 
			id,
			cat,
			SUBCAT,
			MAINTENANCE
		from Bronze.erp_PX_CAT_G1V2
		set @end_insert = getdate()
		Print'Load Duration:' + cast(datediff(second, @end_insert, @start_insert) as nvarchar)

	END TRY
	BEGIN CATCH

		print '=============================='
		print 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		print 'Error Message' + error_message();
		print 'Error Message' + cast(Error_Number() as NVARCHAR);
		print 'Error Message' + cast(Error_state() as NVARCHAR);
		print '=============================='

	END CATCH
End
