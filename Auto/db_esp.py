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
    df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Especie", skiprows=5, usecols="A,C")
    df.columns = ['descricao', 'sec_codigo']

    df = df.dropna(subset=['sec_codigo'])

    df['sec_codigo'] = df['sec_codigo'].astype(int)

    cursor.execute("SELECT DISTINCT tpa_codigo FROM tb_regra_atributo_especie")
    tpa_codigos = [row[0] for row in cursor.fetchall()]

    for _, row in df.iterrows():
        descricao = str(row['descricao'])[:50] if pd.notna(row['descricao']) else "Descrição não informada"
        sec_codigo = int(row['sec_codigo'])

        cursor.execute("SELECT MAX(esp_codigo) FROM tb_especie WHERE sec_codigo = ?", sec_codigo)
        resultado = cursor.fetchone()
        maior_esp_codigo = resultado[0] if resultado[0] is not None else 0

        esp_codigo_incrementado = maior_esp_codigo + 1

        cursor.execute(""" 
            INSERT INTO tb_especie (sec_codigo, esp_codigo, esp_descricao, esp_granel, esp_aliquota_icms, esp_ativo, usu_codigo_comprador, clf_codigo)
            VALUES (?, ?, ?, 0, NULL, 1, NULL, NULL)
        """, sec_codigo, esp_codigo_incrementado, descricao)

        for tpa_codigo in tpa_codigos:
            cursor.execute("""
                INSERT INTO tb_regra_atributo_especie (sec_codigo, esp_codigo, tpa_codigo) 
                VALUES (?, ?, ?)
            """, (sec_codigo, esp_codigo_incrementado, tpa_codigo))

        connection.commit()
        print(f"Espécie '{descricao}' inserida com esp_codigo {esp_codigo_incrementado} na secao {sec_codigo}.")

    print("\nDados inseridos com sucesso!")

except Exception as e:
    print(f"\nOcorreu um erro: {e}")
    connection.rollback()
finally:
    cursor.close()
    connection.close()
