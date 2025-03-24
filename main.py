from Auto.db_conn import preencher_planilha, dados_necessarios
from Auto.db_module import importar_modulo_vba
import os

caminho_arquivo = 'Cadastros Auto Nextt limpa.xlsx'
caminho_novo_arquivo = 'Cadastros Auto Nextt.xlsx'
modulos_vba = [r"Module\CriarIntervalosNomeadosB.bas", r"Module\ValidarCamposCadastro.bas"]

if not os.path.exists(caminho_arquivo):
    print(f"Arquivo não encontrado: {caminho_arquivo}")
    exit()

dados = dados_necessarios()

def main():
    preencher_planilha(dados, caminho_arquivo)

    importar_modulo_vba(caminho_novo_arquivo, modulos_vba)

    print("Dados preenchidos com sucesso.")
    
    return

main()