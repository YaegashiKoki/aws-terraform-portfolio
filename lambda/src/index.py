import json
import boto3
import os
from openai import OpenAI

ssm_client = boto3.client('ssm')

def get_ssm_parameter(name):
    response = ssm_client.get_parameter(Name=name, WithDecryption=True)
    return response['Parameter']['Value']

def load_faq():
    # Lambda内のローカルファイル(faq.json)を読み込む
    file_path = os.path.join(os.path.dirname(__file__), 'faq.json')
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def search_faq(user_question, faq_list):
    # 【Retrieval（検索）】
    # ユーザーの質問にキーワードが含まれているFAQを抽出する
    retrieved = []
    for faq in faq_list:
        for keyword in faq['keywords']:
            if keyword.lower() in user_question.lower():
                retrieved.append(f"Q: {faq['question']}\nA: {faq['answer']}")
                break # 1つのFAQが重複して追加されないようにする
    return retrieved

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        user_question = body.get('question', 'こんにちは！')

        # 1. FAQデータの読み込み
        faq_list = load_faq()

        # 2. 関連するFAQを検索
        retrieved_faqs = search_faq(user_question, faq_list)
        
        # 検索結果をひとつの文字列にまとめる
        context_text = "\n\n".join(retrieved_faqs) if retrieved_faqs else "関連するFAQは見つかりませんでした。"

        # 3. 【Augmented（拡張）】
        # AIに対する指示書（システムプロンプト）に、検索した社内ルールを埋め込む！
        system_prompt = f"""
        あなたは「aslead DevOps ヘルプデスク」の優秀なAIアシスタントです。
        以下の【参考FAQ】のみを元にして、ユーザーの質問に回答してください。
        【参考FAQ】に答えがない場合は、勝手に想像で答えず「申し訳ありませんが、マニュアルに記載がありません。担当者にお繋ぎします。」と回答してください。

        【参考FAQ】
        {context_text}
        """

        # 4. 【Generation（生成）】
        api_key = get_ssm_parameter('/ai-helpdesk/openai-api-key')
        client = OpenAI(api_key=api_key)

        completion = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_question}
            ],
            temperature=0.0 # 💡重要：RAGの時はAIの「想像力」を消すため、temperatureを0にする
        )
        
        ai_response = completion.choices[0].message.content

        # 5. レスポンスを返す（デバッグ用に「検索したFAQ」も一緒に返す）
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json; charset=utf-8"
            },
            "body": json.dumps({
                "question": user_question,
                "retrieved_context": retrieved_faqs, # 裏側で何を検索したか見れるようにする
                "answer": ai_response
            }, ensure_ascii=False)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal Server Error"})
        }