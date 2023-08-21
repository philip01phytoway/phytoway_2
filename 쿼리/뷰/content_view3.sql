
  WITH cost_mkt AS (
         SELECT c2.yymmdd,
            c2.id,
            sum(c2.cost_per_day) AS cost1
           FROM ( SELECT y1.yymmdd,
                    y1.id,
                    c1.marketing_type,
                    c1.owned_keyword_type,
                    c1.agency,
                    c1.cost_per_day
                   FROM (( SELECT "YMD2".yymmdd,
                            "YMD2".yymm,
                            "YMD2".yyww,
                            "YMD2".yyww_int,
                            p1.id
                           FROM ("YMD2"
                             CROSS JOIN ( SELECT "Page".id
                                   FROM "Page") p1)) y1
                     LEFT JOIN ( SELECT t1.index,
                            t1.id,
                            t1.start_date,
                            t1.end_date,
                            t1.marketing_type,
                            t1.owned_keyword_type,
                            t1.cost,
                            t1.agency,
                            t1.pay_date,
                            t1.manager,
                            t1.reg_date,
                            t1.cost_term,
                            (t1.cost / t1.cost_term) AS cost_per_day
                           FROM ( SELECT cost_marketing.index,
                                    cost_marketing.id,
                                    cost_marketing.start_date,
                                    cost_marketing.end_date,
                                    cost_marketing.marketing_type,
                                    cost_marketing.owned_keyword_type,
                                    cost_marketing.cost,
                                    cost_marketing.agency,
                                    cost_marketing.pay_date,
                                    cost_marketing.manager,
                                    cost_marketing.reg_date,
                                    ((to_date((cost_marketing.end_date)::text, 'YYYY-MM-DD'::text) - to_date((cost_marketing.start_date)::text, 'YYYY-MM-DD'::text)) + 1) AS cost_term
                                   FROM cost_marketing) t1) c1 ON ((y1.id = c1.id)))
                  WHERE (((y1.yymmdd)::text >= (c1.start_date)::text) AND ((y1.yymmdd)::text <= (c1.end_date)::text))) c2
          GROUP BY c2.yymmdd, c2.id
        )
 SELECT y.yymm,
    y.yyww,
    y.yymmdd,
    p.channel,
    CASE 
    	WHEN pp.brand IS NULL THEN '파이토웨이'
    	ELSE pp.brand
    END AS brand,
    CASE 
    	WHEN pp.nick IS NULL THEN '파이토웨이'
    	ELSE pp.nick
	 END AS nick,
    p.page_type,
    p.id,
    p.keyword,
        CASE
            WHEN ((p.keyword)::text ~~ concat('%', pp.brand, '%')) THEN '자상호'::text
            ELSE '비자상호'::text
        END AS owned_keyword_type,
    cm.cost1,
    cp.cost2,
    pl2.pv,
    pl2.cc,
    pl2.cc2,
    n.inflow_cnt,
    n.order_cnt,
    n.order_price
   FROM ((((((( SELECT "YMD2".yymmdd,
            "YMD2".yymm,
            "YMD2".yyww,
            "YMD2".yyww_int,
            p_1.id
           FROM ("YMD2"
             CROSS JOIN ( SELECT "Page".id
                   FROM "Page") p_1)) y
     LEFT JOIN "Page" p ON ((y.id = p.id)))
     LEFT JOIN product pp ON ((p.product_id = pp.no)))
     LEFT JOIN ( SELECT cost_product.gift_date,
            cost_product.id,
            sum(cost_product.cost) AS cost2
           FROM cost_product
          GROUP BY cost_product.gift_date, cost_product.id) cp ON ((((y.yymmdd)::text = (cp.gift_date)::text) AND (y.id = cp.id))))
     LEFT JOIN cost_mkt cm ON ((((y.yymmdd)::text = (cm.yymmdd)::text) AND (y.id = cm.id))))
     LEFT JOIN ( SELECT to_char(pl."createdAt", 'YYYY-MM-DD'::text) AS ymd,
            p_1.id,
            sum(
                CASE
                    WHEN ((pl.action_type)::text = 'Page'::text) THEN 1
                    ELSE 0
                END) AS pv,
            sum(
                CASE
                    WHEN ((pl.action_type)::text = 'Click'::text) THEN 1
                    ELSE 0
                END) AS cc,
            sum(
                CASE
                    WHEN ((pl.action_type)::text = 'Click2'::text) THEN 1
                    ELSE 0
                END) AS cc2
           FROM ("Page" p_1
             LEFT JOIN ( SELECT min("Page_Log"."createdAt") AS "createdAt",
                    to_char("Page_Log"."createdAt", 'YYYY-MM-DD'::text) AS to_char,
                    "Page_Log".page_id,
                    "Page_Log".product_id,
                    "Page_Log".action_type,
                    "Page_Log".header_agent,
                    "Page_Log".header_referer
                   FROM "Page_Log"
                  GROUP BY (to_char("Page_Log"."createdAt", 'YYYY-MM-DD'::text)), "Page_Log".page_id, "Page_Log".product_id, "Page_Log".action_type, "Page_Log".header_agent, "Page_Log".header_referer) pl ON ((p_1.id = pl.page_id)))
          WHERE (to_char(pl."createdAt", 'YYYY-MM-DD'::text) IS NOT NULL)
          GROUP BY (to_char(pl."createdAt", 'YYYY-MM-DD'::text)), p_1.id) pl2 ON ((((y.yymmdd)::text = pl2.ymd) AND (y.id = pl2.id))))
     LEFT JOIN ( SELECT "Naver_Custom_Order".yymmdd,
            "Naver_Custom_Order".nt_medium,
            sum("Naver_Custom_Order".inflow_cnt) AS inflow_cnt,
            sum("Naver_Custom_Order".order_cnt) AS order_cnt,
            sum("Naver_Custom_Order".order_price) AS order_price
           FROM "Naver_Custom_Order"
          WHERE (("Naver_Custom_Order".nt_source)::text = ANY ((ARRAY['matrix'::character varying, 'contents'::character varying, 'youtube'::character varying])::text[]))
          GROUP BY "Naver_Custom_Order".yymmdd, "Naver_Custom_Order".nt_medium
          ORDER BY "Naver_Custom_Order".yymmdd) n ON ((((n.nt_medium)::text = ((y.id)::character varying(10))::text) AND ((n.yymmdd)::text = (y.yymmdd)::text))))
  WHERE ((cp.id IS NOT NULL) OR (cm.id IS NOT NULL) OR (pl2.id IS NOT NULL) OR (n.nt_medium IS NOT NULL));
  