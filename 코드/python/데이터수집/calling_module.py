## 클래스를 정의해서 필요한 함수들을 넣고, 클래스 호출해서 콜링 해결하자.
## 이런 클래스들을 모아서 패키지로 만들어야겠다.


## 콜링 데이터 수집, 예외처리 포함 <- 일자별로 페이지네이션 주는게 필요할까?
## 콜링 데이터 가공
## 콜링 데이터 db 인서트 <- 그런데 db에 바로 넣는건 좀 지켜보다가 해야겠다. 일단 구글 시트에 올려서, 에러가 나는지 확인을 하다가 넣자.
## 콜링 데이터 마트에 업데이트


## 그리고 주석을 세세하게 달아야 댐. 내가 나중에 기억할 수 있게.
## id-615@datacollectautomation.iam.gserviceaccount.com

import time
from datetime import datetime, timedelta
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from oauth2client.service_account import ServiceAccountCredentials
from gspread_dataframe import get_as_dataframe, set_with_dataframe
import gspread


class calling():
    def __init__(self):
        self.키워드사운드_URL = 'https://keywordsound.com/service/keyword-analysis'
        self.자상호키워드_버전1 = ['판토모나,판토모나비오틴,판토모나샴푸,판토모나정,파이토웨이', '써큐시안,써큐시안블러드케어,홍메가텐,혈관종합영양제']
        self.자상호키워드_버전2 = ['판토모나,판토모나비오틴,판토모나비오틴하이퍼포머,판토모나정,판토모나하이퍼포머', '판토모나맨,판토모나남자,판토모나남성용,판토모나남성,판토모나레이디', '판토모나여자,판토모나여성용,판토모나여성,판토모나샴푸,써큐시안', '써큐시안블러드케어,싸이토팜,싸이토팜MSM,싸이토팜100,싸이토팜관절식물성MSM100', '파이토웨이마그네슘,루테콤,루테콤루테인지아잔틴,루테콤눈에좋은루테인지아잔틴,페미론큐', '페미론큐이노시톨,페미론큐이노시톨플러스콜린,페미론큐콜린이노시톨,파이토웨이,phytoway']
        self.키워드사운드_col = ['날짜', '키워드', 'PC검색량', '모바일검색량', '총검색량']
        self.result_col = ['날짜', '키워드', 'PC검색량', '모바일검색량', '총검색량', 'query']
        self.upload_sheet_url = 'https://docs.google.com/spreadsheets/d/13Wqg7dyVPPvN8CHix8qEJcRgkDTlHm7rLOpyuJvkJYo/edit#gid=0' # 콜링 수집 자동화 시트
        self.scope = ['https://spreadsheets.google.com/feeds']
        self.json_file_name = 'C:/phytoway_2/코드/python/데이터수집/datacollectautomation-04543e89aa13.json'
        self.credentials = ServiceAccountCredentials.from_json_keyfile_name(self.json_file_name, self.scope)


    def collect(self, keyword_list):
        try:

            yesterday = (datetime.today() - timedelta(days=1)).strftime("%Y-%m-%d")
            user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36'
            options = webdriver.ChromeOptions()
            options.add_argument('user-agent=' + user_agent)
            options.add_argument("headless")
            options.add_experimental_option("excludeSwitches", ["enable-logging"])
            driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
            driver.maximize_window()
            time.sleep(3)

           
            rows = []
            for keyword in keyword_list:
                

                # 클릭으로 검색하지 않고 url에 쿼리 스트링 넣어서 검색
                query = '?keywords=' + keyword
                target_url = self.키워드사운드_URL + query
                driver.get(target_url)
                driver.implicitly_wait(10)


                # 에러 메시지가 나는 경우가 있어서 에러 있는 경우 최대 20번 반복하며 다시 호출.
                # 미안해서 20번으로 제한두었음.
                error_times = 0
                while True:
                    try:
                        if error_times > 20:
                            break
                        else:
                            err_msg = driver.find_element(By.CLASS_NAME, "swal2-confirm")
                            err_msg.click()
                            time.sleep(3)
                            driver.get(target_url)
                            driver.implicitly_wait(10)
                    except:
                        break
                    finally:
                        error_times += 1
               

                ## 명시적 대기 필요. 검색량 테이블이 완전히 로딩 되었을 때
                WebDriverWait(driver, 1000).until(EC.text_to_be_present_in_element((By.CLASS_NAME, "even"), yesterday))
                time.sleep(3)


                # 키워드 사운드 검색량 테이블 접근
                SearchVolume = driver.find_element(By.ID, "tableSearchVolume_wrapper")
                table = SearchVolume.text.split('\n')[7:17]
                

                ## 어제 날짜만 필터링해서 리스트에 넣음
                yesterday_date = datetime.strptime(yesterday, '%Y-%m-%d')
                for i in table:
                    row = i.split()
                    if datetime.strptime(row[0], '%Y-%m-%d') == yesterday_date:
                        rows.append(row)
                    else:
                        pass
                        

            ## 데이터 프레임 생성
            result = pd.DataFrame(data=rows, columns=self.키워드사운드_col)

            ## db에 넣을 쿼리 형태로 생성
            if keyword_list == self.자상호키워드_버전1:
                result['query'] = "insert into " + '"Query_Log" ' + "values " + "('" +result['날짜'] + "', '" + result['키워드'] + "', " + result['PC검색량'] + ", " + result['모바일검색량'] + ");"
            elif keyword_list == self.자상호키워드_버전2:
                result['query'] = "insert into " + '"Query_Log2" ' + "values " + "('" +result['날짜'] + "', '" + result['키워드'] + "', " + result['PC검색량'] + ", " + result['모바일검색량'] + ");"

 
        except:
            print("오류 발생. 확인해보세요")


        finally:
            driver.quit()
            return result
        

    def upload_sheet(self, result):
        
        # 콜링 데이터 업로드할 구글 시트 인증 및 접근
        gc = gspread.authorize(self.credentials)
        ss = gc.open_by_url(self.upload_sheet_url)
        ws = ss.worksheet('콜링')
        row_num = len(ws.col_values(1)) + 1 # 첫번째 열의 모든 값 가져온 뒤 개수 세기. 즉, 행 개수 알아내기.

       
        df = pd.DataFrame(result)
        df.columns = self.result_col
        set_with_dataframe(ws, df, row=row_num, include_index=False, include_column_header=False, resize=False)
        print('구글 시트에 콜링 데이터 업로드 완료')


    def insert_db():
        pass