from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time

# WebDriverのパスを指定（例: ChromeDriverの場合）
driver_path = '/path/to/chromedriver'  # 実際のパスに置き換えてください
driver = webdriver.Chrome(executable_path=driver_path)

try:
    # サイトを開く
    driver.get('https://acex.jsysneo.fukuoka-u.ac.jp/kyogaku/syllabus/syllabus/public_html/index.php')

    # ページが完全に読み込まれるまで待機
    time.sleep(2)

    # 'kamoku_name'フィールドを探してキーワードを入力
    search_box = driver.find_element(By.NAME, 'kamoku_name')
    search_box.clear()  # 既存の値をクリア
    search_box.send_keys('プログラミング')  # 検索キーワードを入力

    # 検索実行（Enterキーを送信）
    search_box.send_keys(Keys.RETURN)

    # 検索結果が表示されるまで待機
    time.sleep(3)

    # 検索結果の処理（例: 結果を表示）
    results = driver.find_elements(By.CSS_SELECTOR, 'table tr')
    for result in results:
        print(result.text)

finally:
    # ブラウザを閉じる
    driver.quit()
