import pandas as pd
import pyodbc
import tkinter as tk
from tkinter import filedialog

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
    connection = pyodbc.connect(string_connection)
    cursor = connection.cursor()
    return connection, cursor

def selecionar_arquivo():
    root = tk.Tk()
    root.withdraw()
    arquivo_path = filedialog.askopenfilename(title="Selecione o arquivo Excel", filetypes=[("Arquivos Excel", "*.xlsx;*.xls")])
    return arquivo_path

caminho_arquivo = selecionar_arquivo()

if not caminho_arquivo:
    print("Nenhum arquivo selecionado. O programa será encerrado.")
else:
    connection, cursor = get_connection()

    try:
        null_value = None
        # Carregando a planilha "Cadastro de Produtos" sem skiprows para verificar a linha do cabeçalho
        df_teste = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Produtos")
        print(df_teste.head(10))  # Exibir as primeiras 10 linhas para verificar o cabeçalho real

        # Agora, carregando os dados corretamente, começando a partir da linha 6 e limitando às colunas de A a P
        df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Produtos", skiprows=5, header=None, usecols="A:P")
        # Definindo manualmente os nomes das colunas
        df.columns = ["secao", "especie", "descricao", "descricao_reduzida", "marca", "referencia",
                      "cod_original", "comprador", "ativo", "unidade", "classificacao", "origem",
                      "venda", "icms", "ipi", "etiqueta"]

        # Remover linhas totalmente vazias
        df = df.dropna(how='all')

        print("Dados a serem importados:")
        print(df.head(10))  # Verifique os dados carregados

        for x in range(len(df)):  # Percorrer todas as linhas da planilha
            secao = df.iloc[x, 0]
            especie = df.iloc[x, 1]
            descricao = df.iloc[x, 2]
            descricao_reduzida = df.iloc[x, 3]
            marca = df.iloc[x, 4]
            referencia = df.iloc[x, 5]
            cod_original = df.iloc[x, 6]
            comprador = df.iloc[x, 7]
            ativo = df.iloc[x, 8]
            unidade = df.iloc[x, 9]
            classificacao = df.iloc[x, 10]
            origem = df.iloc[x, 11]
            venda = df.iloc[x, 12]
            icms = df.iloc[x, 13]
            ipi = df.iloc[x, 14]
            etiqueta = df.iloc[x, 15]

            # Apenas processa a linha se houver pelo menos um valor válido
            if pd.notna(secao) or pd.notna(especie) or pd.notna(descricao):
                print(secao, especie, 0, descricao, descricao_reduzida, marca, unidade, null_value, 
                      null_value, 0, 0, 0, cod_original, ativo, 0, null_value, referencia, null_value, 
                      classificacao, comprador, null_value, venda, origem, icms, ipi, etiqueta, null_value, 
                      null_value, 1, null_value, null_value, null_value, null_value, null_value)
            
    except Exception as e:
        print(f"Erro ao processar o arquivo: {e}")
