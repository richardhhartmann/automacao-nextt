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
        df = pd.read_excel(caminho_arquivo)
        df.columns = df.columns.str.strip()

        print("Dados a serem importados:")
        print(df)

        for index, row in df.iterrows():
            marca = row['mar_codigo']

            print(f"Inserindo a marca: {marca}")

            cursor.execute("""INSERT INTO tb_marca (mar_descricao) VALUES (?)""", (marca))

            connection.commit()

        print("Dados inseridos com sucesso!")

    except Exception as e:
        print(f"Erro ao processar o arquivo: {e}")
    finally:
        cursor.close()
        connection.close()
