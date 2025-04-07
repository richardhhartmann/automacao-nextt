import pyodbc
import openpyxl

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
    connection = pyodbc.connect(string_connection)
    return connection

# Conectar ao SQL Server
connection = get_connection() 
cursor = connection.cursor()  

# Consultar colunas obrigatórias
cursor.execute("""
    SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'tb_produto' 
    AND IS_NULLABLE = 'NO'
""")

# Obter os nomes das colunas obrigatórias
colunas_obrigatorias = {row.COLUMN_NAME for row in cursor.fetchall()}

# Adicionar manualmente as colunas que devem ser obrigatórias mesmo que não estejam na consulta
colunas_obrigatorias.update(["und_codigo", "clf_codigo", "prd_origem"])

# Mapeamento das colunas do banco para os nomes no Excel
mapeamento_colunas = {
    "sec_codigo": "Seção",
    "esp_codigo": "Espécie",
    "prd_descricao": "Descrição",
    "prd_descricao_reduzida": "Descrição Reduzida",
    "mar_codigo": "Marca",
    "prd_referencia_fornec": "Referência do Fornecedor",
    "prd_codigo_original": "Código Original",
    "usu_codigo_comprador": "Comprador",
    "und_codigo": "Unidade",                 # Unidade sempre obrigatória
    "clf_codigo": "Classificação Fiscal",     # Classificação Fiscal sempre obrigatória
    "prd_origem": "Origem",                   # Origem sempre obrigatória
    "prd_valor_venda": "Valor de Venda",
    "prd_percentual_icms": "% ICMS",
    "prd_percentual_ipi": "% IPI",
    "etq_codigo_padrao": "Etiqueta Padrão"
}

# Abrir o arquivo Excel
caminho_arquivo = "teste.xlsx"
wb = openpyxl.load_workbook(caminho_arquivo)
ws = wb["Cadastro de Produtos"]  # Definir aba correta

# Definir faixa de leitura (Coluna A até Q -> Colunas 1 a 17)
ultima_coluna = 17  # Coluna Q
linha_titulo = 3
linha_obrigatorio = 4

# Percorrer os cabeçalhos da linha 3 (somente até a coluna Q)
for col in range(1, ultima_coluna + 1):
    nome_coluna_excel = ws.cell(row=linha_titulo, column=col).value  # Nome da coluna no Excel

    # Se a célula estiver mesclada, pegar o valor à esquerda
    if nome_coluna_excel is None:
        nome_coluna_excel = ws.cell(row=linha_titulo, column=col - 1).value  

    # Verificar se a coluna está mapeada e é obrigatória
    for col_sql, col_excel in mapeamento_colunas.items():
        if nome_coluna_excel == col_excel and col_sql in colunas_obrigatorias:
            # Simplesmente sobrescreve a célula sem empurrar para baixo
            ws.cell(row=linha_obrigatorio, column=col, value="Obrigatório")

# Salvar as alterações
wb.save(caminho_arquivo)
wb.close()
connection.close()
