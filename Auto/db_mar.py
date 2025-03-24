import pandas as pd
import pyodbc
import tkinter as tk
from tkinter import filedialog
from datetime import datetime

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
    connection = pyodbc.connect(string_connection)
    cursor = connection.cursor()
    return connection, cursor

def selecionar_arquivo():
    root = tk.Tk()
    root.withdraw()
    arquivo_path = filedialog.askopenfilename(title="Selecione o arquivo Excel", filetypes=[("Arquivos Excel", "*.xlsx;*.xls;*.xlsm")])
    return arquivo_path

caminho_arquivo = selecionar_arquivo()

if not caminho_arquivo:
    print("Nenhum arquivo selecionado. O programa será encerrado.")
else:
    connection, cursor = get_connection()

    try:
        df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Espécie", skiprows=6, header=None)

        df.columns = [
            "descricao", "coluna2", "secao"
        ]

        df = df.dropna(subset=["secao", "descricao"])

        # Ajuste para garantir que a seção seja lida corretamente da coluna C
        df['secao'] = pd.to_numeric(df['secao'], errors='coerce').fillna(0).astype('int')
        df['descricao'] = df['descricao'].fillna("Descrição não informada").astype(str)

        print("Dados lidos da planilha:")
        print(df.head())  # Mostrando as primeiras linhas para depuração

        for index, row in df.iterrows():
            descricao = row["descricao"]
            secao = row["secao"]

            # Verificar se a seção foi lida corretamente
            if secao == 0:
                print(f"Atenção: Seção da linha {index + 1} não foi lida corretamente como '0'.")
                continue  # Pula para a próxima linha, já que a seção é inválida

            print(f"\nProcessando linha {index + 1} - Descrição: {descricao}, Seção: {secao}")

            # Obtendo o maior esp_codigo para a secao
            cursor.execute("""
                SELECT MAX(esp_codigo) 
                FROM tb_especie 
                WHERE sec_codigo = ?
            """, secao)

            especie = cursor.fetchone()[0]
            if especie is None:  # Caso não exista espécie para essa seção, começamos do código 1
                especie = 1
            else:
                especie += 1  # Incrementamos o código da espécie

            print(f"Espécie calculada para inserção: {especie}")

            # Verificar se a combinação secao e especie já existe
            cursor.execute("""
                SELECT COUNT(1) 
                FROM tb_especie 
                WHERE esp_codigo = ? AND sec_codigo = ?
            """, especie, secao)

            especie_existe = cursor.fetchone()[0] > 0

            if not especie_existe:
                cursor.execute("""
                    INSERT INTO tb_especie (sec_codigo, esp_codigo, esp_descricao, esp_granel, esp_aliquota_icms, esp_ativo)
                    VALUES (?, ?, ?, 0, NULL, 1)
                """, secao, especie, descricao)

                connection.commit()
                print(f"Espécie {descricao} com código {especie} inserida com sucesso!")

            else:
                print(f"Espécie com código {especie} e seção {secao} já existe. Não foi inserida.")

    except Exception as e:
        print(f"Erro ao processar o arquivo: {e}")
    finally:
        cursor.close()
        connection.close()
