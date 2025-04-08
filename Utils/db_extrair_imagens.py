import pyodbc
import json
import os
import sys

def get_connection_from_file(file_name):
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

connection, cursor = get_connection_from_file('conexao_temp.txt')

output_dir = "imagens_extraidas"
os.makedirs(output_dir, exist_ok=True)

cursor.execute("SELECT img_codigo, img_nome, img_data FROM tb_imagem")

for img_codigo, img_nome, img_data in cursor.fetchall():
    if img_data:
        caminho = os.path.join(output_dir, img_nome)
        with open(caminho, "wb") as f:
            f.write(img_data)

print("Imagens salvas com sucesso na pasta:", output_dir)