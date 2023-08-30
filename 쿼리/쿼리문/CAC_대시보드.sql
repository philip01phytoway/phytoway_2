

-- reg_date의 최댓값으로 where 조건 걸어서 keyword_occ 테이블과 join.
SELECT * FROM "keyword_occ_log"


-- Page 테이블에 발행일을 못넣어서 임시 테이블에서 발행일 삽입 (2차 버전에서 통합 예정)
SELECT * FROM "page_temp"



SELECT *
FROM "Page" AS p
LEFT JOIN "page_temp" AS t ON (p.id = t.content_id)
WHERE t.content_id IS NOT NULL 


SELECT *
FROM 	(
			SELECT id, REPLACE("keyword", ' ', '') AS keyword_mod 
			FROM "Page"
			WHERE page_type = '블로그'
		) AS t
LEFT JOIN "keyword_occ" AS k ON (t.keyword_mod = k.sub_keyword_novoid)
WHERE k.sub_keyword_novoid IS NULL 


-- Page 테이블에는 있는데 keyword_occ에는 없는 키워드는 keyword_occ에 추가를 하자.
-- 일단 이건 나중에 하고, Page에 등록된 키워드로만 보고서를 뽑아보자.


-- 일자별, 키워드별 발행건수
-- page_temp에 keyword_no도 추가를 해야 된다.
SELECT t.post_date, p.keyword, COUNT(*)
FROM "Page" AS p
LEFT JOIN "page_temp" AS t ON (p.id = t.content_id)
WHERE t.content_id IS NOT NULL AND page_type = '블로그'
GROUP BY t.post_date, p.keyword
Order BY t.post_date desc



-- 일자별, 키워드별 발행건수
-- 발행 키워드랑 일치하는 점유 키워드만 가져오기

SELECT *
FROM (
			SELECT 	
						dense_rank() over(partition BY reg_date, search_keyword Order BY rank) AS occ_rank,						  (regexp_matches(split_part(url, '?', 1), '[^/]+$'))[1] as url_key,
						*
			FROM "naver_view_occ"
			WHERE post_type <> '광고'
			--Order BY search_keyword, occ_rank
) AS t
LEFT JOIN "keyword_occ" AS k ON (t.keyword_no = k.keyword_no)
LEFT JOIN (SELECT *, (regexp_matches(split_part(page_url, '?', 1), '[^/]+$'))[1] as url_key FROM "Page") AS p ON (t.url_key = p.url_key)
LEFT JOIN "page_temp" AS p_t ON (p.id = p_t.content_id)
LEFT JOIN "product" AS pd ON (k.product_no = pd.no)
WHERE post_type NOT IN ('카페', '포스트') AND occ_rank <= 5 AND p.url_key IS NOT NULL 
AND t.reg_date >= '2023-08-29' AND p_t.post_date >= TO_CHAR(CURRENT_DATE - INTERVAL '1 week', 'YYYY-MM-DD')
AND k.sub_keyword_novoid = REPLACE(p.keyword, ' ', '')




select (CURRENT_DATE - INTERVAL '1 week')

SELECT TO_CHAR(CURRENT_DATE - INTERVAL '1 week', 'YYYY-MM-DD');


LIMIT 500


GROUP BY t.reg_date, k.sub_keyword_novoid, t.url_key
Order BY t.reg_date desc

) AS occ
WHERE reg_date = '2023-08-29'






