SELECT
            
	-- ,item_ser
   ' ' as TRAN_ID
   ,' ' as line_no
   ,' ' as dist_ord
   ,' ' as LINE_NO_DIST_ORDER
   	-- ,null as TRAN_ID__DEMAND
      ,item_code
	 ,QTY_ORDER as QUANTITY
      ,UNIT
      ,'NIL' as TAX_CLASS
	,tax_chap
   	,'STIWC01' as TAX_ENV
      ,loc_code
	-- ,QTY_CONFIRM
   	-- ,null as QTY_RECEIVED
   	-- ,null as QTY_SHIPPED
     ,LOT_NO
    ,LOT_SL
	--,due_date
   	
         
   --	,NULL AS LINE_NO__SORD
    	,0 AS RATE
        ,0 as AMOUNT
    	
        /* NULL AS SALE_ORDER
    	,NULL AS QTY_RETURN
    	,NULL AS QTY_ALLOC
 	,NULL AS DATE_ALLOC
    	,NULL AS RATE_CLG
   	,0 AS DISCOUNT
    	,NULL AS REMARKS
    	,0 AS TOT_AMT
   	,0 AS TAX_AMT
    	,0 AS NET_AMT
    	,0 AS OVER_SHIP_PERC
    	,NULL AS RATE__CLG
   	,UNIT AS UNIT__ALT
    	,NULL AS CONV__QTY__ALT
    	,QTY_ORDER AS QTY_ORDER__ALT
    	,due_date AS SHIP_DATE
   	,NULL AS PACK_INSTR
    	,NULL AS CUSTOM_DESCR
    	,'IT' AS REAS_CODE
    	,NULL AS WORK_ORDER
    	,NULL AS CUST_SPEC__NO
    	,NULL AS QUANTITY__FC
    	,NULL AS PRD_CODE__RFC
    	,NULL AS LINE_NO__PORD
    	,NULL AS EXP_DLV_DATE
    	,NULL AS CUST_ITEM__REF
    	,'O' AS  STATUS
          ,NULL AS PLAN_PROD_DATE */
FROM (
	SELECT dist_ord
		,row_number() over(partition by dist_ord order by
		 dist_ord,loc_code, item_code)line_no
		,loc_code
		--,item_ser
		,item_code
		,QTY_ORDER
		,QTY_CONFIRM
		,due_date
		,tax_chap
        ,UNIT
        ,LOT_NO
        ,LOT_SL
	FROM (
		SELECT
				(case
					when row_num between 001 and 020 then '1'
					when row_num between 021 and 040 then '2'
					when row_num between 041 and 060 then '3'
					when row_num between 061 and 080 then '4'
					when row_num between 081 and 100 then '5'
					when row_num between 101 and 120 then '6'
					when row_num between 121 and 140 then '7'
					when row_num between 141 and 160 then '8'
					when row_num between 161 and 180 then '9'
					when row_num between 181 and 200 then '10'
					when row_num between 201 and 220 then '11'
					when row_num between 221 and 240 then '12'
					when row_num between 241 and 260 then '13'
					when row_num between 261 and 280 then '14'
					when row_num between 281 and 300 then '15'
					when row_num between 301 and 320 then '16'
					when row_num between 321 and 340 then '17'
					when row_num between 341 and 360 then '18'
					when row_num between 361 and 380 then '19'
					when row_num between 381 and 400 then '20'
					when row_num between 401 and 420 then '21'
					when row_num between 421 and 440 then '22'
					when row_num between 441 and 460 then '23'
					when row_num between 461 and 480 then '24'
					when row_num between 481 and 500 then '25'
				END
				) dist_ord
			,loc_code
			--,item_ser
			,item_code
			,QTY_ORDER
			,QTY_CONFIRM
			,due_date
			,tax_chap
            ,UNIT
            ,LOT_NO
            ,LOT_SL
		FROM (
			SELECT
				row_number() over(order by loc_code,item_code) row_num
				,loc_code
				--,item_ser
				,item_code
				,QTY_ORDER
				,QTY_CONFIRM
				,due_date
				,tax_chap
                ,UNIT
                ,LOT_NO
                ,LOT_SL
			FROM (
				SELECT --  My query
					--NULL as DIST_ORDER
					--, null as LINE_NO
					--, null as TRAN_ID__DEMAND
					srd.loc_code
					--,srd.item_ser
					,srd.item_code
					,sum(srd.quantity) AS QTY_ORDER
					,sum(srd.quantity) AS QTY_CONFIRM
					,to_char(sysdate, 'dd/mm/yy') AS due_date
					,it.tax_chap
                    ,it.unit
					,SRD.LOT_NO
                    ,SRD.LOT_SL
				--, null as QTY_RECEIVED
				FROM sreturn sr
				JOIN sreturndet srd ON sr.tran_id = srd.tran_id
				JOIN item it ON it.item_code = srd.item_code
				WHERE CONFIRMED = 'Y'
					AND sr.tran_type <> 'IC'
					and srd.loc_code in( 'EXPR' , 'DMGD')

					AND sr.site_code='S0011'
					AND sr.tran_date >= '01-JUL-24'
					AND sr.tran_date <= '30-JUL-24'
					--and srd.loc_code = 'DMGD'
 --( 'DMGD' )       
					AND srd.item_ser >= '00'
					AND srd.item_ser <= 'ZZ'
				--	AND srd.item_ser >= 'TR01'
				--	AND srd.item_ser <= 'TR04'

	GROUP BY   srd.loc_code
					--,srd.item_ser
					,srd.item_code
					,it.tax_chap
                    ,it.unit
                    ,SRD.LOT_NO
                    ,SRD.LOT_SL
				) tab0
			) tab1
		) tab2
	) tab3
ORDER BY loc_code
	--,item_ser
	,item_code