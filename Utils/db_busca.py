import pyodbc
import json
import os
import sys
from tqdm import tqdm
from collections import defaultdict

def get_connection_from_file(file_name):
    """Lê o arquivo JSON e cria uma conexão com o banco de dados."""
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        file_path = os.path.join(script_dir, '..', file_name)
        
        with open(file_path, 'r') as f:
            config = json.load(f)

        driver = config.get('driver')
        server = config.get('server')
        database = config.get('database')
        username = config.get('username')
        password = config.get('password')
        trusted_connection = config.get('trusted_connection', 'no').lower()

        if trusted_connection == 'yes':
            conn_str = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};Trusted_Connection=yes"
        else:
            conn_str = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={username};PWD={password}"

        conn = pyodbc.connect(conn_str)
        return conn, conn.cursor()

    except Exception as e:
        print(f"\nErro ao conectar ao banco de dados: {e}", file=sys.stderr)
        sys.exit(1)

def empresa_nome():
    """Obtém o nome da empresa de forma mais eficiente."""
    try:
        conn, cursor = get_connection_from_file('conexao_temp.txt')
        cursor.execute("SELECT TOP 1 emp_descricao FROM tb_empresa")
        empresa = cursor.fetchone()
        return empresa[0] if empresa else "Desconhecida"
    finally:
        cursor.close()
        conn.close()

def search_in_database(search_term):
    """Busca otimizada com progress bar e tratamento de erros."""
    conn, cursor = None, None
    try:
        conn, cursor = get_connection_from_file('conexao_temp.txt')
        
        cursor.execute("""
            SELECT TABLE_NAME, COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_CATALOG = DB_NAME()
            AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext')
        """)
        tables_and_columns = cursor.fetchall()
        
        if not tables_and_columns:
            print("\nNenhuma tabela ou coluna válida encontrada.")
            return

        results = defaultdict(list)
        total = len(tables_and_columns)
        
        print(f"\nBuscando em {total} colunas...")
        
        with tqdm(tables_and_columns, unit="col", desc="Progresso") as pbar:
            for table, column in pbar:
                try:
                    query = f"""
                    SELECT TOP 1000 CAST([{column}] AS NVARCHAR(MAX)) AS Value 
                    FROM [{table}] 
                    WHERE [{column}] LIKE ? ESCAPE '\\'
                    """
                    cursor.execute(query, (f'%{search_term}%',))
                    
                    for row in cursor:
                        results[f"{table}.{column}"].append(row.Value)
                        
                except pyodbc.Error as e:
                    pbar.write(f"Erro em {table}.{column}: {str(e)}")
                    continue

        if results:
            print(f"\nResultados para '{search_term}':")
            for location, values in results.items():
                table, column = location.split('.')
                print(f"\nTabela: {table}\nColuna: {column}")
                for i, value in enumerate(values[:5], 1):
                    print(f"  {i}. {value}")
                if len(values) > 5:
                    print(f"  (+ {len(values)-5} resultados adicionais)")
        else:
            print(f"\nNenhum resultado encontrado para '{search_term}'")

    finally:
        if cursor: cursor.close()
        if conn: conn.close()

if __name__ == "__main__":
    empresa = empresa_nome()
    print(f"\nSistema de busca - {empresa}")
    search_term = input("Digite o termo de busca: ").strip()
    
    if not search_term:
        print("Termo de busca não pode ser vazio.")
    else:
        search_in_database(search_term)