import pandas as pd
import pyodbc
import json
import os
import sys

def get_connection_from_file(file_name='conexao_temp.txt'):
    """Lê o arquivo JSON e cria uma conexão com o banco de dados."""
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        file_path = os.path.join(script_dir, '..', file_name)
        
        with open(file_path, 'r') as f:
            config = json.load(f)

        driver = config.get('driver', None)
        server = config.get('server', None)
        database = config.get('database', None)
        username = config.get('username', None)
        password = config.get('password', None)
        trusted_connection = config.get('trusted_connection', None)

        if trusted_connection.lower() == 'yes':
            string_connection = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};Trusted_Connection={trusted_connection}"
        else:
            string_connection = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={username};PWD={password};"

        connection = pyodbc.connect(string_connection)
        cursor = connection.cursor()

        return connection, cursor

    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        sys.exit(1)

if len(sys.argv) > 1:
    caminho_arquivo = os.path.abspath(sys.argv[1]) 
else:
    print("Erro: Nenhum caminho de arquivo foi passado.")
    sys.exit(1)

print(f"Usando o arquivo: {caminho_arquivo}")

connection, cursor = get_connection_from_file('conexao_temp.txt')

try:
    print("Lendo dados do Excel...")
    df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Segmento", skiprows=5, usecols="A")
    df.columns = ['descricao']

    df = df.dropna(subset=['descricao'])

    for _, row in df.iterrows():
        descricao = str(row['descricao'])[:50] if pd.notna(row['descricao']) else "Descrição não informada"

        cursor.execute("SELECT MAX(seg_codigo) FROM tb_segmento")
        resultado = cursor.fetchone()
        maior_sec_codigo = resultado[0] if resultado[0] is not None else 0

        seg_codigo_incrementado = maior_sec_codigo + 1

        cursor.execute("""
            INSERT INTO tb_segmento (seg_codigo, seg_descricao, ram_codigo) VALUES (?, ?, 1)
        """, seg_codigo_incrementado, descricao)

        connection.commit()

        print(f"Segmento '{descricao}' inserida com seg_codigo {seg_codigo_incrementado}.")

    print("\nDados inseridos com sucesso!")

except Exception as e:
    print(f"\nOcorreu um erro: {e}")
    connection.rollback()

finally:
    cursor.close()
    connection.close()
