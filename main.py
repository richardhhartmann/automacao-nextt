import tkinter as tk
import json
import time
import threading
import sys
import os
import pyodbc
from io import StringIO
from tkinter import font, Toplevel
from PIL import Image, ImageTk
from Auto.db_connection import preencher_planilha, dados_necessarios
from Auto.db_module import importar_modulo_vba
from cadastro_produto import cadastrar_produto

caminho_parametros = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'conexao_temp.txt')

def validar_campos():
    """Verifica se os campos obrigatórios estão preenchidos."""
    driver = entry_driver.get().strip()
    server = entry_server.get().strip()
    database = entry_database.get().strip()
    
    if not all([driver, server, database]):
        label_status.config(text="Preencha todos os campos obrigatórios antes de continuar!", fg="red")
        return False
    return True

def exportar_conexao():
    """Exporta a conexão se os campos forem válidos."""
    if not validar_campos():
        return
    
    bloquear_campos(True)

    mostrar_janela_carregamento()
    
    driver = entry_driver.get().strip()
    server = entry_server.get().strip()
    database = entry_database.get().strip()
    username = entry_username.get().strip()
    password = entry_password.get().strip()
    trusted_connection = "yes" if var_trusted_connection.get() else "no"
    
    dados_conexao = {
        "driver": driver,
        "server": server,
        "database": database,
        "username": username,
        "password": password,
        "trusted_connection": trusted_connection
    }
    
    try:
        with open('conexao_temp.txt', 'w') as f:
            json.dump(dados_conexao, f, indent=4)
        
        print("\nConfiguração exportada com sucesso!")  
        label_status.config(text="Configuração salva com sucesso!", fg="green")
        root.after(100, main)
    
    except Exception as e:
        fechar_janela_carregamento()
        print(f"Erro ao salvar conexão: {e}") 
        label_status.config(text=f"Erro ao salvar: {str(e)}", fg="red")

def carregar_parametros_conexao_arquivo():
    """Carrega os parâmetros de conexão do arquivo 'conexao_temp.txt'."""
    if not os.path.exists(caminho_parametros):
        raise FileNotFoundError(f"Arquivo de conexão não encontrado: {caminho_parametros}")

    with open(caminho_parametros, "r") as f:
        return json.load(f)

def obter_nome_empresa():
    """Obtém o nome da empresa do banco de dados usando os parâmetros do arquivo de conexão 'conexao_temp.txt'."""
    try:
        parametros = carregar_parametros_conexao_arquivo()
        
        string_connection = (
            f"DRIVER={parametros['driver']};"
            f"SERVER={parametros['server']};"
            f"DATABASE={parametros['database']};"
        )
        
        if parametros["trusted_connection"].lower() == "yes":
            string_connection += "Trusted_Connection=yes;"
        else:
            string_connection += f"UID={parametros['username']};PWD={parametros['password']};"

        conexao = pyodbc.connect(string_connection)
        cursor = conexao.cursor()
        
        cursor.execute("SELECT emp_descricao FROM tb_empresa")
        resultado = cursor.fetchone()
        conexao.close()

        return resultado[0].strip() if resultado else "Desconhecida"
    except Exception as e:
        print(f"Erro ao buscar o nome da empresa: {e}")
        return "Erro"

nome_empresa = obter_nome_empresa()
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
    "db_ExecutarCadastroMarca.bas",
    "verificar_secao_completa.bas"
]

class OutputRedirector:
    def __init__(self, text_widget):
        self.text_widget = text_widget
    
    def write(self, message):
        self.text_widget.insert(tk.END, message)
        self.text_widget.yview(tk.END)
        
        sys.__stdout__.write(message)
        sys.__stdout__.flush()
        
        loading_window.update()

    def flush(self):
        pass


def atualizar_status(mensagem):
    """Atualiza o texto da label de status com a mensagem passada."""
    label_status.config(text=mensagem)
    root.update() 

def mostrar_janela_carregamento():
    """Cria e exibe a janela de carregamento com animação de texto."""
    global loading_window, label_loading, animando, text_output, output_redirector
    animando = True 
    
    loading_window = Toplevel(root)
    loading_window.title("Processando...")
    loading_window.geometry("400x200")
    loading_window.resizable(False, False)
    
    label_loading = tk.Label(loading_window, text="Processando... Aguarde.", font=("Arial", 12))
    label_loading.pack(pady=10)
    
    text_output = tk.Text(loading_window, width=45, height=6, wrap=tk.WORD, font=("Arial", 10))
    text_output.pack(pady=10)

    output_redirector = OutputRedirector(text_output)
    sys.stdout = output_redirector
    
    threading.Thread(target=atualizar_texto_carregamento).start()

def atualizar_texto_carregamento():
    """Atualiza o texto da janela de carregamento com animação de pontinhos."""
    while animando:
        label_loading.config(text="Extraindo Dados " + nome_empresa + "...")
        time.sleep(0.5)
        loading_window.after(0, loading_window.update) 


def fechar_janela_carregamento():
    """Fecha a janela de carregamento e para a animação."""
    global animando
    animando = False  
    loading_window.destroy()  

def bloquear_campos(bloquear):
    """Bloqueia ou desbloqueia as caixas de entrada.""" 
    state = "disabled" if bloquear else "normal"
    entry_driver.config(state=state)
    entry_server.config(state=state)
    entry_database.config(state=state)
    entry_username.config(state=state)
    entry_password.config(state=state)
    checkbutton_trusted_connection.config(state=state)

def main():
    root.iconify()
    dados = dados_necessarios(caminho_arquivo)
    
    print("Preenchendo planilha...")
    preencher_planilha(dados, caminho_arquivo)
    
    print("Planilha preenchida com sucesso.") 
    importar_modulo_vba(caminho_novo_arquivo, modulos_vba, caminho_novo_arquivo)
    
    print("VBA importado com sucesso.")  
    print("Processo concluído com sucesso.")
    
    fechar_janela_carregamento()

    bloquear_campos(False)

def exportar_conexao():
    
    mostrar_janela_carregamento()
    
    """Função executada quando o botão é pressionado"""
    driver = entry_driver.get().strip()
    server = entry_server.get().strip()
    database = entry_database.get().strip()
    username = entry_username.get().strip()
    password = entry_password.get().strip()
    trusted_connection = "yes" if var_trusted_connection.get() else "no"

    if not all([driver, server, database]):
        label_status.config(text="Preencha todos os campos obrigatórios!", fg="red")
        return

    dados_conexao = {
    "driver": driver,
    "server": server,
    "database": database,
    "username": username,
    "password": password,
    "trusted_connection": trusted_connection
}

    try:
        with open('conexao_temp.txt', 'w') as f:
            json.dump(dados_conexao, f, indent=4)

        print("\nConfiguração exportada com sucesso!")  
        label_status.config(text="Configuração salva com sucesso!", fg="green")

        root.after(100, main)

    except Exception as e:
        fechar_janela_carregamento()
        print(f"Erro ao salvar conexão: {e}") 
        label_status.config(text=f"Erro ao salvar: {str(e)}", fg="red")

def importar():
    if not validar_campos():
        return
    
    root.after(100, lambda: (cadastrar_produto()))

root = tk.Tk()
root.title("Conexão Banco de Dados")
root.geometry("400x450")
root.resizable(False, False)

root.columnconfigure(0, weight=1)
root.columnconfigure(1, weight=1)

image_path = "brand.png"
icon_img = ImageTk.PhotoImage(file="brand-ico.ico")

root.iconphoto(True, icon_img)

try:
    img = Image.open(image_path)
    img = ImageTk.PhotoImage(img)
    label_img = tk.Label(root, image=img)
    label_img.grid(row=0, column=0, columnspan=2, pady=(10, 5), sticky="n")
except Exception as e:
    print(f"Erro ao carregar a imagem: {e}")

custom_font = font.Font(family="Arial", size=12, weight="bold")
label_text = tk.Label(root, text="Cadastro em Lotes Automatizado | Demo", font=custom_font)
label_text.grid(row=1, column=0, columnspan=2, pady=(0, 10), sticky="n")

tk.Label(root, text="Driver:").grid(row=2, column=0, padx=10, pady=5, sticky="e")
entry_driver = tk.Entry(root, width=30)
entry_driver.grid(row=2, column=1, padx=10, pady=5, sticky="w")
entry_driver.insert(0, "SQL Server Native Client 11.0")

tk.Label(root, text="Servidor:").grid(row=3, column=0, padx=10, pady=5, sticky="e")
entry_server = tk.Entry(root, width=30)
entry_server.grid(row=3, column=1, padx=10, pady=5, sticky="w")
entry_server.insert(0, "localhost")

tk.Label(root, text="Banco de Dados:").grid(row=4, column=0, padx=10, pady=5, sticky="e")
entry_database = tk.Entry(root, width=30)
entry_database.grid(row=4, column=1, padx=10, pady=5, sticky="w")
entry_database.insert(0, "NexttLoja")

tk.Label(root, text="Usuário:").grid(row=5, column=0, padx=10, pady=5, sticky="e")
entry_username = tk.Entry(root, width=30)
entry_username.grid(row=5, column=1, padx=10, pady=5, sticky="w")
entry_username.insert(0, "sa")

tk.Label(root, text="Senha:").grid(row=6, column=0, padx=10, pady=5, sticky="e")
entry_password = tk.Entry(root, width=30, show="*")
entry_password.grid(row=6, column=1, padx=10, pady=5, sticky="w")

var_trusted_connection = tk.BooleanVar(value=True)
checkbutton_trusted_connection = tk.Checkbutton(root, text="Certificado do Servidor Confiável", variable=var_trusted_connection)
checkbutton_trusted_connection.grid(row=7, column=0, columnspan=2, pady=10)

frame_buttons = tk.Frame(root)
frame_buttons.grid(row=8, column=0, columnspan=2, pady=15) 

btn_exportar = tk.Button(frame_buttons, text="Exportar Planilha", width=15, height=2, command=exportar_conexao)
btn_exportar.grid(row=0, column=0, padx=10)  

btn_importar = tk.Button(frame_buttons, text="Importar Planilha", width=15, height=2, command=importar)
btn_importar.grid(row=0, column=1, padx=10)  

label_status = tk.Label(root, text="", font=("Arial", 10))
label_status.grid(row=9, column=0, columnspan=2, pady=(10, 0))

root.mainloop()
