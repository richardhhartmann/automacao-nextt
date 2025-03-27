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

print(f"Usando o arquivo: {caminho_arquivo} para cadastrar seções.")

# Conectar ao banco de dados
connection, cursor = get_connection()

try:
    print("Lendo dados do Excel...")
    # Lendo os dados da aba "Cadastro de Seção" e configurando os nomes das colunas
    df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Segmento", skiprows=5, usecols="A")
    df.columns = ['descricao']

    # Removendo linhas onde 'descricao' está vazio
    df = df.dropna(subset=['descricao'])

    for _, row in df.iterrows():
        descricao = str(row['descricao'])[:50] if pd.notna(row['descricao']) else "Descrição não informada"

        # Obtendo o maior código de segmento
        cursor.execute("SELECT MAX(seg_codigo) FROM tb_segmento")
        resultado = cursor.fetchone()
        maior_sec_codigo = resultado[0] if resultado[0] is not None else 0

        seg_codigo_incrementado = maior_sec_codigo + 1

        # Inserindo os dados no banco
        cursor.execute("""
            INSERT INTO tb_segmento (seg_codigo, seg_descricao, ram_codigo) VALUES (?, ?, 1)
        """, seg_codigo_incrementado, descricao)

        connection.commit()

        # Print para indicar que a inserção foi bem-sucedida
        print(f"Segmento '{descricao}' inserida com seg_codigo {seg_codigo_incrementado}.")

    print("\nDados inseridos com sucesso!")

except Exception as e:
    print(f"\nOcorreu um erro: {e}")
    connection.rollback()

finally:
    cursor.close()
    connection.close()
