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

def empresa_nome():
    connection, cursor = get_connection_from_file('conexao_temp.txt')
    cursor.execute("""
        SELECT * FROM tb_empresa
    """)

    empresa = cursor.fetchone()
    cursor.close()
    connection.close()

    return empresa

def search_in_database(search_term):
    connection, cursor = get_connection_from_file('conexao_temp.txt')

    cursor.execute("""
        SELECT TABLE_NAME, COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_CATALOG = DB_NAME()
        AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
    """)

    tables_and_columns = cursor.fetchall()

    results = []
    for table, column in tables_and_columns:
        try:
            query = f"SELECT DISTINCT '{table}' AS TableName, '{column}' AS ColumnName, CAST([{column}] AS NVARCHAR(MAX)) AS Value FROM [{table}] WHERE [{column}] LIKE ?"
            cursor.execute(query, (f'%{search_term}%',))
            rows = cursor.fetchall()
            if rows:
                results.extend(rows)
        except pyodbc.ProgrammingError:
            query = f"SELECT '{table}' AS TableName, '{column}' AS ColumnName, CAST([{column}] AS NVARCHAR(MAX)) AS Value FROM [{table}] WHERE [{column}] LIKE ?"
            cursor.execute(query, (f'%{search_term}%',))
            rows = cursor.fetchall()
            if rows:
                unique_rows = { (row.TableName, row.ColumnName, row.Value) for row in rows }
                results.extend([ type('Row', (), {'TableName': t, 'ColumnName': c, 'Value': v}) 
                               for t, c, v in unique_rows ])

    if results:
        print(f"Resultados encontrados para o termo '{search_term}':")
        for result in results:
            print(f"Tabela: {result.TableName}, Coluna: {result.ColumnName}, Valor: {result.Value}")
    else:
        print(f"Nenhum resultado encontrado para o termo '{search_term}'.")

    cursor.close()
    connection.close()

empresa = empresa_nome()
search_term = input(f"Digite o termo que deseja buscar no banco de dados de {empresa[1]}: ")
search_in_database(search_term)