-- 고객수 찾는 쿼리

-- phytoway = 'y' : 기타 제품 제외 (product 테이블에서 조회)
-- order_id <> '' : b2b 제외

-- key 컬럼을 가지고 고객 정보를 찾는다면

-- 1. disticnt 사용 (중복 제거)
SELECT DISTINCT order_tel, recv_address
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' AND  order_date >= '2023-01-30'


-- 2. group by 사용
SELECT "key", max(order_tel), max(recv_address)
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' AND  order_date >= '2023-01-30'
GROUP BY key
 
-- 전화번호 컬럼을 가지고 고객 정보를 찾는다면
SELECT order_tel, MAX(recv_address)
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' AND  order_date >= '2023-01-30'
GROUP BY order_tel



-- 전화번호 중복 제거
-- 직원 제외
-- 010으로 시작하는 번호만
-- 0000 제외, * 제외
SELECT order_tel, MAX(order_name), COUNT(distinct recv_address) AS cnt
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' AND  order_date >= '2023-01-30'
AND order_tel NOT IN (
'01020301750', '01089943170', '01087648973', '01071835318', '01095805107', '01047053596', '01041412239', '01045782253', '01047151436', '01054939894', '01036183938', '01047459420', '01030623570', '01088190204', '01043378902', '01037639009', '01029785948', '01024632393', '01045795150', '01027777868', '01043336357', '01029793426', '01092243296', '01089027503', '01052658787', '01027032835', '01089794886', '01056763848', '01093346009', '01077311221', '01046431990', '01045699054', '0.48125', '01020301750', '01089943170', '01087648973', '01071835318', '01095805107', '01047053596', '01041412239', '01045782253', '01047151436', '01054939894', '01036183938', '01047459420', '01030623570', '01088190204', '01043378902', '01037639009', '01029785948', '01024632393', '01045795150', '01027777868', '01043336357', '01029793426', '01092243296', '01089027503', '01052658787', '01027032835', '01089794886', '01056763848', '01093346009', '01077311221', '01046431990', '01045699054')
AND order_tel LIKE '010%' AND order_tel NOT LIKE '%0000%' AND order_tel NOT LIKE '%*%'
group by order_tel
Order BY cnt desc





-- 






