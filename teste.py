import pyodbc

# Filtra só os drivers relacionados ao SQL Server
sql_server_drivers = [d for d in pyodbc.drivers() if "SQL Server" in d]

# Pega o último da lista (normalmente o mais recente)
if sql_server_drivers:
    driver_mais_recente = sql_server_drivers[-1]
    print(f"Driver selecionado: {driver_mais_recente}")
else:
    print("Nenhum driver SQL Server encontrado.")
