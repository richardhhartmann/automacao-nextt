import pyodbc

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
    connection = pyodbc.connect(string_connection)
    return connection  

def search_in_database(search_term):
    connection = get_connection() 
    cursor = connection.cursor()  

    cursor.execute("""
        SELECT TABLE_NAME, COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_CATALOG = DB_NAME()
        AND DATA_TYPE IN ('char', 'varchar', 'text', 'nchar', 'nvarchar', 'ntext')
    """)
    tables_and_columns = cursor.fetchall()

    results = []
    for table, column in tables_and_columns:
        query = f"SELECT '{table}' AS TableName, '{column}' AS ColumnName, [{column}] AS Value FROM [{table}] WHERE [{column}] LIKE ?"
        cursor.execute(query, (f'%{search_term}%',))
        rows = cursor.fetchall()
        if rows:
            results.extend(rows)

    if results:
        print(f"Resultados encontrados para o termo '{search_term}':")
        for result in results:
            print(f"Tabela: {result.TableName}, Coluna: {result.ColumnName}, Valor: {result.Value}")
    else:
        print(f"Nenhum resultado encontrado para o termo '{search_term}'.")

    cursor.close()
    connection.close()

search_term = input("Digite o termo que deseja buscar: ")
search_in_database(search_term)