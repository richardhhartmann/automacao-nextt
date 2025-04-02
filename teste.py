import openpyxl

def processar_atributos(planilha_path):
    # Carregar a planilha e selecionar a aba "Cadastro de Produtos"
    try:
        wb = openpyxl.load_workbook(planilha_path)
    except FileNotFoundError:
        print(f"Erro: Arquivo '{planilha_path}' não encontrado.")
        return []
    
    # Verificar se a aba existe (com tratamento para diferenças de capitalização)
    nome_aba = None
    for sheetname in wb.sheetnames:
        if sheetname.lower() == "cadastro de produtos":
            nome_aba = sheetname
            break
    
    if not nome_aba:
        print(f"Erro: A aba 'Cadastro de Produtos' não foi encontrada na planilha.")
        return []
    
    ws = wb[nome_aba]
    
    resultados = []
    
    # Processar cada linha do intervalo Q7:X200
    for linha in range(7, 201):  # De 7 até 200
        # Inicializar contador de variações para esta linha
        ipr_codigo = 0
        tuplas_preenchidas = []
        
        # Verificar a primeira tupla obrigatória (Q e U)
        q_val = ws['Q' + str(linha)].value
        u_val = ws['U' + str(linha)].value
        
        if q_val is not None and u_val is not None:
            ipr_codigo = 1
            tupla1 = {
                'linha': linha,
                'tupla': 1,
                'cor': q_val,
                'tamanho': u_val,
                'coluna_cor': 'Q',
                'coluna_tamanho': 'U'
            }
            tuplas_preenchidas.append(tupla1)
            
            # Verificar as tuplas adicionais
            # Tupla 2: R e V
            r_val = ws['R' + str(linha)].value
            v_val = ws['V' + str(linha)].value
            if r_val is not None and v_val is not None:
                ipr_codigo += 1
                tupla2 = {
                    'linha': linha,
                    'tupla': 2,
                    'cor': r_val,
                    'tamanho': v_val,
                    'coluna_cor': 'R',
                    'coluna_tamanho': 'V'
                }
                tuplas_preenchidas.append(tupla2)
                
            # Tupla 3: S e W
            s_val = ws['S' + str(linha)].value
            w_val = ws['W' + str(linha)].value
            if s_val is not None and w_val is not None:
                ipr_codigo += 1
                tupla3 = {
                    'linha': linha,
                    'tupla': 3,
                    'cor': s_val,
                    'tamanho': w_val,
                    'coluna_cor': 'S',
                    'coluna_tamanho': 'W'
                }
                tuplas_preenchidas.append(tupla3)
                
            # Tupla 4: T e X
            t_val = ws['T' + str(linha)].value
            x_val = ws['X' + str(linha)].value
            if t_val is not None and x_val is not None:
                ipr_codigo += 1
                tupla4 = {
                    'linha': linha,
                    'tupla': 4,
                    'cor': t_val,
                    'tamanho': x_val,
                    'coluna_cor': 'T',
                    'coluna_tamanho': 'X'
                }
                tuplas_preenchidas.append(tupla4)
            
            # Gerar os comandos INSERT apenas se houver pelo menos uma tupla válida
            if ipr_codigo > 0:
                inserts = []
                for i in range(1, ipr_codigo + 1):
                    insert_sql = f"""
                    INSERT INTO tb_item_produto (sec_codigo, esp_codigo, prd_codigo, ipr_codigo, ipr_codigo_barra, ipr_preco_promocional, ipr_gtin)
                    VALUES (?, ?, ?, {i}, 0, 0, NULL)
                    """
                    inserts.append(insert_sql)
                
                resultados.append({
                    'linha': linha,
                    'ipr_codigo': ipr_codigo,
                    'inserts': inserts,
                    'tuplas': tuplas_preenchidas
                })
    
    return resultados

def gerar_relatorio(resultados):
    print("\n=== RELATÓRIO DE PROCESSAMENTO ===")
    print(f"Total de linhas com variações: {len(resultados)}")
    
    for resultado in resultados:
        print(f"\nLinha {resultado['linha']}:")
        print(f"- Variações encontradas: {resultado['ipr_codigo']}")
        
        for tupla in resultado['tuplas']:
            print(f"  Tupla {tupla['tupla']}: {tupla['coluna_cor']}={tupla['cor']} (cor) e {tupla['coluna_tamanho']}={tupla['tamanho']} (tamanho)")
        
        print("\n  Comandos INSERT gerados:")
        for i, insert in enumerate(resultado['inserts'], start=1):
            print(f"  {i}. {insert.strip()}")

# Exemplo de uso
if __name__ == "__main__":
    caminho_planilha = "Cadastros Auto Nextt limpa.xlsx"
    
    print(f"Processando arquivo: {caminho_planilha}")
    resultados = processar_atributos(caminho_planilha)
    
    if resultados:
        gerar_relatorio(resultados)
    else:
        print("Nenhuma variação foi encontrada nas linhas processadas.")