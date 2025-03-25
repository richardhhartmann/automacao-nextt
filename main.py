from Auto.db_conn import preencher_planilha, dados_necessarios
from Auto.db_module import importar_modulo_vba
import os

caminho_arquivo = 'Cadastros Auto Nextt limpa.xlsx'
caminho_novo_arquivo = 'Cadastros Auto Nextt.xlsx'

modulos_vba = [
    "CriarIntervalosNomeadosB.bas", 
    "cadastro_de_produtos.bas",
    "cadastro_de_marcas.bas",
    "cadastro_de_segmento.bas",
    "cadastro_de_secao.bas",
    "cadastro_de_especie.bas"
]

if not os.path.exists(caminho_arquivo):
    print(f"Arquivo não encontrado: {caminho_arquivo}")
    exit()

dados = dados_necessarios()

def main():
    print("Preenchendo planilha...\n")

    preencher_planilha(dados, caminho_arquivo)

    print("Planilha preenchida com sucesso.\n")
    
    print("Importando VBA...\n")

    importar_modulo_vba(caminho_novo_arquivo, modulos_vba)

    print("VBA importado com sucesso.\n")

    print("Dados preenchidos com sucesso.")
    
    return

main()