# 軽量なPythonイメージを使用
FROM python:3.9-slim

# 作業ディレクトリを設定
WORKDIR /app

# 必要なファイルをコピー
COPY requirements.txt .
COPY main.py .

# ライブラリをインストール
RUN pip install --no-cache-dir -r requirements.txt

# ポート80を開ける
EXPOSE 80

# アプリ起動コマンド
CMD ["python", "main.py"]