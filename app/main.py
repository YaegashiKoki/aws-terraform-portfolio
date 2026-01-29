from flask import Flask
import datetime
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    # 現在時刻と、コンテナのホスト名（どのコンテナで動いているか）を表示
    now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    host_name = socket.gethostname()
    
    html = f"""
    <html>
        <head>
            <title>AWS Portfolio App</title>
            <style>
                body {{ font-family: sans-serif; text-align: center; padding-top: 50px; background-color: #f0f2f5; }}
                .container {{ background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); display: inline-block; }}
                h1 {{ color: #007bff; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Hello, Cloud Engineer!</h1>
                <p>Current Time: <b>{now}</b></p>
                <p>Container ID: {host_name}</p>
                <p>Status: <span style="color:green; font-weight:bold;">Running on ECS Fargate</span></p>
            </div>
        </body>
    </html>
    """
    return html

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)