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
    df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Seção", skiprows=5, usecols="A,C")
    df.columns = ['descricao', 'seg_codigo']

    # Removendo linhas onde 'seg_codigo' está vazio
    df = df.dropna(subset=['seg_codigo'])

    # Convertendo 'seg_codigo' para inteiro
    df['seg_codigo'] = df['seg_codigo'].astype(int)

    for _, row in df.iterrows():
        descricao = str(row['descricao'])[:50] if pd.notna(row['descricao']) else "Descrição não informada"
        seg_codigo = int(row['seg_codigo'])

        # Obtendo o maior código de seção
        cursor.execute("SELECT MAX(sec_codigo) FROM tb_secao")
        resultado = cursor.fetchone()
        maior_sec_codigo = resultado[0] if resultado[0] is not None else 0

        sec_codigo_incrementado = maior_sec_codigo + 1

        # Inserindo os dados no banco
        cursor.execute("""
            INSERT INTO tb_secao (sec_codigo, sec_descricao, seg_codigo, sec_permite_item_produto, 
            sec_ativo, usu_codigo_comprador, clf_codigo) values (?, ?, ?, 1, 1, 1, NULL)
        """, sec_codigo_incrementado, descricao, seg_codigo)

        connection.commit()

        # Print para indicar que a inserção foi bem-sucedida
        print(f"Seção '{descricao}' inserida com sec_codigo {sec_codigo_incrementado} no segmento {seg_codigo}.")

    print("\nDados inseridos com sucesso!")

except Exception as e:
    print(f"\nOcorreu um erro: {e}")
    connection.rollback()

finally:
    cursor.close()
    connection.close()
