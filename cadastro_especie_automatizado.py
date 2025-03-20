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
        df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Espécie", skiprows=5, usecols="A,C")
        df.columns = ['descricao', 'sec_codigo']

        df = df.dropna(subset=['sec_codigo'])

        df['sec_codigo'] = df['sec_codigo'].astype(int)

        for x in range(len(df)):
            descricao = str(df.iloc[x, 0])[:50] if pd.notna(df.iloc[x, 0]) else "Descrição não informada"
            sec_codigo = int(df.iloc[x, 1])

            cursor.execute("SELECT MAX(esp_codigo) FROM tb_especie WHERE sec_codigo = ?", sec_codigo)
            resultado = cursor.fetchone()
            maior_esp_codigo = resultado[0] if resultado[0] is not None else 0

            esp_codigo_incrementado = maior_esp_codigo + 1

            cursor.execute("""
                INSERT INTO tb_especie (sec_codigo, esp_codigo, esp_descricao, esp_granel, esp_aliquota_icms, esp_ativo, usu_codigo_comprador, clf_codigo)
                VALUES (?, ?, ?, 0, NULL, 1, NULL, NULL)
            """, sec_codigo, esp_codigo_incrementado, descricao)

            connection.commit()
            print(f"Espécie '{descricao}' inserida com esp_codigo {esp_codigo_incrementado} na secao {sec_codigo}.")

        print("\nDados inseridos com sucesso!")

    except Exception as e:
        print(f"\nOcorreu um erro: {e}")
        connection.rollback()

    finally:
        cursor.close()
        connection.close()
