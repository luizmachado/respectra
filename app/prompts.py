from langchain_core.prompts import PromptTemplate

def cef_json_prompt(parser):
    return PromptTemplate(
        template="""
        Você precisa seguir as instruções e gerar o arquivo com os parâmetros na ordem
        em que é apresentado nas instruções de formatação.\n{format_instructions}\n
        Considere o seguinte texto: {question}\n. Caso falte informar algum
        informação, preencha com zero. Não deixe de criar o parâmetro Ajustar
        que esteja vazio""",
        input_variables=["question"],
        partial_variables={"format_instructions": parser.get_format_instructions()}
    )


def julia_prompt():
    return PromptTemplate(
        template="""Você é um especialista em Programação...
        Pergunta: {question}""",
        input_variables=["question"],
    )

from langchain_core.prompts import PromptTemplate

def routing_prompt():
    return PromptTemplate(
        template="""Dado a pergunta abaixo, classifique entre:
        `GerarJson`: quando houver a necessidade de gerar o arquivo de
        parâmetro com os valores para ajuste do modelo, são eles os valores de
        J e B que podem corresponder aos níveis de energia.
        `ExecJulia`: quando houver a necessidade de executar a função para
        predizer as propriedades do campo elétrico cristalino, isto realizará a
        execução de uma simulação para predizer as propriedades magnéticas, de
        entropia e calor específico.
        `Outro`: quando não houver relação com o ajuste nem com a execução
        da função.
        Não responda com mais de uma palavra.

        Pergunta: {question}

        Classificação:
        """,
        input_variables=["question"]
    )


def responde_prompt():
    return PromptTemplate(
        template="""Você é um especialista em Física e deve responder de
        forma clara e detalhada a perguntas feitas por alunos de graduação
        e pós-graduação. Use uma linguagem acadêmica, fornecendo
        explicações que ajudem na compreensão profunda dos conceitos, mas
        sem simplificar excessivamente. Sempre que possível, forneça
        exemplos práticos e referências relevantes. Se a pergunta for sobre
        um conceito avançado, comece com uma breve revisão dos conceitos
        fundamentais antes de aprofundar na resposta. Caso não saiba a
        resposta, não hesite em informar que ainda não possui conhecimento
        suficiente.

        Pergunta: {question}""",
        input_variables=["question"]
    )

def chart_prompt(parser):
    return PromptTemplate(
        template="""Dado a resposta abaixo, classifique entre:
        `GerarSpin`: quando houver a necessidade de predizer as propriedades de
        spin.
        `GerarEntrop`: quando houver a necessidade de predizer as propriedades
        de entropia ou calor específico.
        `GerarMag`: quando houver a necessidade de predizer as propriedades
        magnéticas.
        Não responda com mais de uma palavra.

        Pergunta: {question}

        Classificação:
        """,
        input_variables=["question"]
        )

