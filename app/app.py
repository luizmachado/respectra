from flask import Flask, render_template, request, redirect, url_for, jsonify
import os

app = Flask(__name__)

# Configuração da pasta para upload dos arquivos
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Lista para armazenar mensagens do chat
chat_messages = []

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        file_mapping = {
                'file_cif': 'CIF',
                'file_MvsH1': 'MvsH1',
                'file_MvsH2': 'MvsH2',
                'file_MvsH3': 'MvsH2',
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
    message = request.form.get('message')
    if message:
        chat_messages.append(message)
    return jsonify({'status': 'success', 'messages': chat_messages})

if __name__ == '__main__':
    app.run(debug=True)



