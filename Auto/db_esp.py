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
    print("Lendo dados do Excel...")
    df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Espécie", skiprows=5, usecols="A,C")
    df.columns = ['descricao', 'sec_codigo']

    # Removendo linhas onde 'sec_codigo' está vazio
    df = df.dropna(subset=['sec_codigo'])

    # Convertendo 'sec_codigo' para inteiro
    df['sec_codigo'] = df['sec_codigo'].astype(int)

    for _, row in df.iterrows():
        descricao = str(row['descricao'])[:50] if pd.notna(row['descricao']) else "Descrição não informada"
        sec_codigo = int(row['sec_codigo'])

        # Obtendo o maior código de espécie dentro da seção
        cursor.execute("SELECT MAX(esp_codigo) FROM tb_especie WHERE sec_codigo = ?", sec_codigo)
        resultado = cursor.fetchone()
        maior_esp_codigo = resultado[0] if resultado[0] is not None else 0

        esp_codigo_incrementado = maior_esp_codigo + 1

        # Inserindo os dados no banco
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
