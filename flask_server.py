from flask import Flask, request, jsonify
from sc import search_profile_url, find_avatar_url  # ← 今作ったスクリプトをモジュールとして使う

app = Flask(__name__)

@app.route('/get_avatar')
def get_avatar():
    researcher_name = request.args.get('researcher_name', '')
    if not researcher_name:
        return jsonify({'error': 'No researcher name provided'}), 400

    profile_url = search_profile_url(researcher_name)
    avatar_url = find_avatar_url(profile_url) if profile_url else None

    if not profile_url:
        return jsonify({'error': 'Profile not found'}), 404
    if not avatar_url:
        return jsonify({'error': 'Avatar not found'}), 404

    return jsonify({
        'profile_url': profile_url,
        'avatar_url': avatar_url
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
