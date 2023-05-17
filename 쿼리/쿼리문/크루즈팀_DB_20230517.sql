-- 크루즈팀_DB_2023-05-17

-- 개선사항 
-- 기존 cruise_cust_view는 일자를 조건으로 줄 수 없었음.
-- 따라서 일자를 조건으로 줄 수 있게끔 cruise_cust_view2 작성



-- cruise_cust_view2 쿼리문
-- WHERE 절에 일자 수정하여 사용

SELECT brand, MAX(order_date) AS order_date, count(distinct KEY) AS cnt 
FROM "cruise_cust_view2"
--WHERE order_date <= '2023-01-10' 
GROUP BY brand
Order BY cnt desc
