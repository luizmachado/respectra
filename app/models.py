# Importações necessárias para as classes Pydantic
from langchain_core.pydantic_v1 import BaseModel, Field

# Definição das classes de dados usando Pydantic para ajuste do CEF e acoplamentos
class CefAjuste(BaseModel):
    B20: float = Field(description="B20")
    B40: float = Field(description="B40")
    B4M3: float = Field(description="B4M3")
    B43: float = Field(description="B43")
    B60: float = Field(description="B60")
    B63: float = Field(description="B63")
    B66: float = Field(description="B66")
    B6M3: float = Field(description="B6M3")
    B6M6: float = Field(description="B6M6")

class Acoplamentos(BaseModel):
    J1: float = Field(description="J1")
    J2: float = Field(description="J2")
    QTbTb: float = Field(description="QTbTb")

class AjusteCef(BaseModel):
    Ajustar: dict = Field(description="Ajustar")  # Dicionário vazio
    NoAjustar: CefAjuste = Field(description="NoAjustar")
    Ajustar = {}

class AjusteAcoplamientos(BaseModel):
    Ajustar: dict = Field(description="Ajustar")  # Dicionário vazio
    NoAjustar: Acoplamentos = Field(description="NoAjustar")
    Ajustar = {}

class AjusteCompleto(BaseModel):
    CEF: AjusteCef = Field(description="CEF")
    Acoplamientos: AjusteAcoplamientos = Field(description="Acoplamientos")


