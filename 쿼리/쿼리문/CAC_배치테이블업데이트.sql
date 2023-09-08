-- 배치 테이블 업데이트 쿼리문

-- order_batch : 오전 10시 업데이트 이후 업데이트 자율적으로 진행
-- ad_batch : 오전 10시 업데이트 이후 업데이트 자율적으로 진행
-- content_batch : 업데이트 자율적으로 진행

-- 데이터 삭제 -> 데이터 삽입 -> 중복삽입 검증 순으로 진행


---------------
-- order_batch
---------------

-- 데이터 삭제
TRUNCATE TABLE "order_batch"

-- 데이터 삽입
INSERT INTO "order_batch" (yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type, inflow_path, dead_date, onnuri_code, onnuri_name, onnuri_type, trans_date, prev_dead_date, next_dead_date, prev_order_date, next_order_date)
SELECT yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type, inflow_path, dead_date, onnuri_code, onnuri_name, onnuri_type, trans_date, prev_dead_date, next_dead_date, prev_order_date, next_order_date FROM "order5"




---------------
-- ad_batch
---------------

-- 데이터 삭제
TRUNCATE TABLE "ad_batch"

-- 데이터 삽입
INSERT INTO "ad_batch" (yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, order_cnt_14, order_price_14, option_id, cost_payback)
SELECT yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, order_cnt_14, order_price_14, option_id, cost_payback FROM "ad_view7"

---------------
-- content_batch
---------------

-- 데이터 삭제
TRUNCATE TABLE "content_batch"

-- 데이터 삽입
INSERT INTO "content_batch" (yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price)
SELECT yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price FROM "content_view3"


-- 중복삽입 검증

-- order_batch 40만행
select COUNT(*) from "order_batch"

-- ad_batch 290만행
select COUNT(*) from "ad_batch"

-- content_batch 20만행
select COUNT(*) from "content_batch"




