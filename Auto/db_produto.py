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
    arquivo_path = filedialog.askopenfilename(title="Selecione o arquivo Excel", filetypes=[("Arquivos Excel", "*.xlsx;*.xls;*.xlsm")])
    return arquivo_path

caminho_arquivo = selecionar_arquivo()

if not caminho_arquivo:
    print("Nenhum arquivo selecionado. O programa será encerrado.")
else:
    connection, cursor = get_connection()

    try:
        null_value = None
        df_teste = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Produtos")
        
        df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Produtos", skiprows=6, header=None)
        #pd.set_option('display.max_columns', None)

        #print(f"Total de colunas lidas: {len(df.columns)}")
        
        df.columns = [
            "secao", "especie", "descricao", "descricao_reduzida", "marca", "referencia",
            "cod_original", "comprador", "ativo", "unidade", "classificacao", "origem",
            "venda", "icms", "ipi", "etiqueta", "coluna17", "coluna18", "coluna19", "coluna20",
            "coluna21", "coluna22", "coluna23", "coluna24", "coluna25", "coluna26", "coluna27",
            "coluna28", "coluna29", "coluna30", "coluna31"
        ] + [f"coluna{i}" for i in range(32, len(df.columns) + 1)]

        df = df.dropna(how='all')

        df['secao'] = pd.to_numeric(df['secao'], errors='coerce').fillna(0).astype('int16')
        df['especie'] = pd.to_numeric(df['especie'], errors='coerce').fillna(0).astype('int16')
        df['cod_original'] = pd.to_numeric(df['cod_original'], errors='coerce').fillna(0).astype('int16')
        df['ativo'] = df['ativo'].astype('Int64', errors='ignore').astype('object')
        df['classificacao'] = pd.to_numeric(df['classificacao'], errors='coerce').fillna(0).astype('int16')
        df['venda'] = pd.to_numeric(df['venda'], errors='coerce').fillna(0).astype('int16')
        df['origem'] = pd.to_numeric(df['origem'], errors='coerce').fillna(0).astype('int16')
        df['icms'] = pd.to_numeric(df['icms'], errors='coerce').fillna(0).astype('int16')
        df['ipi'] = pd.to_numeric(df['ipi'], errors='coerce').fillna(0).astype('int16')
        df['coluna25'] = pd.to_numeric(df['coluna25'], errors='coerce').fillna(0).astype('int16')
        df['coluna26'] = pd.to_numeric(df['coluna26'], errors='coerce').fillna(0).astype('int16')
        df['coluna27'] = pd.to_numeric(df['coluna27'], errors='coerce').fillna(0).astype('int16')
        df['coluna28'] = pd.to_numeric(df['coluna28'], errors='coerce').fillna(0).astype('int16')
        df['coluna29'] = pd.to_numeric(df['coluna29'], errors='coerce').fillna(0).astype('int16')
        df['coluna30'] = pd.to_numeric(df['coluna30'], errors='coerce').fillna(0).astype('int16')
        df['coluna31'] = pd.to_numeric(df['coluna31'], errors='coerce').fillna(0).astype('int16')
 
        #print("Dados a serem importados:")
        #print(df.head(200))

        duplicata = 0
        total_itens = len(df)

        for x in range(len(df)):
            secao = int(df.iloc[x, 24]) if not pd.isna(df.iloc[x, 24]) else None
            especie = int(df.iloc[x, 25]) if not pd.isna(df.iloc[x, 25]) else None

            descricao = str(df.iloc[x, 2])[:50] if pd.notna(df.iloc[x, 2]) else None
            descricao_reduzida = str(df.iloc[x, 3])[:50] if pd.notna(df.iloc[x, 3]) else None
            
            marca = int(df.iloc[x, 26]) if not pd.isna(df.iloc[x, 26]) else None

            referencia = str(df.iloc[x, 5]) if pd.notna(df.iloc[x, 5]) else None
            
            if pd.notna(df.iloc[x, 6]):
                cod_original = str(df.iloc[x, 6])
            else:
                cursor.execute("SELECT MAX(prd_codigo_original) FROM tb_produto WHERE sec_codigo = ? and esp_codigo = ?", secao, especie)
                resultado = cursor.fetchone()
                maior_cod_original = resultado[0] if resultado[0] is not None else None
                
                if maior_cod_original is None:
                    cod_original = 1
                else:
                    cod_original = maior_cod_original + 1

            comprador = int(df.iloc[x, 27]) if pd.notna(df.iloc[x, 27]) else None
            ativo = 1
            unidade = str(df.iloc[x, 9]) if pd.notna(df.iloc[x, 9]) else None
            classificacao = int(df.iloc[x, 29]) if not pd.isna(df.iloc[x, 29]) else None
            origem = str(df.iloc[x, 11]) if pd.notna(df.iloc[x, 11]) else None
            venda = float(str(df.iloc[x, 12]).replace(',', '.')) if pd.notna(df.iloc[x, 12]) else None
            icms = float(df.iloc[x, 13]) if pd.notna(df.iloc[x, 13]) else None
            ipi = float(df.iloc[x, 14]) if pd.notna(df.iloc[x, 14]) else None
            etiqueta = int(df.iloc[x, 30]) if pd.notna(df.iloc[x, 30]) else None
            data = datetime.now()
            
            cursor.execute("SELECT MAX(prd_codigo) FROM tb_produto WHERE sec_codigo = ? AND esp_codigo = ?", secao, especie)
            resultado = cursor.fetchone()
            maior_prd_codigo = resultado[0] if resultado[0] is not None else 0
            prd_codigo = maior_prd_codigo + 1

            prd_data_ultima_compra = None
            prd_data_ultima_entrega = None
            prd_custo_medio = 0
            prd_preco_medio = 0
            prd_aliquota_icms = 0
            prd_ultimo_custo = 0
            prd_arquivo_foto = None
            prd_tipo_tributacao = None
            und_codigo = int(df.iloc[x, 28]) if not pd.isna(df.iloc[x, 28]) else None
            usu_codigo_cadastro = None
            sec_codigo_r = None
            esp_codigo_r = None
            prd_permite_comprar = 1
            prd_valor_unidade_conversao = None
            udc_codigo = None
            und_codigo_conversao = None
            prd_iat = None
            prd_ippt = None

            cursor.execute("""
                SELECT COUNT(1)
                FROM tb_produto
                WHERE prd_referencia_fornec = ? AND mar_codigo = ?
            """, referencia, marca)

            produto_existe = cursor.fetchone()[0] > 0

            if produto_existe:
                duplicata += 1

            if not produto_existe:
                parametros = (
                    secao, especie, prd_codigo, descricao, descricao_reduzida, marca, data, unidade,
                    prd_data_ultima_compra if prd_data_ultima_compra else None,
                    prd_data_ultima_entrega if prd_data_ultima_entrega else None,
                    prd_custo_medio, prd_preco_medio, prd_aliquota_icms, cod_original, ativo, prd_ultimo_custo,
                    prd_arquivo_foto, referencia, prd_tipo_tributacao, classificacao, comprador, und_codigo, venda,
                    origem, icms, ipi, etiqueta, usu_codigo_cadastro, sec_codigo_r, esp_codigo_r, prd_permite_comprar,
                    prd_valor_unidade_conversao, udc_codigo, und_codigo_conversao, prd_iat, prd_ippt
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
            
            else:
                print(f"Produto com referência '{referencia}' da marca '{marca}' já existe no banco de dados. Produto não inserido.")

    except Exception as e:
        print(f"Erro ao processar o arquivo: {e}")
    finally:
        cursor.close()
        connection.close()
