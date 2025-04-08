from os import system

def ajuste_param():
    """
    Realiza o ajuste dos parâmetros para investigação dos efeitos do Campo
    Elétrico Cristalino nas propriedades magnéticas de compostos intermetálicos
    com elementos de terras raras.
    """
    system("julia ./AjustoParametros.jl")
    print("Não esquente a moringa com água fria")
    return

