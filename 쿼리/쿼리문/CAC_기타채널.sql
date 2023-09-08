

SELECT order_date, store, brand, nick,
			
			COUNT(DISTINCT KEY) AS cust_cnt,
			
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '신규' THEN key
				END) AS new_cust_cnt,
				
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '재구매' THEN key
				END) AS re_cust_cnt,
			
			SUM(prd_amount_mod) AS price,
			
			SUM(CASE 
					WHEN all_cust_type = '신규' THEN prd_amount_mod
					ELSE 0
				END) new_price,
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN prd_amount_mod
					ELSE 0
				END) AS re_price
				
FROM "order_batch"
WHERE phytoway = 'y' AND store NOT IN ('스마트스토어', '스마트스토어_풀필먼트', '쿠팡', '쿠팡2', '쿠팡_로켓배송', '쿠팡_제트배송', '자사몰')
AND order_date between '2023-09-01' AND '2023-09-07'
GROUP BY order_date, store, brand, nick
Order BY order_date DESC, store