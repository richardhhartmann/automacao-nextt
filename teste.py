import pyodbc

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
    connection = pyodbc.connect(string_connection)
    cursor = connection.cursor()
    return connection, cursor

connection, cursor = get_connection()

cursor.execute('SELECT * FROM dbo.tb_campo')
rows = cursor.fetchmany(10)

if rows:
    column_names = [column[0] for column in cursor.description]
    
for i, row in enumerate(rows, start=1):
    row_dict = dict(zip(column_names, row))
    
    print(f'{i}, {row_dict}\n')

