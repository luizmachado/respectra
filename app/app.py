from flask import Flask, render_template, request, redirect, url_for, jsonify
from langchain_google_genai import ChatGoogleGenerativeAI
from chains import json_chain
from chains import julia_chain
from chains import general_chain
from prompts import responde_prompt
from prompts import routing_prompt
from langchain_core.runnables import RunnableBranch
from langchain_core.output_parsers import StrOutputParser
import logging
import json
import os

app = Flask(__name__)

# Configuração da pasta para upload dos arquivos
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def chat_ia(query):
    # Substitui ChatOllama pelo modelo Gemini
    llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")
    route_prompt = routing_prompt()
    routing_chain = (route_prompt | llm | StrOutputParser())

    # Definindo os branches para diferentes rotas
    branch = RunnableBranch(
        (lambda x: "gerarjson" in x["topic"].lower(), json_chain),
        (lambda x: "execjulia" in x["topic"].lower(), julia_chain),
        lambda x: general_chain,
    )

    full_chain = (
        {"topic": routing_chain, "question": lambda x: x["question"]} | branch
    )

    resultado = full_chain.invoke({"question": query})
    return resultado


# Lista para armazenar mensagens do chat
chat_messages = []

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        file_mapping = {
                'file_cif': 'CIF',
                'file_MvsH1': 'MvsH1',
                'file_MvsH2': 'MvsH2',
                'file_MvsH3': 'MvsH3',
                'file_MvsT1': 'MvsT1',
                'file_MvsT2': 'MvsT2',
                'file_MvsT3': 'MvsT3',
                }

        for input_name, new_filename in file_mapping.items():
            file = request.files.get(input_name)
            if file and file.filename != '':
                ext = os.path.splitext(file.filename)[1]
                filepath = os.path.join(app.config['UPLOAD_FOLDER'],
                                        new_filename + ext)
                file.save(filepath)
    return render_template('index.html', chat_messages=chat_messages)

@app.route('/send_message', methods=['POST'])

def send_message():
    # Receber mensagem do chat via AJAX
    query_input = None
    output = None
    if request.method == 'POST':
        query_input = request.form.get('message')
        if query_input:
            try:
                print(query_input)
                output = chat_ia(query_input)
                print(output)
                image_path = None
                if os.path.exists("static/graph.png"):
                    image_path = "/static/graph.png"  # Caminho relativo para o navegador
            except Exception as e:
                logging.error(f"Erro ao acessar modelo de linguagem: {e}")
                output = "Desculpe, houve um erro ao processar a sua requisição."
    return jsonify({'status': 'success', 'messages': output, "image": image_path})

if __name__ == '__main__':
    app.run(debug=True)
