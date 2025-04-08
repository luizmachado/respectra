from src_julia.graficos_matplotlib import mag_matplotlib, cs_matplotlib, spin_matplotlib
import logging
import json
import re
import os


arquivos_txt = ['ConfSpin_Calc.txt', 'CsT_calc.txt', 'Entrop_calc.txt',
                'MH1_calc.txt', 'MH2_calc.txt', 'MT1_calc.txt', 'MT2_calc.txt',
                ]
julia_dir = './src_julia'

def limpa_temp():
    # Itera sobre a lista de arquivos
    for arquivo in arquivos_txt:
        # Cria o caminho completo para o arquivo
        caminho_arquivo = os.path.join(julia_dir, arquivo)
        
        # Verifica se o arquivo existe no diretório
        if os.path.exists(caminho_arquivo):
            try:
                # Remove o arquivo
                os.remove(caminho_arquivo)
                os.remove("graph.png")
                print(f"Arquivo removido: {arquivo}")
            except Exception as e:
                print(f"Erro ao remover {arquivo}: {e}")
        else:
            print(f"Arquivo não encontrado: {arquivo}")

def format_and_save_json(json_string, file_name="./src_julia/SoloParametros.json"):
    """
    Formata uma string JSON e salva o resultado em um arquivo .json.

    :param json_string: String no formato JSON a ser formatada
    :param file_name: Nome do arquivo onde o JSON será salvo (padrão: SoloParametros.json)
    """
    try:
        limpa_temp()
        # Substitui aspas simples por aspas duplas
        json_string = re.sub(r"'", '"', json_string)

        # Converte a string JSON em um dicionário Python
        json_data = json.loads(json_string)

        # Abre o arquivo em modo de escrita e salva o JSON formatado
        with open(file_name, 'w') as json_file:
            json.dump(json_data, json_file, indent=4, sort_keys=True)

        print(f"Arquivo {file_name} salvo com sucesso.")
        with open(file_name, 'r') as json_file:
            return json.load(json_file)

    except json.JSONDecodeError as e:
        print(f"Erro ao processar JSON: {e}")


def setup_logger():
    logging.basicConfig(level=logging.INFO)
    return logging.getLogger("AppLogger")

def verificar_arquivos(lista_arquivos, diretorio):
    # Obter a lista de arquivos no diretório
    arquivos_no_diretorio = os.listdir(diretorio)
    
    # Verificar se todos os arquivos da lista estão no diretório
    arquivos_faltando = [arquivo for arquivo in lista_arquivos if arquivo not in arquivos_no_diretorio]
    
    if not arquivos_faltando:
        print("Todos os arquivos estão presentes no diretório.")
        return True
    else:
        print("Os seguintes arquivos estão faltando no diretório:", arquivos_faltando)
        return False

def exec_graph(tipo):
    print(f"Tipo de gráfico solicitado: {tipo.lower()}")
    if tipo.lower() == 'gerarspin':
        # Gera gráfico de Spin
        spin_matplotlib()
    elif tipo.lower() == 'gerarentrop':
        # Gera gráfico de Entropia
        cs_matplotlib()
    elif tipo.lower() == 'gerarmag':
        # Gera gráfico de Magnetização
        mag_matplotlib()
    else:
        print(f'Função do gráfico {tipo} não encontrada')

def coletar_respostas():
    # Perguntas e coleta das respostas das duas primeiras perguntas em uma única variável
    estrutura_ajustes = (
        input("Quais são as propriedades estruturais (parâmetros de rede, grupo especial, célula, etc.)? ") + "\n" +
        input("Quais são os parâmetros de ajuste B's e J's? ")
    )
    
    # Pergunta sobre as propriedades desejadas para cálculo
    propriedades_desejadas = input("Quais propriedades deseja calcular? ")
    
    return estrutura_ajustes, propriedades_desejadas
from src_julia.graficos_matplotlib import mag_matplotlib, cs_matplotlib, spin_matplotlib
import logging
import json
import re
import os


arquivos_txt = ['ConfSpin_Calc.txt', 'CsT_calc.txt', 'Entrop_calc.txt',
                'MH1_calc.txt', 'MH2_calc.txt', 'MT1_calc.txt', 'MT2_calc.txt',
                ]
julia_dir = './src_julia'

def limpa_temp():
    # Itera sobre a lista de arquivos
    for arquivo in arquivos_txt:
        # Cria o caminho completo para o arquivo
        caminho_arquivo = os.path.join(julia_dir, arquivo)
        
        # Verifica se o arquivo existe no diretório
        if os.path.exists(caminho_arquivo):
            try:
                # Remove o arquivo
                os.remove(caminho_arquivo)
                os.remove("graph.png")
                print(f"Arquivo removido: {arquivo}")
            except Exception as e:
                print(f"Erro ao remover {arquivo}: {e}")
        else:
            print(f"Arquivo não encontrado: {arquivo}")

def format_and_save_json(json_string, file_name="./src_julia/SoloParametros.json"):
    """
    Formata uma string JSON e salva o resultado em um arquivo .json.

    :param json_string: String no formato JSON a ser formatada
    :param file_name: Nome do arquivo onde o JSON será salvo (padrão: SoloParametros.json)
    """
    try:
        limpa_temp()
        # Substitui aspas simples por aspas duplas
        json_string = re.sub(r"'", '"', json_string)

        # Converte a string JSON em um dicionário Python
        json_data = json.loads(json_string)

        # Abre o arquivo em modo de escrita e salva o JSON formatado
        with open(file_name, 'w') as json_file:
            json.dump(json_data, json_file, indent=4, sort_keys=True)

        print(f"Arquivo {file_name} salvo com sucesso.")
        with open(file_name, 'r') as json_file:
            return json.load(json_file)

    except json.JSONDecodeError as e:
        print(f"Erro ao processar JSON: {e}")


def setup_logger():
    logging.basicConfig(level=logging.INFO)
    return logging.getLogger("AppLogger")

def verificar_arquivos(lista_arquivos, diretorio):
    # Obter a lista de arquivos no diretório
    arquivos_no_diretorio = os.listdir(diretorio)
    
    # Verificar se todos os arquivos da lista estão no diretório
    arquivos_faltando = [arquivo for arquivo in lista_arquivos if arquivo not in arquivos_no_diretorio]
    
    if not arquivos_faltando:
        print("Todos os arquivos estão presentes no diretório.")
        return True
    else:
        print("Os seguintes arquivos estão faltando no diretório:", arquivos_faltando)
        return False

def exec_graph(tipo):
    print(f"Tipo de gráfico solicitado: {tipo.lower()}")
    if tipo.lower() == 'gerarspin':
        # Gera gráfico de Spin
        spin_matplotlib()
    elif tipo.lower() == 'gerarentrop':
        # Gera gráfico de Entropia
        cs_matplotlib()
    elif tipo.lower() == 'gerarmag':
        # Gera gráfico de Magnetização
        mag_matplotlib()
    else:
        print(f'Função do gráfico {tipo} não encontrada')

def coletar_respostas():
    # Perguntas e coleta das respostas das duas primeiras perguntas em uma única variável
    estrutura_ajustes = (
        input("Quais são as propriedades estruturais (parâmetros de rede, grupo especial, célula, etc.)? ") + "\n" +
        input("Quais são os parâmetros de ajuste B's e J's? ")
    )
    
    # Pergunta sobre as propriedades desejadas para cálculo
    propriedades_desejadas = input("Quais propriedades deseja calcular? ")
    
    return estrutura_ajustes, propriedades_desejadas
