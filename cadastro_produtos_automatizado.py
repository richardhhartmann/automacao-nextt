import pandas as pd
import pyodbc
import tkinter as tk
from tkinter import filedialog
from datetime import datetime

def get_connection(driver='SQL Server Native Client 11.0', server='localhost', database='NexttLoja', username='sa', password=None, trusted_connection='yes'):
    string_connection = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection={trusted_connection}"
    connection = pyodbc.connect(string_connection)
    cursor = connection.cursor()
    return connection, cursor

def selecionar_arquivo():
    root = tk.Tk()
    root.withdraw()
    arquivo_path = filedialog.askopenfilename(title="Selecione o arquivo Excel", filetypes=[("Arquivos Excel", "*.xlsx;*.xls")])
    return arquivo_path

caminho_arquivo = selecionar_arquivo()

if not caminho_arquivo:
    print("Nenhum arquivo selecionado. O programa será encerrado.")
else:
    connection, cursor = get_connection()

    try:
        null_value = None
        df_teste = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Produtos")
        df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Produtos", skiprows=5, header=None, usecols="A:P")
        df.columns = ["secao", "especie", "descricao", "descricao_reduzida", "marca", "referencia",
                      "cod_original", "comprador", "ativo", "unidade", "classificacao", "origem",
                      "venda", "icms", "ipi", "etiqueta"]
        df = df.dropna(how='all')

        df['secao'] = df['secao'].astype('Int64', errors='ignore').astype('object')
        df['especie'] = df['especie'].astype('Int64', errors='ignore').astype('object')
        df['cod_original'] = df['cod_original'].astype('Int64', errors='ignore').astype('object')
        df['ativo'] = df['ativo'].astype('Int64', errors='ignore').astype('object')
        df['unidade'] = df['unidade'].astype('Int64', errors='ignore').astype('object')
        df['classificacao'] = df['classificacao'].astype('Int64', errors='ignore').astype('object')
        df['venda'] = df['venda'].astype('float64', errors='ignore').astype('object')
        df['icms'] = df['icms'].astype('float64', errors='ignore').astype('object')
        df['ipi'] = df['ipi'].astype('float64', errors='ignore').astype('object')

        print("Dados a serem importados:")
        print(df.head(10))

        for x in range(len(df)):
            secao = int(df.iloc[x, 0]) if pd.notna(df.iloc[x, 0]) else None
            especie = int(df.iloc[x, 1]) if pd.notna(df.iloc[x, 1]) else None
            descricao = str(df.iloc[x, 2])[:50] if pd.notna(df.iloc[x, 2]) else None
            descricao_reduzida = str(df.iloc[x, 3])[:50] if pd.notna(df.iloc[x, 3]) else None
            marca = str(df.iloc[x, 4]) if pd.notna(df.iloc[x, 4]) else None
            referencia = str(df.iloc[x, 5]) if pd.notna(df.iloc[x, 5]) else None
            cod_original = int(df.iloc[x, 6]) if pd.notna(df.iloc[x, 6]) else None
            comprador = str(df.iloc[x, 7]) if pd.notna(df.iloc[x, 7]) else None
            ativo = int(df.iloc[x, 8]) if pd.notna(df.iloc[x, 8]) else None
            unidade = int(df.iloc[x, 9]) if pd.notna(df.iloc[x, 9]) else None
            classificacao = int(df.iloc[x, 10]) if pd.notna(df.iloc[x, 10]) else None
            origem = str(df.iloc[x, 11]) if pd.notna(df.iloc[x, 11]) else None
            venda = float(df.iloc[x, 12]) if pd.notna(df.iloc[x, 12]) else None
            icms = float(df.iloc[x, 13]) if pd.notna(df.iloc[x, 13]) else None
            ipi = float(df.iloc[x, 14]) if pd.notna(df.iloc[x, 14]) else None
            etiqueta = int(df.iloc[x, 15]) if pd.notna(df.iloc[x, 15]) else None
            data = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            parametros = (
    secao, especie, None, descricao, descricao_reduzida, marca, data, unidade, 
    None, None, 0, 0, 0, None, 1, 0, None, referencia, None, classificacao, 
    None, 9, venda, origem, None, None, None, None, None, None, 1, None, None, 
    None, None, None
)

            cursor.execute("""
                INSERT INTO tb_produto 
                (sec_codigo, esp_codigo, prd_codigo, prd_descricao, prd_descricao_reduzida, 
                mar_codigo, prd_data_cadastro, prd_unidade, prd_data_ultima_compra, 
                prd_data_ultima_entrega, prd_custo_medio, prd_preco_medio, prd_aliquota_icms, 
                prd_codigo_original, prd_ativo, prd_ultimo_custo, prd_arquivo_foto, 
                prd_referencia_fornec, prd_tipo_tributacao, clf_codigo, usu_codigo_comprador, 
                und_codigo, prd_valor_venda, prd_origem, prd_percentual_icms, prd_percentual_ipi, 
                etq_codigo_padrao, usu_codigo_cadastro, sec_codigo_r, esp_codigo_r, 
                prd_permite_comprar, prd_valor_unidade_conversao, udc_codigo, und_codigo_conversao, 
                prd_iat, prd_ippt)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 
                           ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, parametros)

            connection.commit()

        print("Dados inseridos com sucesso!")

    except Exception as e:
        print(f"Erro ao processar o arquivo: {e}")
    finally:
        cursor.close()
        connection.close()