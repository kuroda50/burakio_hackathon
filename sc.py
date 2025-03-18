import requests
from bs4 import BeautifulSoup
import urllib.parse
import re

def search_profile_url(name):
    """
    研究者名からプロフィールURLを検索する
    """
    # URLエンコード
    encoded_name = urllib.parse.quote(name)
    affiliation = urllib.parse.quote('福岡大学')  # 固定ならここで指定
    search_url = f'https://researchmap.jp/researchers?name={encoded_name}&affiliation={affiliation}'
    
    print(f'検索URL: {search_url}')

    headers = {
        'User-Agent': 'Mozilla/5.0'
    }

    response = requests.get(search_url, headers=headers)

    if response.status_code != 200:
        print('検索ページの取得に失敗:', response.status_code)
        return None

    soup = BeautifulSoup(response.text, 'html.parser')
    links = soup.find_all('a', href=True)

    profile_link_tag = None
    
    for link in links:
        href = link['href']
        # パターンに合うリンクを探す
        if href.startswith('/') and not href.startswith('/researchers'):
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

def find_avatar_url(profile_url):
    """
    プロフィールページからアバター画像URLを取得する
    """
    headers = {
        'User-Agent': 'Mozilla/5.0'
    }

    response = requests.get(profile_url, headers=headers)

    if response.status_code != 200:
        print('プロフィールページ取得失敗:', response.status_code)
        return None

    soup = BeautifulSoup(response.text, 'html.parser')
    img_tags = soup.find_all('img')
    
    avatar_url = None
    for img in img_tags:
        img_src = img.get('src')
        if img_src and 'avatar' in img_src:
            if img_src.startswith('/'):
                avatar_url = 'https://researchmap.jp' + img_src
            else:
                avatar_url = img_src
            print('アバター画像URL:', avatar_url)
            break

    if not avatar_url:
        print('アバター画像が見つかりませんでした')

    return avatar_url

# テスト実行用
if __name__ == '__main__':
    import sys

    if len(sys.argv) > 1:
        researcher_name = sys.argv[1]
        profile_url = search_profile_url(researcher_name)
        avatar_url = find_avatar_url(profile_url) if profile_url else None

        print(f'プロフィールURL: {profile_url}')
        print(f'アバター画像URL: {avatar_url}')
    else:
        print("使い方: python sc.py '研究者名'")
