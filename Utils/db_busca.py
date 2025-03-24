import pyodbc

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
    connection = pyodbc.connect(string_connection)
    return connection  # Retorna apenas a conexão

def search_in_database(search_term):
    connection = get_connection()  # Obtém a conexão
    cursor = connection.cursor()   # Cria o cursor a partir da conexão

    # Passo 1: Identificar todas as tabelas e colunas
    cursor.execute("""
        SELECT TABLE_NAME, COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_CATALOG = DB_NAME()
        AND DATA_TYPE IN ('char', 'varchar', 'text', 'nchar', 'nvarchar', 'ntext')
    """)
    tables_and_columns = cursor.fetchall()

    # Passo 2 e 3: Construir e executar consultas dinâmicas
    results = []
    for table, column in tables_and_columns:
        query = f"SELECT '{table}' AS TableName, '{column}' AS ColumnName, [{column}] AS Value FROM [{table}] WHERE [{column}] LIKE ?"
        cursor.execute(query, (f'%{search_term}%',))
        rows = cursor.fetchall()
        if rows:
            results.extend(rows)

    # Passo 4: Exibir os resultados
    if results:
        print(f"Resultados encontrados para o termo '{search_term}':")
        for result in results:
            print(f"Tabela: {result.TableName}, Coluna: {result.ColumnName}, Valor: {result.Value}")
    else:
        print(f"Nenhum resultado encontrado para o termo '{search_term}'.")

    cursor.close()
    connection.close()

# Exemplo de uso
search_term = input("Digite o termo que deseja buscar: ")
search_in_database(search_term)