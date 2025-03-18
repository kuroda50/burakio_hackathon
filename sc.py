import requests
from bs4 import BeautifulSoup
import urllib.parse
import time
import re  # 正規表現モジュール追加

def search_profile_url(name):
    # URLエンコード
    encoded_name = urllib.parse.quote(name)
    
    # 福岡大学固定
    affiliation = urllib.parse.quote('福岡大学')
    
    # 検索URL生成
    search_url = f'https://researchmap.jp/researchers?name={encoded_name}&affiliation={affiliation}'
    print(f'\n検索URL: {search_url}\n')

    headers = {
        'User-Agent': 'Mozilla/5.0'
    }

    # 検索結果ページ取得
    response = requests.get(search_url, headers=headers)

    if response.status_code != 200:
        print('検索ページの取得に失敗:', response.status_code)
        return None

    soup = BeautifulSoup(response.text, 'html.parser')

    # aタグの一覧を取得
    links = soup.find_all('a', href=True)

    profile_link_tag = None
    
    for link in links:
        href = link['href']
        
        # 条件1: '/' で始まるリンク
        # 条件2: パスが "researchers" じゃない（検索ページのリンクと混同しないため）
        # 条件3: 正規表現でユーザーID形式（英数字）を検出（例: /jh6vjm）
        if href.startswith('/') and not href.startswith('/researchers'):
            # ユーザーIDっぽい形式の確認
            if re.fullmatch(r'/[a-zA-Z0-9_-]+', href):
                profile_link_tag = href
                break

    if profile_link_tag:
        profile_url = 'https://researchmap.jp' + profile_link_tag
        print(f'プロフィールページURL: {profile_url}')
        return profile_url
    else:
        print('プロフィールページが見つかりませんでした')
        return None


def download_avatar(profile_url, researcher_name):
    headers = {
        'User-Agent': 'Mozilla/5.0'
    }

    response = requests.get(profile_url, headers=headers)

    if response.status_code != 200:
        print('プロフィールページ取得失敗:', response.status_code)
        return

    soup = BeautifulSoup(response.text, 'html.parser')

    # imgタグの中からアバター画像を探す
    img_tags = soup.find_all('img')
    
    avatar_url = None
    for img in img_tags:
        img_src = img.get('src')
        # "avatar" が含まれている画像URLを探す
        if img_src and 'avatar' in img_src:
            if img_src.startswith('/'):
                avatar_url = 'https://researchmap.jp' + img_src
            else:
                avatar_url = img_src
            print('アバター画像URL:', avatar_url)
            break

    if not avatar_url:
        print('アバター画像が見つかりませんでした')
        return

    # 画像をダウンロードして保存
    img_response = requests.get(avatar_url)
    if img_response.status_code == 200:
        filename = researcher_name.replace(' ', '_') + '_avatar.jpg'
        with open(filename, 'wb') as f:
            f.write(img_response.content)
        print(f'{filename} を保存しました！')
    else:
        print('画像取得失敗:', img_response.status_code)


if __name__ == '__main__':
    researcher_name = input('研究者の名前を入力してください（例: 末次 正）: ')
    
    profile_url = search_profile_url(researcher_name)

    if profile_url:
        time.sleep(1)
        download_avatar(profile_url, researcher_name)









