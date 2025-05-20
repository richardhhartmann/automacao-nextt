import openpyxl
import tkinter as tk
import json
import time
import threading
import sys
import os
import pyodbc
import shutil
from tkinter import font, Toplevel, ttk, filedialog
from concurrent.futures import ThreadPoolExecutor
from PIL import Image, ImageTk
from Auto.db_connection import preencher_planilha
from Auto.db_module import importar_modulo_vba
from Auto.cadastros_auto_nextt import cadastrar_produto, cadastrar_pedido
from Auto.importacao import importacao_dados

cancelar_evento = threading.Event()
VERSAO = '1.0'
arquivo_excel_selecionado = None
nome_empresa = ""
DEBUG = True

def cancelar_processamento():
    global cancelar_evento
    if messagebox.askyesno("Cancelar", "Tem certeza que deseja cancelar o processo?"):
        cancelar_evento.set()
        fechar_janela_carregamento()
        label_status.config(text="Processo cancelado pelo usuário.", fg="orange")


def baixar_planilha():
    if var_importacao.get():
        origem = os.path.abspath("offline/Cadastros Auto Nextt.xlsm")
        if not os.path.exists(origem):
            label_status.config(text="Arquivo padrão não encontrado!", fg="red")
            return

        destino = filedialog.asksaveasfilename(
            defaultextension=".xlsm",
            filetypes=[("Planilha Excel habilitada para macro", "*.xlsm")],
            initialfile="Cadastros Auto Nextt.xlsm"
        )

        if destino:
            try:
                shutil.copy(origem, destino)
                label_status.config(text="Planilha exportada com sucesso!", fg="green")
            except Exception as e:
                label_status.config(text=f"Erro ao salvar: {e}", fg="red")
                return

        var_importacao.set(False)
        alternar_modo_importacao()
    else:
        label_status.config(text="Modo de importação não está ativado.", fg="orange")


def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)

caminho_parametros = resource_path('conexao_temp.txt')
pasta_modulos = resource_path('Module')

def validar_campos():
    driver = entry_driver.get().strip()
    server = entry_server.get().strip()
    database = entry_database.get().strip()
    
    if not all([driver, server, database]):
        label_status.config(text="Preencha todos os campos obrigatórios antes de continuar!", fg="red")
        return False
    return True

sql_server_drivers = [d for d in pyodbc.drivers() if "SQL Server" in d]
if sql_server_drivers:
    driver_mais_recente = sql_server_drivers[-1]

def exportar_conexao():
    if not validar_campos():
        return
    
    bloquear_campos(True)
    mostrar_janela_carregamento()

    global nome_empresa

    dados_conexao = {
        "driver": driver_mais_recente,
        "server": entry_server.get().strip(),
        "database": entry_database.get().strip(),
        "username": entry_username.get().strip(),
        "password": entry_password.get().strip(),
        "trusted_connection": "yes" if var_trusted_connection.get() else "no"
    }
    
    try:
        with open(caminho_parametros, 'w') as f:
            json.dump(dados_conexao, f, indent=4)
        
        print("\nConfiguração exportada com sucesso!")  
        label_status.config(text="Configuração salva com sucesso!", fg="green")

        nome_empresa = obter_nome_empresa()
        threading.Thread(target=processar_apos_exportacao).start()
    
    except Exception as e:
        fechar_janela_carregamento()
        print(f"Erro ao salvar conexão: {e}") 
        label_status.config(text=f"Erro ao salvar: {str(e)}", fg="red")

def processar_apos_exportacao():
    try:
        main()
    except Exception as e:
        fechar_janela_carregamento()
        label_status.config(text=f"Erro ao ler parâmetros: {str(e)}", fg="red")


def carregar_parametros_conexao_arquivo():
    if not os.path.exists(caminho_parametros):
        raise FileNotFoundError(f"Arquivo de conexão não encontrado: {caminho_parametros}")

    with open(caminho_parametros, "r") as f:
        return json.load(f)

def obter_nome_empresa():
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

if not os.path.exists(pasta_modulos):
    print(f"Erro: A pasta '{pasta_modulos}' não foi encontrada!")
    raise SystemExit("Mensagem de erro detalhada")

modulos_vba = [
    os.path.join(pasta_modulos, arquivo)
    for arquivo in os.listdir(pasta_modulos)
    if arquivo.endswith((".bas", ".frm", ".cls")) and arquivo != "AutoExec.bas"
]

caminho_arquivo = 'Cadastros Auto Nextt limpa.xlsx'
caminho_novo_arquivo = 'Cadastros Auto Nextt.xlsx'

def atualizar_status(mensagem):
    label_status.config(text=mensagem)
    root.update() 

def mostrar_janela_carregamento():
    global loading_window, label_loading, animando, output_redirector, cancelar_evento
    animando = True
    cancelar_evento.clear()

    loading_window = Toplevel(root)
    loading_window.title("Processando...")
    loading_window.geometry("300x200")
    loading_window.resizable(False, False)

    label_loading = tk.Label(loading_window, text="Extraindo Dados...", font=("Arial", 12))
    label_loading.pack(pady=10)

    progress_bar = ttk.Progressbar(
        loading_window, 
        mode='determinate', 
        length=250,
        maximum=100,
        style='green.Horizontal.TProgressbar'  # Estilo opcional para melhor visualização
    )
    progress_bar.pack(pady=(20, 10))

    def animar_progresso():
        if not animando:  # Verifica se a animação deve continuar
            return
            
        valor_atual = progress_bar['value']
        novo_valor = (valor_atual + 2) % 100  # Incrementa e reinicia após 100
        
        progress_bar['value'] = novo_valor
        loading_window.after(50, animar_progresso)  # Ajuste o tempo para velocidade desejada

    # Inicia a animação
    animar_progresso()

    botao_cancelar = ttk.Button(loading_window, text="Cancelar", command=cancelar_processamento)
    botao_cancelar.pack(pady=(5, 10))
    botao_cancelar.config(width=20)

    threading.Thread(target=atualizar_texto_carregamento, daemon=True).start()

def atualizar_texto_carregamento():
    pontos = ""
    while animando and not cancelar_evento.is_set():
        pontos += "."
        if len(pontos) > 3:
            pontos = ""
        texto = f"Extraindo Dados {nome_empresa}{pontos}" if 'nome_empresa' in globals() else f"Extraindo Dados{pontos}"
        label_loading.config(text=texto)
        time.sleep(0.5)

def fechar_janela_carregamento():
    global animando
    animando = False  
    loading_window.destroy()  

def bloquear_campos(bloquear):
    state = "disabled" if bloquear else "normal"
    entry_driver.config(state=state)
    entry_server.config(state=state)
    entry_database.config(state=state)
    entry_username.config(state=state)
    entry_password.config(state=state)
    checkbutton_trusted_connection.config(state=state)

def main():
    root.iconify()
    
    if cancelar_evento.is_set(): return
    print("Preenchendo planilha...")
    preencher_planilha(caminho_arquivo, cancelar_evento)

    if cancelar_evento.is_set(): return
    print("Planilha preenchida com sucesso.")
    importar_modulo_vba(caminho_novo_arquivo, modulos_vba, pasta_modulos)

    if cancelar_evento.is_set(): return
    print("VBA importado com sucesso.")
    print("Processo concluído com sucesso.")
    
    fechar_janela_carregamento()
    bloquear_campos(False)

import threading
from tkinter import Tk, filedialog

def importar():
    """Função principal para importação de dados, otimizada e com melhor tratamento de erros."""
    if not validar_campos():
        return

    # 1. Preparação dos dados de conexão (mais eficiente)
    dados_conexao = {
        "driver": driver_mais_recente,
        "server": entry_server.get().strip(),
        "database": entry_database.get().strip(),
        "username": entry_username.get().strip(),
        "password": entry_password.get().strip(),
        "trusted_connection": "yes" if var_trusted_connection.get() else "no"
    }

    # 2. Salvar parâmetros de conexão de forma segura
    try:
        with open(caminho_parametros, 'w') as f:
            json.dump(dados_conexao, f, indent=4)
    except IOError as e:
        print(f"Erro ao salvar parâmetros de conexão: {e}")
        return

    # 3. Função interna otimizada para execução do cadastro
    def executar_cadastro():
        try:
            # Verificação rápida de cancelamento
            if cancelar_evento.is_set():
                print("Operação cancelada pelo usuário.")
                return
                
            # 4. Seleção de arquivo mais eficiente
            caminho_excel = obter_caminho_excel()
            if not caminho_excel:
                return
            
            # 5. Processamento otimizado do arquivo
            processar_arquivo_excel(caminho_excel)
            
        except Exception as e:
            print(f"Erro durante a execução: {str(e)}")
            if DEBUG:
                import traceback
                traceback.print_exc()

    # 6. Iniciar thread com tratamento de exceções
    iniciar_thread_segura(executar_cadastro)

# Funções auxiliares para modularização
def obter_caminho_excel():
    """Obtém o caminho do arquivo Excel de forma otimizada."""
    root = Tk()
    root.withdraw()
    root.attributes('-topmost', True)
    
    try:
        caminho = filedialog.askopenfilename(
            title="Selecione a planilha Excel",
            filetypes=[("Excel files", "*.xlsx *.xls *.xlsm"), ("All files", "*.*")],
            initialdir=os.path.expanduser("~")  # Começa no diretório do usuário
        )
        return caminho if caminho else None
    finally:
        root.destroy()  # Libera recursos imediatamente

def processar_arquivo_excel(caminho_excel):
    """Processa o arquivo Excel de forma otimizada."""
    global arquivo_excel_selecionado
    arquivo_excel_selecionado = caminho_excel
    print(f"Processando arquivo: {os.path.basename(caminho_excel)}")
    
    try:
        # Verificação rápida de planilhas necessárias
        wb = openpyxl.load_workbook(caminho_excel, data_only=True, read_only=True)
        planilhas = set(wb.sheetnames)
        wb.close()
        
        if not {"Cadastro de Produtos", "Cadastro de Pedidos"}.issubset(planilhas):
            print("Planilhas necessárias não encontradas, executando importação básica...")
            importacao_dados(caminho_excel)
            exportar_conexao()
        else:
            """print("Cadastrando produtos...")
            cadastrar_produto(caminho_excel)
            print("Cadastrando pedidos...")
            cadastrar_pedido(caminho_excel)"""
            print("Iniciando cadastros...")
            with ThreadPoolExecutor(max_workers=2) as executor:
                print("Cadastrando produtos...")
                executor.submit(cadastrar_produto, caminho_excel)
                print("Cadastrando pedidos...")
                executor.submit(cadastrar_pedido, caminho_excel)
                
    except Exception as e:
        print(f"Erro ao processar arquivo Excel: {e}")
        raise

def iniciar_thread_segura(target):
    """Inicia uma thread com tratamento seguro de exceções."""
    def thread_com_excecao():
        try:
            target()
        except Exception as e:
            print(f"Erro não tratado na thread: {e}")
    
    thread = threading.Thread(target=thread_com_excecao, daemon=True)
    thread.start()
    return thread

def preencher_campos_com_parametros_salvos():
    if not os.path.exists(caminho_parametros):
        return

    try:
        with open(caminho_parametros, "r") as f:
            dados = json.load(f)
        
        entry_driver.delete(0, tk.END)
        entry_driver.insert(0, dados.get("driver", ""))

        entry_server.delete(0, tk.END)
        entry_server.insert(0, dados.get("server", ""))
        entry_server.bind("<FocusOut>", atualizar_bancos_disponiveis)

        entry_database.delete(0, tk.END)
        entry_database.insert(0, dados.get("database", ""))

        entry_username.delete(0, tk.END)
        entry_username.insert(0, dados.get("username", ""))

        entry_password.delete(0, tk.END)
        entry_password.insert(0, dados.get("password", ""))

        trusted = dados.get("trusted_connection", "").lower() == "yes"
        var_trusted_connection.set(trusted)

        if dados.get("server") and dados.get("driver"):
            root.after(100, lambda: atualizar_bancos_disponiveis())
            
    except Exception as e:
        print(f"Erro ao carregar dados salvos: {e}")

import tkinter.messagebox as messagebox

def atualizar_bancos_disponiveis(event=None):
    servidor = entry_server.get().strip()
    driver = entry_driver.get().strip()

    if not servidor or not driver:
        return

    trusted = var_trusted_connection.get()
    usuario = entry_username.get().strip()
    senha = entry_password.get().strip()

    try:
        string_conexao = f"DRIVER={driver};SERVER={servidor};"
        if trusted:
            string_conexao += "Trusted_Connection=yes;"
        else:
            string_conexao += f"UID={usuario};PWD={senha};"

        conexao = pyodbc.connect(string_conexao, timeout=3)
        cursor = conexao.cursor()
        cursor.execute("""
            SELECT name 
            FROM sys.databases 
            WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb', 'Nextt.Compras')
            AND state = 0  
            ORDER BY name
        """)
        bancos = [row[0] for row in cursor.fetchall()]
        conexao.close()

        if not bancos:
            messagebox.showerror("Erro", "Nenhum banco de dados disponível para o servidor informado.")
            entry_database['values'] = []
            entry_database.set("Nenhum banco encontrado")
            return

        entry_database['values'] = bancos
        if bancos:
            entry_database.current(0)

        entry_database['values'] = bancos
        entry_database.set(bancos[0] if bancos else "Nenhum banco encontrado")

    except Exception as e:
        print(f"Erro ao buscar bancos: {e}")
        entry_database['values'] = []
        entry_database.set("Erro na conexão")


root = tk.Tk()
root.title("Conexão Banco de Dados")
root.geometry("400x525")
root.resizable(False, False)

root.columnconfigure(0, weight=1)
root.columnconfigure(1, weight=1)

image_path = os.path.join(os.getcwd(), "Public", "brand.png")
icon_path = os.path.join("Public", "brand-ico.ico")
icon_img = ImageTk.PhotoImage(file=icon_path)

root.iconphoto(True, icon_img)

try:
    img = Image.open(image_path)
    img = ImageTk.PhotoImage(img)
    label_img = tk.Label(root, image=img)
    label_img.grid(row=0, column=0, columnspan=2, pady=(10, 5), sticky="n")
except Exception as e:
    print(f"Erro ao carregar a imagem: {e}")

custom_font = font.Font(family="Arial", size=12, weight="bold")
label_text = tk.Label(root, text=f"Cadastro em Lotes Automatizado {VERSAO}", font=custom_font)
label_text.grid(row=1, column=0, columnspan=2, pady=(0, 10), sticky="n")

tk.Label(root, text="Driver:").grid(row=2, column=0, padx=10, pady=5, sticky="e")
entry_driver = tk.Entry(root, width=30)
entry_driver.grid(row=2, column=1, padx=10, pady=5, sticky="w")
entry_driver.insert(0, f"{driver_mais_recente}")

tk.Label(root, text="Servidor:").grid(row=3, column=0, padx=10, pady=5, sticky="e")
entry_server = tk.Entry(root, width=30)
entry_server.grid(row=3, column=1, padx=10, pady=5, sticky="w")

var_importacao = tk.BooleanVar()

def alternar_modo_importacao():
    estado = tk.DISABLED if var_importacao.get() else tk.NORMAL
    for entry in [entry_driver, entry_server, entry_database, entry_username, entry_password]:
        entry.config(state=estado)
    checkbutton_trusted_connection.config(state=estado)
    btn_importar.config(state=estado)

checkbutton_importacao = tk.Checkbutton(
    root, text="Modo Importação (Offline)", variable=var_importacao, command=alternar_modo_importacao
)
checkbutton_importacao.grid(row=10, column=0, columnspan=2, pady=(5, 0))

tk.Label(root, text="Banco de Dados:").grid(row=4, column=0, padx=10, pady=5, sticky="e")
entry_database = ttk.Combobox(root, width=27, state="readonly")
entry_database.grid(row=4, column=1, padx=10, pady=5, sticky="w")
entry_database['values'] = ["(Selecione ou digite o servidor)"]
entry_database.set("Selecione um banco")

tk.Label(root, text="Usuário:").grid(row=5, column=0, padx=10, pady=5, sticky="e")
entry_username = tk.Entry(root, width=30)
entry_username.grid(row=5, column=1, padx=10, pady=5, sticky="w")

tk.Label(root, text="Senha:").grid(row=6, column=0, padx=10, pady=5, sticky="e")
entry_password = tk.Entry(root, width=30, show="*")
entry_password.grid(row=6, column=1, padx=10, pady=5, sticky="w")

var_trusted_connection = tk.BooleanVar(value=True)
preencher_campos_com_parametros_salvos()
checkbutton_trusted_connection = tk.Checkbutton(root, text="Certificado do Servidor Confiável", variable=var_trusted_connection)
checkbutton_trusted_connection.grid(row=7, column=0, columnspan=2, pady=10)

frame_buttons = tk.Frame(root)
frame_buttons.grid(row=8, column=0, columnspan=2, pady=15) 

widgets_em_ordem = [entry_driver, entry_server, entry_database,
                   entry_username, entry_password]

for i, widget in enumerate(widgets_em_ordem):
    widget.grid(row=2+i, column=1, padx=10, pady=5, sticky="w")  # Ajuste os números de linha conforme seu layout
    widget.lift()

entry_driver.focus_set()

def executar_acao():
    if var_importacao.get():
        baixar_planilha()
    else:
        exportar_conexao()

btn_exportar = tk.Button(frame_buttons, text="Baixar Planilha", width=15, height=2, command=executar_acao)
btn_exportar.grid(row=0, column=0, padx=10)  

btn_importar = tk.Button(frame_buttons, text="Importar Planilha", width=15, height=2, command=importar)
btn_importar.grid(row=0, column=1, padx=10)  

label_status = tk.Label(root, text="", font=("Arial", 10))
label_status.grid(row=11, column=0, columnspan=2, pady=(10, 0))

root.mainloop()