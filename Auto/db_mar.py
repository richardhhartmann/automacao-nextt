import pandas as pd
import pyodbc
import os
import sys

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    """Cria e retorna uma conexão com o banco de dados."""
    try:
        string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
        connection = pyodbc.connect(string_connection)
        cursor = connection.cursor()
        return connection, cursor
    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        sys.exit(1)

# Obtém o caminho do arquivo passado pelo VBA
if len(sys.argv) > 1:
    caminho_arquivo = os.path.abspath(sys.argv[1])  # Garante caminho absoluto
else:
    print("Erro: Nenhum caminho de arquivo foi passado.")
    sys.exit(1)

print(f"Usando o arquivo: {caminho_arquivo}")

connection, cursor = get_connection()

try:
    df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Marcas", skiprows=5, usecols="A")

    df.columns = ['descricao']

    df = df.dropna(subset=['descricao'])

    for _, row in df.iterrows():
        descricao = str(row['descricao'])[:50] if pd.notna(row['descricao']) else "Descrição não informada"

        # Obtendo o maior código de segmento
        cursor.execute("SELECT MAX(mar_codigo) FROM tb_marca")
        resultado = cursor.fetchone()
        maior_mar_codigo = resultado[0] if resultado[0] is not None else 0

        mar_codigo_incrementado = maior_mar_codigo + 1

        # Inserindo os dados no banco
        cursor.execute("""
            INSERT INTO tb_marca (mar_codigo, mar_descricao) VALUES (?, ?)
        """, mar_codigo_incrementado, descricao)

        connection.commit()

        # Print para indicar que a inserção foi bem-sucedida
        print(f"Segmento '{descricao}' inserida com seg_codigo {mar_codigo_incrementado}.")

    print("\nDados inseridos com sucesso!")

except Exception as e:
    print(f"\nOcorreu um erro: {e}")
    connection.rollback()

finally:
    cursor.close()
    connection.close()
