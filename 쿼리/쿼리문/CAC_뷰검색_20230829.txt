-- 네이버 점유결과를 수집하여 로컬에 저장하고 db에 저장하는 것은 매일 오전 실행함.
-- 그때 아래 뷰 실행하면 점유 결과를 볼 수 있는데, 이때 Page 테이블에 업데이트가 필요함.
-- 업데이트가 안되어있다면, 새로 발행된 건의 url이 누락된 상태의 점유 결과가 나옴.
-- 업데이트를 하면, 새로 발행된 건의 url이 포함된 상태의 점유 결과가 나옴.



-- 네이버 뷰검색 점유결과
-- 일자 변경하여 사용
-- 만약 오늘자 점유결과가 없다면 아직 점유 체크가 안된 것
SELECT *
FROM "naver_occ_view"
WHERE reg_date = '2023-08-29'



-- 사전 준비사항
-- Page 테이블에 url 업데이트
SELECT * 
FROM "Page" 
WHERE page_type = '블로그' AND page_url IS null


-- 업데이트 쿼리
-- https://docs.google.com/spreadsheets/d/1g8969fDHVt8szpXRIV6J_ocYc-K9tfVaGVVc0mo82L4/edit#gid=0




