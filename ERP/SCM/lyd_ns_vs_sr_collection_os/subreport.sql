select
*
from (
WITH tab2
AS (
	SELECT a.site_code
		,a.tran_date
				 -- ,C.Item_Ser
   ,siteitem.Item_Ser

		,a.cust_code__bil AS cust_code__bil
		,a.cust_code AS cust_code
        ,D.Order_Type
        ,b.Item_Code
                ,nvl(FN_RGET_TAX_DET('S-INV', B.INVOICE_ID, cast(B.line_no AS CHAR(3)), 'CGST_TAX', 'A'), 0) as Gross_Sales
         ,0 as Discount
        ,0 as Off_Discount
		,0 AS sales_return

	FROM invoice a
		,invoice_trace b
		,item c

        ,Sorder D
,siteitem

	WHERE a.invoice_id = b.invoice_id
		AND c.item_code = b.item_code
and siteitem.site_code = A.site_code
and siteitem.item_code = C.Item_Code
        And D.Sale_Order = A.Sale_Order

		AND a.confirmed = 'Y'


		AND a.tran_date >= last_day(add_months(TO_DATE(sysdate), - 13)) + 1
		AND a.tran_date <= (add_months(TO_DATE(sysdate), - 12))
        and a.site_code like 'S%'
        and a.site_code not in ('S0001', 'S0003')

		AND NOT EXISTS (SELECT 1 FROM sreturn sr WHERE sr.invoice_id = a.invoice_id AND confirmed = 'Y' AND tran_date <= (add_months(TO_DATE(sysdate), - 12)) AND tran_type = 'IC')


	UNION ALL

	SELECT a.site_code
		,a.tran_date
		 -- ,C.Item_Ser
   ,siteitem.Item_Ser

		,a.cust_code__bill AS cust_code__bil
		,a.cust_code AS cust_code
        ,'SR' Order_Type
        ,b.Item_Code
		,0 AS gross_sales
        ,0 AS Discount
        ,0 AS Off_Discount
,case when nvl(FN_RGET_TAX_DET('S-RET', B.Tran_Id, cast(B.line_no AS CHAR(3)), 'CGST_TAX', 'A'), 0) > 0 then nvl(FN_RGET_TAX_DET('S-RET', B.Tran_Id, cast(B.line_no AS CHAR(3)), 'CGST_TAX', 'A'), 0)
        else ((B.Rate__Stduom * B.Quantity__StdUom) - (nvl((((NVL(B.QUANTITY, 0) * NVL(B.RATE__STDUOM, 0) * NVL(A.EXCH_RATE, 0)) * nvl(B.DISCOUNT, 0)) / 100), 0) + nvl(FN_RGET_TAX_DET('S-RET', B.Tran_Id, cast(B.line_no AS CHAR(3)), 'DISC_GST', 'T') * (- 1), 0)) )
        end  AS sales_return
	FROM sreturn a
		,sreturndet b
		,item c
,siteitem
	WHERE a.tran_id = b.tran_id
		AND c.item_code = b.item_code
and siteitem.site_code = A.site_code
and siteitem.item_code = C.Item_Code
		AND a.confirmed = 'Y'

		AND a.tran_date >= last_day(add_months(TO_DATE(sysdate), - 13)) + 1
		AND a.tran_date <= (add_months(TO_DATE(sysdate), - 12))

		AND tran_type <> 'IC'
		and a.site_code like 'S%'
        and a.site_code not in ('S0001', 'S0003')
    )
	,tab3
AS (
	SELECT tab2.site_code site
		,s.udf4 AS cfa_code
		,s.udf5 AS cfa_name
		,div.item_ser division_code
		,div.descr AS division
		,tab2.tran_date AS tran_date
		,s.state_code AS state_code
		,(CASE WHEN div.item_ser = 'TR01 ' THEN (tab2.gross_sales-tab2.Discount) ELSE 0 END) AS gross_sales_tr01
		,(CASE WHEN div.item_ser = 'TR01 ' THEN tab2.sales_return ELSE 0 END ) AS sales_return_tr01
        ,(Case when div.Item_Ser = 'TR01 ' THEN (Tab2.Gross_Sales-
            (tab2.sales_return)) else 0 end) as PRI_NET_SALES_TR01
		,(case
              when (div.item_ser = 'TR01 ' And 'DS' = Tab2.Order_Type and  exists (select 1 from pricelist p where price_list = 'TRDD' and p.item_code = tab2.Item_Code))
                then 0
            when (div.item_ser = 'TR01 ' And 'NE' <> Tab2.Order_Type )
                then nvl(Tab2.Discount,0)
            else 0
                    end) as DISCOUNT_1_TR01
        ,((Case when div.item_ser = 'TR01 ' then
                nvl(Tab2.Discount,0) + nvl(Off_Discount,0)
               else 0 end)) as COMPNY_DISC_TR01

		,(CASE WHEN div.item_ser = 'TR02 ' THEN (tab2.gross_sales-tab2.Discount) ELSE 0 END) AS gross_sales_tr02
		,(CASE WHEN div.item_ser = 'TR02 ' THEN tab2.sales_return ELSE 0 END ) AS sales_return_tr02
        ,(Case when div.Item_Ser = 'TR02 ' THEN (Tab2.Gross_Sales-
            (tab2.sales_return)) else 0 end) as PRI_NET_SALES_TR02
		,(case
              when (div.item_ser = 'TR02 ' And 'DS' = Tab2.Order_Type and  exists (select 1 from pricelist p where price_list = 'TRDD' and p.item_code = tab2.Item_Code))
                then 0
            when (div.item_ser = 'TR02 ' And 'NE' <> Tab2.Order_Type )
                then nvl(Tab2.Discount,0)
          else 0
                    end) as DISCOUNT_1_TR02
        ,((Case when div.item_ser = 'TR02 ' then
                    nvl(Tab2.Discount,0) + nvl(Off_Discount,0)
               else 0 end)) as COMPNY_DISC_TR02

		,(CASE WHEN div.item_ser = 'TR03 ' THEN (tab2.gross_sales-tab2.Discount) ELSE 0 END) AS gross_sales_tr03
		,(CASE WHEN div.item_ser = 'TR03 ' THEN tab2.sales_return ELSE 0 END ) AS sales_return_tr03
        ,(Case when div.Item_Ser = 'TR03 ' THEN (Tab2.Gross_Sales-
            (tab2.sales_return)) else 0 end) as PRI_NET_SALES_TR03
        ,(case
          when (div.item_ser = 'TR03 ' And 'DS' = Tab2.Order_Type and  exists (select 1 from pricelist p where price_list = 'TRDD' and p.item_code = tab2.Item_Code))
            then 0
        when (div.item_ser = 'TR03 ' And 'NE' <> Tab2.Order_Type )
            then nvl(Tab2.Discount,0)
        else 0
                end) as DISCOUNT_1_TR03
        ,((Case when div.item_ser = 'TR03 ' then
            nvl(Tab2.Discount,0) + nvl(Off_Discount,0)
           else 0 end)) as COMPNY_DISC_TR03

		,(CASE WHEN div.item_ser = 'TR04 ' THEN (tab2.gross_sales-tab2.Discount) ELSE 0 END) AS gross_sales_tr04
		,(CASE WHEN div.item_ser = 'TR04 ' THEN tab2.sales_return ELSE 0 END ) AS sales_return_tr04
        ,(Case when div.Item_Ser = 'TR04 ' THEN (Tab2.Gross_Sales-
            (tab2.sales_return)) else 0 end) as PRI_NET_SALES_TR04
		,(case
          when (div.item_ser = 'TR04 ' And 'DS' = Tab2.Order_Type and  exists (select 1 from pricelist p where price_list = 'TRDD' and p.item_code = tab2.Item_Code))
            then 0
        when (div.item_ser = 'TR04 ' And 'NE' <> Tab2.Order_Type )
            then nvl(Tab2.Discount,0)
        else 0
                end) as DISCOUNT_1_TR04
        ,((Case when div.item_ser = 'TR04 ' then
            nvl(Tab2.Discount,0) + nvl(Off_Discount,0)
           else 0 end)) as COMPNY_DISC_TR04

        ,(CASE WHEN div.item_ser = 'TR05 ' THEN (tab2.gross_sales-tab2.Discount) ELSE 0 END) AS gross_sales_tr05
		,(CASE WHEN div.item_ser = 'TR05 ' THEN tab2.sales_return ELSE 0 END ) AS sales_return_tr05
        ,(Case when div.Item_Ser = 'TR05 ' THEN (Tab2.Gross_Sales-
            (tab2.sales_return)) else 0 end) as PRI_NET_SALES_TR05
		,(case
          when (div.item_ser = 'TR05 ' And 'DS' = Tab2.Order_Type and  exists (select 1 from pricelist p where price_list = 'TRDD' and p.item_code = tab2.Item_Code))
            then 0
        when (div.item_ser = 'TR05 ' And 'NE' <> Tab2.Order_Type )
            then nvl(Tab2.Discount,0)
        else 0
                end) as DISCOUNT_1_TR05
        ,((Case when div.item_ser = 'TR05 ' then
                    nvl(Tab2.Discount,0) + nvl(Off_Discount,0)
                   else 0 end)) as COMPNY_DISC_TR05

        ,(CASE WHEN div.item_ser = 'TR06 ' THEN (tab2.gross_sales-tab2.Discount) ELSE 0 END) AS gross_sales_TR06
		,(CASE WHEN div.item_ser = 'TR06 ' THEN tab2.sales_return ELSE 0 END ) AS sales_return_TR06
        ,(Case when div.Item_Ser = 'TR06 ' THEN (Tab2.Gross_Sales-
            (tab2.sales_return)) else 0 end) as PRI_NET_SALES_TR06
		,(case
          when (div.item_ser = 'TR06 ' And 'DS' = Tab2.Order_Type and  exists (select 1 from pricelist p where price_list = 'TRDD' and p.item_code = tab2.Item_Code))
            then 0
        when (div.item_ser = 'TR06 ' And 'NE' <> Tab2.Order_Type )
            then nvl(Tab2.Discount,0)
        else 0
                end) as DISCOUNT_1_TR06
        ,((Case when div.item_ser = 'TR06 ' then
                    nvl(Tab2.Discount,0) + nvl(Off_Discount,0)
                   else 0 end)) as COMPNY_DISC_TR06

	FROM tab2
        ,site s
		,itemser div
		,customer stk

	WHERE s.site_code = tab2.site_code
		AND div.item_ser = tab2.item_ser
		AND stk.cust_code = tab2.cust_code__bil
		--AND STK.fax IS NULL
	)
SELECT state_code state_code
	,Round((gross_sales_tr01/100000),2) gross_sales_tr01
	,Round((sales_return_tr01/100000),2) sales_return_tr01
	,Round((PRI_NET_SALES_TR01/100000),2) PRI_NET_SALES_TR01
	,Round((gross_sales_tr02/100000),2) gross_sales_tr02
	,Round((sales_return_tr02/100000),2) sales_return_tr02
	,Round((PRI_NET_SALES_TR02/100000),2) PRI_NET_SALES_TR02
	,Round((gross_sales_tr03/100000),2) gross_sales_tr03
	,Round((sales_return_tr03/100000),2) sales_return_tr03
	,Round((PRI_NET_SALES_TR03/100000),2) PRI_NET_SALES_TR03
	,Round((gross_sales_tr04/100000),2) gross_sales_tr04
	,Round((sales_return_tr04/100000),2) sales_return_tr04
	,Round((PRI_NET_SALES_TR04/100000),2) PRI_NET_SALES_TR04
    ,Round((gross_sales_tr05/100000),2) gross_sales_tr05
	,Round((sales_return_tr05/100000),2) sales_return_tr05
	,Round((PRI_NET_SALES_TR05/100000),2) PRI_NET_SALES_TR05
    ,Round((gross_sales_tr06/100000),2) gross_sales_tr06
	,Round((sales_return_tr06/100000),2) sales_return_tr06
	,Round((PRI_NET_SALES_TR06/100000),2) PRI_NET_SALES_TR06
	,Round((chq_dep_val/100000),2) chq_dep_val
	,Round((tot_dep_val/100000),2) tot_dep_val
	,Round((tot_rcp_val/100000),2) tot_rcp_val
	,0 os_amt
FROM (
		SELECT TO_CHAR(add_months(TO_DATE(sysdate), - 12), 'ddth Mon-YY') state_code
		,SUM(gross_sales_tr01) AS gross_sales_tr01
		,SUM(sales_return_tr01) AS sales_return_tr01
		,SUM(PRI_NET_SALES_TR01) AS PRI_NET_SALES_TR01
		,SUM(gross_sales_tr02) AS gross_sales_tr02
		,SUM(sales_return_tr02) AS sales_return_tr02
		,SUM(PRI_NET_SALES_TR02) AS PRI_NET_SALES_TR02
		,SUM(gross_sales_tr03) AS gross_sales_tr03
		,SUM(sales_return_tr03) AS sales_return_tr03
		,SUM(PRI_NET_SALES_TR03) AS PRI_NET_SALES_TR03
		,SUM(gross_sales_tr04) AS gross_sales_tr04
		,SUM(sales_return_tr04) AS sales_return_tr04
		,SUM(PRI_NET_SALES_TR04) AS PRI_NET_SALES_TR04
        ,SUM(gross_sales_tr05) AS gross_sales_tr05
		,SUM(sales_return_tr05) AS sales_return_tr05
		,SUM(PRI_NET_SALES_TR05) AS PRI_NET_SALES_TR05
     ,SUM(gross_sales_tr06) AS gross_sales_tr06
		,SUM(sales_return_tr06) AS sales_return_tr06
		,SUM(PRI_NET_SALES_TR06) AS PRI_NET_SALES_TR06
		,SUM(chq_dep_val) AS chq_dep_val
		,SUM(tot_dep_val) AS tot_dep_val
		,SUM(tot_rcp_val) AS tot_rcp_val
		,0 AS os_amt
	FROM (
		SELECT gross_sales_tr01 AS gross_sales_tr01
			,sales_return_tr01 AS sales_return_tr01
 ,(PRI_NET_SALES_TR01 - (COMPNY_DISC_TR01)) as PRI_NET_SALES_TR01
			,gross_sales_tr02 AS gross_sales_tr02
			,sales_return_tr02 AS sales_return_tr02
 ,(PRI_NET_SALES_TR02 - (COMPNY_DISC_TR02)) as PRI_NET_SALES_TR02
			,gross_sales_tr03 AS gross_sales_tr03
			,sales_return_tr03 AS sales_return_tr03
 ,(PRI_NET_SALES_TR03 - (COMPNY_DISC_TR03)) as PRI_NET_SALES_TR03
			,gross_sales_tr04 AS gross_sales_tr04
			,sales_return_tr04 AS sales_return_tr04
,(PRI_NET_SALES_TR04 - (COMPNY_DISC_TR04)) as PRI_NET_SALES_TR04
            ,gross_sales_tr05 AS gross_sales_tr05
			,sales_return_tr05 AS sales_return_tr05
,(PRI_NET_SALES_TR05 - (COMPNY_DISC_TR05)) as PRI_NET_SALES_TR05
            ,gross_sales_tr06 AS gross_sales_tr06
			,sales_return_tr06 AS sales_return_tr06
,(PRI_NET_SALES_TR06 - (COMPNY_DISC_TR06)) as PRI_NET_SALES_TR06
			,0 AS chq_dep_val
			,0 AS tot_dep_val
			,0 As tot_rcp_val
			,0 AS os_amt
		FROM tab3
		WHERE tran_date >= last_day(add_months(TO_DATE(sysdate), - 13)) + 1
			AND tran_date <= (add_months(TO_DATE(sysdate), - 12))

		UNION ALL

		SELECT 0 AS gross_sales_tr01
			,0 AS sales_return_tr01
            ,0 as PRI_NET_SALES_TR01
			,0 AS gross_sales_tr02
			,0 AS sales_return_tr02
            ,0 as PRI_NET_SALES_TR02
			,0 AS gross_sales_tr03
			,0 AS sales_return_tr03
            ,0 as PRI_NET_SALES_TR03
			,0 AS gross_sales_tr04
			,0 AS sales_return_tr04
            ,0 as PRI_NET_SALES_TR04
            ,0 AS gross_sales_tr05
			,0 AS sales_return_tr05
            ,0 as PRI_NET_SALES_TR05
           ,0 AS gross_sales_tr06
			,0 AS sales_return_tr06
            ,0 as PRI_NET_SALES_TR06
			,(CASE WHEN (pr.ref_date = (add_months(TO_DATE(sysdate), - 13)) AND NOT EXISTS (SELECT 1 FROM receipt WHERE tran_id = tran_ref_rcp AND confirmed = 'Y')) THEN pr.amount ELSE 0 END) AS chq_dep_val
			,pr.amount AS tot_dep_val
			,0 As tot_rcp_val
			,0 AS os_amt
		FROM pdc_received pr
		WHERE pr.STATUS IN ('P')
			AND (
				pr.ref_date >= last_day(add_months(TO_DATE(sysdate), - 13)) + 1
				AND pr.ref_date <= (add_months(TO_DATE(sysdate), - 12))
				)
			--And Not Exists (Select 1 from receipt where tran_id = tran_ref_rcp And Confirmed = 'Y')
			AND pr.amount <> 0
			and pr.site_code like 'S%'
            and pr.site_code not in ('S0001', 'S0003')
		UNION ALL

		SELECT 0 AS gross_sales_tr01
			,0 AS sales_return_tr01
			,0 as PRI_NET_SALES_TR01
			,0 AS gross_sales_tr02
			,0 AS sales_return_tr02
			,0 as PRI_NET_SALES_TR02
			,0 AS gross_sales_tr03
			,0 AS sales_return_tr03
			,0 as PRI_NET_SALES_TR03
			,0 AS gross_sales_tr04
			,0 AS sales_return_tr04
			,0 as PRI_NET_SALES_TR04
            ,0 AS gross_sales_tr05
			,0 AS sales_return_tr05
			,0 as PRI_NET_SALES_TR05
            ,0 AS gross_sales_tr06
			,0 AS sales_return_tr06
			,0 as PRI_NET_SALES_TR06
			,0 AS chq_dep_val
			,0 AS tot_dep_val
			,Net_Amt__BC AS tot_rcp_val
			,0 AS os_amt
		FROM Receipt r
		WHERE Confirmed = 'Y'
		And Tran_Date >= last_day(add_months(TO_DATE(sysdate), - 13)) + 1
		And Tran_Date <= (add_months(TO_DATE(sysdate), - 12))
		And Not Exists (Select 1 from rcpdishnr rd Where Confirmed = 'Y' And rd.Receipt_No = r.Tran_Id)
and r.site_code like 'S%'
        and r.site_code not in ('S0001', 'S0003')
		) prev_mon
	GROUP BY TO_CHAR((add_months(TO_DATE(sysdate), - 12)), 'ddth Mon-YY')
	)
) tab11