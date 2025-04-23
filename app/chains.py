from langchain_core.runnables import chain
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.output_parsers import JsonOutputParser
from prompts import cef_json_prompt, responde_prompt, chart_prompt
from utils.tools import format_and_save_json, verificar_arquivos, exec_graph, limpa_temp
from models import AjusteCompleto
from os import chdir
from src_julia.exec_julia import ajuste_param
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from prompts import routing_prompt
from langchain_core.runnables import RunnableBranch
import os

llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

parser = JsonOutputParser(pydantic_object=AjusteCompleto)

arquivos_txt = ['ConfSpin_Calc.txt', 'CsT_calc.txt', 'Entrop_calc.txt', 'MH1_calc.txt', 'MH2_calc.txt', 'MT1_calc.txt', 'MT2_calc.txt']
julia_dir = './src_julia'


def routing_chain():
    prompt = routing_prompt()
    return (prompt | llm | StrOutputParser())

# Função para definir qual cadeia de execução será utilizada
def create_routing_branch(json_chain, julia_chain, general_chain):
    return RunnableBranch(
        (lambda x: "gerarjson" in x["topic"].lower(), json_chain),
        (lambda x: "execjulia" in x["topic"].lower(), julia_chain),
        lambda x: general_chain,
    )

@chain
def general_chain(text):
    limpa_temp()
    prompt = responde_prompt()
    return (prompt | llm | StrOutputParser()).invoke({"question": text})

# Função para gerar JSON a partir do modelo
@chain
def json_chain(text):
    prompt = cef_json_prompt(parser)
    gerarjson_chain = (prompt | llm | parser)
    output = gerarjson_chain.invoke({"question": text})
    return format_and_save_json(str(output))

@chain
def julia_chain(text):
    prompt = chart_prompt
    gerarchart_chain = (prompt | llm | StrOutputParser())
    output = gerarchart_chain.invoke({"question": text})
    output = output.rstrip()
    if verificar_arquivos(arquivos_txt, julia_dir):
        exec_graph(output)
        print(output)

    else:
        chdir(julia_dir)
        ajuste_param()
        chdir('../')
        exec_graph(output)
        return "Função Julia executada com sucesso"
