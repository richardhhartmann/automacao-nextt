import pandas as pd
import pyodbc
import tkinter as tk
import os
import json
import sys
import openpyxl
from tkinter import filedialog
from datetime import datetime
from openpyxl.utils import get_column_letter, column_index_from_string

def get_connection_from_file(file_name='conexao_temp.txt'):
    """Lê o arquivo JSON e cria uma conexão com o banco de dados."""
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        file_path = os.path.join(script_dir, file_name)
        
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

def selecionar_arquivo():
    root = tk.Tk()
    root.withdraw()
    arquivo_path = filedialog.askopenfilename(title="Selecione o arquivo Excel", filetypes=[("Arquivos Excel", "*.xlsx;*.xls;*.xlsm")])
    return arquivo_path

def get_colunas_adicionais(ws, linha_cabecalho=3, coluna_inicial='Z'):
    """Retorna todas as colunas adicionais que possuem valores no cabeçalho"""
    colunas = []
    current_col_idx = column_index_from_string(coluna_inicial)

    while True:
        col_letter = get_column_letter(current_col_idx)
        valor = ws[f'{col_letter}{linha_cabecalho}'].value
        if pd.isna(valor):
            break
        colunas.append(col_letter)
        current_col_idx += 1

    return colunas


def cadastrar_produto():
    caminho_arquivo = selecionar_arquivo()
    wb = openpyxl.load_workbook(caminho_arquivo, data_only=True)
    ws = wb["Cadastro de Produtos"]
    if not caminho_arquivo:
        print("Nenhum arquivo selecionado. O programa será encerrado.")
        return
    
    connection, cursor = get_connection_from_file('conexao_temp.txt')

    try:
        df = pd.read_excel(caminho_arquivo, sheet_name="Cadastro de Produtos", skiprows=6, header=None)
        pd.set_option('display.max_columns', None)
        print("Dados lidos do Excel:")
        #print(df)
        
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
        df['etiqueta'] = pd.to_numeric(df['etiqueta'], errors='coerce').fillna(0).astype('int16')
        df['comprador'] = pd.to_numeric(df['comprador'], errors='coerce').fillna(0).astype('int16')
        df['coluna25'] = pd.to_numeric(df['coluna25'], errors='coerce').fillna(0).astype('int16')
        df['coluna26'] = pd.to_numeric(df['coluna26'], errors='coerce').fillna(0).astype('int16')
        df['coluna27'] = pd.to_numeric(df['coluna27'], errors='coerce').fillna(0).astype('int16')
        df['coluna28'] = pd.to_numeric(df['coluna28'], errors='coerce').fillna(0).astype('int16')
        df['coluna29'] = pd.to_numeric(df['coluna29'], errors='coerce').fillna(0).astype('int16')
        df['coluna30'] = pd.to_numeric(df['coluna30'], errors='coerce').fillna(0).astype('int16')
        df['coluna31'] = pd.to_numeric(df['coluna31'], errors='coerce').fillna(0).astype('int16')
        df['coluna54'] = pd.to_numeric(df['coluna54'], errors='coerce').fillna(0).astype('int16')
        df['coluna55'] = pd.to_numeric(df['coluna55'], errors='coerce').fillna(0).astype('int16')
        df['coluna56'] = pd.to_numeric(df['coluna56'], errors='coerce').fillna(0).astype('int16')
        df['coluna57'] = pd.to_numeric(df['coluna57'], errors='coerce').fillna(0).astype('int16')
        df['coluna58'] = pd.to_numeric(df['coluna58'], errors='coerce').fillna(0).astype('int16')
        df['coluna59'] = pd.to_numeric(df['coluna59'], errors='coerce').fillna(0).astype('int16')
        df['coluna60'] = pd.to_numeric(df['coluna60'], errors='coerce').fillna(0).astype('int16')
        df['coluna61'] = pd.to_numeric(df['coluna61'], errors='coerce').fillna(0).astype('int16')
        df['coluna62'] = pd.to_numeric(df['coluna62'], errors='coerce').fillna(0).astype('int16')

        duplicata = 0
        produtos_inseridos = 0
        variacoes_inseridas = 0

        for x in range(len(df)):
            if df.iloc[x, 62] != "OK":
                continue
            
            linha_excel = x + 7

            def trata_valor(valor, tipo=int):
                if pd.isna(valor) or str(valor).strip().upper() in ['#N/D', '#N/A', 'N/D']:
                    return None
                try:
                    return tipo(valor)
                except:
                    return None

            secao = trata_valor(df.iloc[x, 54])
            especie = trata_valor(df.iloc[x, 55])
            descricao = str(df.iloc[x, 2])[:50] if pd.notna(df.iloc[x, 2]) else None
            descricao_reduzida = str(df.iloc[x, 3])[:50] if pd.notna(df.iloc[x, 3]) else None
            marca = trata_valor(df.iloc[x, 56])
            comprador = trata_valor(df.iloc[x, 57])
            und_codigo = trata_valor(df.iloc[x, 58])
            classificacao = trata_valor(df.iloc[x, 59])
            origem = trata_valor(df.iloc[x, 60])
            etiqueta = trata_valor(df.iloc[x, 61])

            referencia = (str(int(df.iloc[x, 5])) if isinstance(df.iloc[x, 5], float) and df.iloc[x, 5].is_integer() else str(df.iloc[x, 5])) if pd.notna(df.iloc[x, 5]) else None

            
            if pd.notna(df.iloc[x, 6]):
                cod_original = str(df.iloc[x, 6])
            else:
                cod_original = ''

            ativo = 1
            venda = float(str(df.iloc[x, 12]).replace(',', '.')) if pd.notna(df.iloc[x, 12]) else None
            icms = float(df.iloc[x, 13]) if pd.notna(df.iloc[x, 13]) else None
            ipi = float(df.iloc[x, 14]) if pd.notna(df.iloc[x, 14]) else None

            ipr_codigo_barra = trata_valor(df.iloc[x, 16])

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
            unidade = None
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

            leitura_dados = [secao, especie, descricao, descricao_reduzida, marca, comprador, und_codigo, classificacao, origem, etiqueta, prd_codigo]
            print(f"Dados: {leitura_dados}")

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

                variacoes_produto = 0

                wb = openpyxl.load_workbook(caminho_arquivo)
                ws = wb["Cadastro de Produtos"]
                colunas_adicionais = get_colunas_adicionais(ws)
                print(f"Colunas adicionais encontradas: {colunas_adicionais}")
                wb.close()

                colunas_adicionais = ['Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF', 'AG', 'AH', 
                'AI', 'AJ', 'AK', 'AL', 'AM', 'AN', 'AO', 'AP', 'AQ', 'AR',
                'AS', 'AT', 'AU', 'AV', 'AW', 'AX', 'AY', 'AZ']

                for idx, col in enumerate(colunas_adicionais, start=3):
                    valor = ws[f'{col}{linha_excel}'].value
                    if pd.notna(valor):
                        try:
                            cursor.execute("""
                                INSERT INTO tb_atributo_produto 
                                (sec_codigo, esp_codigo, prd_codigo, tpa_codigo, apr_descricao, prr_codigo)
                                VALUES (?, ?, ?, ?, ?, NULL)
                            """, secao, especie, prd_codigo, idx, str(valor))
                            print(f"  - Atributo adicional {idx} ({col}{linha_excel}) inserido: {valor}")
                        except pyodbc.IntegrityError as e:
                            print(f"  - Ignorado atributo duplicado: {idx} ({col}{linha_excel})")

                tuplas = [  
                    ('R', 'V'),  
                    ('S', 'W'), 
                    ('T', 'X'),
                    ('U', 'Y') 
                ]

                for i, (col_cor, col_tamanho) in enumerate(tuplas, start=1):
                    cor = ws[f'{col_cor}{linha_excel}'].value
                    tamanho = ws[f'{col_tamanho}{linha_excel}'].value

                    if pd.notna(cor) and pd.notna(tamanho):
                        cursor.execute("""
                            INSERT INTO tb_item_produto 
                            (sec_codigo, esp_codigo, prd_codigo, ipr_codigo, ipr_codigo_barra, ipr_preco_promocional, ipr_gtin)
                            VALUES (?, ?, ?, ?, ?, 0, NULL)
                        """, secao, especie, prd_codigo, i, ipr_codigo_barra)

                        cursor.execute("""
                            INSERT INTO tb_atributo_item_produto 
                            (sec_codigo, esp_codigo, prd_codigo, ipr_codigo,
                            tpa_codigo, aip_descricao, aip_ordem, aip_descricao_fornec)
                            VALUES (?, ?, ?, ?, 1, ?, ?, NULL)
                        """, secao, especie, prd_codigo, i, str(cor), i)

                        cursor.execute("""
                            INSERT INTO tb_atributo_item_produto 
                            (sec_codigo, esp_codigo, prd_codigo, ipr_codigo,
                            tpa_codigo, aip_descricao, aip_ordem, aip_descricao_fornec)
                            VALUES (?, ?, ?, ?, 2, ?, ?, NULL)
                        """, secao, especie, prd_codigo, i, str(tamanho), i)

                        variacoes_produto += 1
                        variacoes_inseridas += 1
                        print(f"  - Variação {i}: Cor='{cor}', Tamanho='{tamanho}'")

                connection.commit()
                produtos_inseridos += 1
                print(f"Código {prd_codigo} inserido com {variacoes_produto} variações")

            else:
                duplicata += 1
                print(f"Produto duplicado (linha {linha_excel}): Referência='{referencia}', Marca='{marca}'")
                
    except Exception as e:
        print(f"Erro durante o processamento: {e}")
        connection.rollback()
    finally:
        cursor.close()
        connection.close()