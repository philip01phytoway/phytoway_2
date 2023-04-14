-- 데이터 2.0

-- 2023-04-13 스터디
SQL의 기본 명령문 4가지

1. SELECT : 조회
2. UPDATE : 수정
3. INSERT : 입력
4. DELETE : 삭제

cac 계정은 SELECT만 할 수 있도록 권한 설정 되었음.

쿼리 실행하는 단축키 : Ctrl + F9 

SELECT문 기본 구조 
SELECT 컬럼 FROM 테이블 WHERE 조건 GROUP BY 컬럼 ORDER BY 컬럼 LIMIT 개수

기타 연산자
LIKE, IN, *, NOT IN, NOT LIKE

주석
--


-- 기본 주문 데이터 조회하기
SELECT * --yymm, prd_amount_mod -- *의 의미 : 모든 컬럼을 조회할래
FROM "order_batch" -- "order_batch" 테이블에서
LIMIT 10000 -- 10000개만 보여줘.


-- 월별 매출 총액 조회하기
SELECT yymm, SUM(prd_amount_mod) AS "gross"
FROM "order_batch"
WHERE yymm IS NOT NULL -- 
GROUP BY yymm
Order BY "gross" desc


-- 월별, 스토어별 매출 총액 조회하기
SELECT yymm, store, SUM(prd_amount_mod)
FROM "order_batch"
WHERE yymm IS NOT NULL
GROUP BY yymm, store
Order BY yymm DESC, store


-- 월별, 스토어별, 브랜드별 매출 총액 조회하기
SELECT yymm, store, brand, SUM(prd_amount_mod)
FROM "order_batch"
WHERE yymm IS NOT NULL
GROUP BY yymm, store, brand
Order BY yymm DESC, store


-- 월별, 스토어별, 브랜드별, 제품별 매출 총액 조회하기
SELECT yymm, store, brand, nick, SUM(prd_amount_mod)
FROM "order_batch"
WHERE yymm IS NOT NULL
GROUP BY yymm, store, brand, nick
Order BY yymm DESC, store


-- 월별, 스토어별, 브랜드별, 제품별 매출 총액, 주문건수 조회하기
SELECT yymm, store, brand, nick, SUM(prd_amount_mod), COUNT(DISTINCT order_id)
FROM "order_batch"
--WHERE yymm IS NOT NULL
GROUP BY yymm, store, brand, nick
Order BY yymm DESC, store


-- 월별, 스토어별, 브랜드별, 제품별 (파이토웨이) 신규고객수 조회하기
SELECT yymm, store, brand, nick, COUNT(DISTINCT KEY)
FROM "order_batch"
WHERE yymm IS NOT NULL AND all_cust_type = '신규'
GROUP BY yymm, yyww, order_date, store, brand, nick
Order BY yymm DESC, store


-- 월별, 스토어별, 브랜드별, 제품별 리셀러 매출 조회하기
SELECT yymm, store, brand, nick, SUM(prd_amount_mod)
FROM "order_batch"
WHERE yymm IS NOT NULL AND prd_amount_mod > 500000 -- and b2b store 제외
GROUP BY yymm, store, brand, nick
Order BY yymm DESC, store