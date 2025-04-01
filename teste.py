import tkinter as tk
import json
from Auto.db_connection import preencher_planilha, dados_necessarios
from Auto.db_module import importar_modulo_vba

caminho_arquivo = 'Cadastros Auto Nextt limpa.xlsx'
caminho_novo_arquivo = 'Cadastros Auto Nextt.xlsx'

modulos_vba = [
    "CriarIntervalosNomeadosB.bas", 
    "cadastro_de_produtos.bas",
    "cadastro_de_marcas.bas",
    "cadastro_de_segmento.bas",
    "cadastro_de_secao.bas",
    "cadastro_de_especie.bas",
    "db_AtualizarDadosConsolidados.bas",
    "db_cadastro_de_especie.bas",
    "db_cadastro_de_secao.bas",
    "db_cadastro_de_segmento.bas",
    "db_cadastro_de_marca.bas",
    "db_ExecutarCadastroEspecie.bas",
    "db_ExecutarCadastroSecao.bas",
    "db_ExecutarCadastroSegmento.bas",
    "db_ExecutarCadastroMarca.bas"
]

def main():
    dados = dados_necessarios()
    
    print("Preenchendo planilha...\n")
    
    preencher_planilha(dados, caminho_arquivo)
    
    print("Planilha preenchida com sucesso.\n")
    
    print("Importando VBA...\n")
    
    importar_modulo_vba(caminho_novo_arquivo, modulos_vba)
    
    print("VBA importado com sucesso.\n")

    print("Processo concluído com sucesso.")

def exportar_conexao():
    """Função executada quando o botão é pressionado"""
    # Coleta os dados dos campos
    driver = entry_driver.get().strip()
    server = entry_server.get().strip()
    database = entry_database.get().strip()
    username = entry_username.get().strip()
    password = entry_password.get().strip()
    trusted_connection = "yes" if var_trusted_connection.get() else "no"

    # Validação dos campos obrigatórios
    if not all([driver, server, database]):
        label_status.config(text="Preencha todos os campos obrigatórios!", fg="red")
        return

    # Cria o dicionário de conexão
    conexao = f'{{\n"driver": "{driver}",\n"server": "{server}",\n"database": "{database}",\n"username": "{username}",\n"password": "{password}",\n"trusted_connection": "{trusted_connection}"\n}}'

    try:
        # Salva o arquivo de conexão
        with open('conexao_temp.txt', 'w') as f:
            json.dump(conexao, f, indent=4)

        print("\nConfiguração exportada com sucesso!")
        label_status.config(text="Configuração salva com sucesso!", fg="green")

        # Executa o processo principal
        main()

    except Exception as e:
        print(f"Erro ao salvar conexão: {e}")
        label_status.config(text=f"Erro ao salvar: {str(e)}", fg="red")

root = tk.Tk()
root.title("Configuração de Conexão")
root.geometry("400x300")
root.resizable(False, False)

tk.Label(root, text="Driver:").grid(row=0, column=0, padx=10, pady=5)
entry_driver = tk.Entry(root)
entry_driver.grid(row=0, column=1, padx=10, pady=5)
entry_driver.insert(0, "SQL Server Native Client 11.0")

tk.Label(root, text="Servidor:").grid(row=1, column=0, padx=10, pady=5)
entry_server = tk.Entry(root)
entry_server.grid(row=1, column=1, padx=10, pady=5)
entry_server.insert(0, "localhost")

tk.Label(root, text="Banco de Dados:").grid(row=2, column=0, padx=10, pady=5)
entry_database = tk.Entry(root)
entry_database.grid(row=2, column=1, padx=10, pady=5)
entry_database.insert(0, "NexttLoja")

tk.Label(root, text="Usuário:").grid(row=3, column=0, padx=10, pady=5)
entry_username = tk.Entry(root)
entry_username.grid(row=3, column=1, padx=10, pady=5)
entry_username.insert(0, "sa")

tk.Label(root, text="Senha:").grid(row=4, column=0, padx=10, pady=5)
entry_password = tk.Entry(root, show="*")
entry_password.grid(row=4, column=1, padx=10, pady=5)

var_trusted_connection = tk.BooleanVar(value=True)
checkbutton_trusted_connection = tk.Checkbutton(root, text="Trusted Connection", variable=var_trusted_connection)
checkbutton_trusted_connection.grid(row=5, column=0, columnspan=2, pady=10)

btn_exportar = tk.Button(root, text="Exportar", command=exportar_conexao)
btn_exportar.grid(row=6, column=0, columnspan=2, pady=10)

label_status = tk.Label(root, text="", fg="red")
label_status.grid(row=7, column=0, columnspan=2)

root.mainloop()