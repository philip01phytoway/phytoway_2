import requests


url = "https://m.search.naver.com/search.naver?where=m_view&sm=mtb_jum&query=%EB%B9%84%EC%98%A4%ED%8B%B4"


headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537',
    'Referer': 'https://www.google.com',
    'Accept-Language': 'en-US,en;q=0.5'
}

session = requests.Session()

response = session.get(url, headers=headers)



print(response.text)
print(response.status_code)