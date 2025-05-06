import pandas as pd
import pyodbc

def carregar_parametros_conexao(caminho_arquivo='conexao_temp.txt'):
    with open(caminho_arquivo, 'r') as f:
        return f.read().strip()

def sincronizar_dados(excel_path):
    try:
        # Conectar ao banco
        conexao_str = carregar_parametros_conexao()
        conn = pyodbc.connect(conexao_str)
        cursor = conn.cursor()

        # Ler planilha
        df = pd.read_excel(excel_path, sheet_name='Dados Consolidados')

        # Filtrar registros pendentes
        pendentes = df[df['Status de Sincronização'].str.upper() == 'PENDENTE']

        for index, row in pendentes.iterrows():
            try:
                # Exemplo de comando INSERT (ajuste os campos conforme o seu modelo)
                cursor.execute("""
                    INSERT INTO tb_produtos (codigo, descricao, marca, referencia, preco, estoque, categoria)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, row['Código'], row['Descrição'], row['Marca'], row['Referência'],
                     row['Preço'], row['Estoque'], row['Categoria'])

                # Marcar como sincronizado no DataFrame
                df.at[index, 'Status de Sincronização'] = 'SINCRONIZADO'

            except Exception as e:
                print(f"Erro ao inserir linha {index}: {e}")
        
        # Salvar alterações na planilha
        with pd.ExcelWriter(excel_path, mode='a', if_sheet_exists='replace') as writer:
            df.to_excel(writer, sheet_name='Dados Consolidados', index=False)

        # Confirmar no banco
        conn.commit()
        print("Sincronização concluída com sucesso.")

    except Exception as erro:
        print(f"Erro geral na sincronização: {erro}")

