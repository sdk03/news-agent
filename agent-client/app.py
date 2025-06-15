from flask import Flask, render_template, request, jsonify
import requests
import os

app = Flask(__name__)

# Configuration
AGENT_SERVER_URL = "http://localhost:3000"  # Update this if your agent server runs on a different port

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/login', methods=['POST'])
def login():
    try:
        response = requests.post(f"{AGENT_SERVER_URL}/api/login", json=request.json)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/news/headline')
def get_headline():
    try:
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"error": "No token provided"}), 401

        response = requests.get(
            f"{AGENT_SERVER_URL}/api/news/khaleej-times/headline",
            headers={"Authorization": token}
        )
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/news/headlines')
def get_headlines():
    try:
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"error": "No token provided"}), 401

        response = requests.get(
            f"{AGENT_SERVER_URL}/api/news/khaleej-times/headlines",
            headers={"Authorization": token}
        )
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/news/article')
def get_article():
    try:
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"error": "No token provided"}), 401

        url = request.args.get('url')
        if not url:
            return jsonify({"error": "URL parameter is required"}), 400

        response = requests.get(
            f"{AGENT_SERVER_URL}/api/news/khaleej-times/article",
            headers={"Authorization": token},
            params={"url": url}
        )
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)