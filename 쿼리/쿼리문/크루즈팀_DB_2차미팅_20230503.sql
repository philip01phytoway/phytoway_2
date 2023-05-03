-------------------------------

크루즈팀 2차 미팅 2023-05-03

-------------------------------


------ db 프로그램 및 계정 정보 ------

Hedisql 다운로드 주소 : https://www.heidisql.com/download.php

ip 주소 : 115.68.228.168
아이디 : cruise
비밀번호 : Zmfnwm84#
포트 : 5432
DB명 : phytogether


SQL의 기본 명령문 4가지

1. SELECT : 조회
2. UPDATE : 수정
3. INSERT : 입력
4. DELETE : 삭제

cruise 계정은 SELECT만 할 수 있도록 권한 설정 되었음.

쿼리 실행하는 단축키 : Ctrl + F9 

SELECT문 기본 구조 
SELECT 컬럼 FROM 테이블 WHERE 조건 GROUP BY 컬럼 ORDER BY 컬럼 LIMIT 개수

기타 연산자
LIKE, IN, *, NOT IN, NOT LIKE

주석
-- 사람끼리 커뮤니케이션 용도



---- 샘플 쿼리 ---- 


-- 1. 기본 주문 데이터 조회하기
SELECT * --yymm, prd_amount_mod -- *의 의미 : 모든 컬럼을 조회할래
FROM "order_batch" -- "order_batch" 테이블에서
LIMIT 10000 -- 10000개만 보여줘.


-- 2. 써큐시안 첫구매 후 판토모나 교차구매 고객 지표
SELECT * FROM "cruise_cust_view"


-- 3. 써큐시안 첫구매 후 판토모나 교차구매 고객 db
SELECT *
FROM "order_batch"
WHERE order_id <> '' AND phytoway = 'y' 
AND KEY IN (
		
	SELECT key
	FROM "order_batch" 
	WHERE all_cust_type = '신규' AND nick = '써큐시안'
)
AND brand = '판토모나'
Order BY KEY, order_date_time


-- 4. 써큐시안 신규고객 db
-- 신규주문건만 포함
-- 써큐시안으로 파이토웨이 제품 첫구매
SELECT * 
FROM "order_batch"
WHERE all_cust_type = '신규' AND nick = '써큐시안'
Order BY order_date_time desc


-- 5. 써큐시안만 구매하고 있는 고객의 로우데이터
SELECT *
FROM "order_batch"
WHERE KEY IN (
		SELECT key
		FROM "order_batch"
		GROUP BY key
		HAVING COUNT(DISTINCT CASE WHEN brand <> '써큐시안' THEN brand END) = 0
		AND COUNT(DISTINCT brand) = 1
	)
Order BY key
	

-- 6. 문자발송
select * from sms_send_log where reserved_date between '2023-04-26' and '2023-05-02'

-- 추가 전달할 쿼리문

1. 활동구간, 만료구간(이탈고객)

2. ltv, 재구매율


SELECT *
FROM "order"
SELECT key FROM "order_batch" WHERE store = '쿠팡' AND order_date >= '2022-10-01'

최근 6개월에 구매를 했는데, 최근 3개월 내에 재구매를 한 사람

