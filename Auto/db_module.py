import win32com.client
import os
import pyodbc

def obter_nome_empresa():
    try:
        conexao = pyodbc.connect("DRIVER=SQL Server Native Client 11.0;SERVER=localhost;DATABASE=NexttLoja;UID=sa;PWD=;Trusted_Connection=yes")
        cursor = conexao.cursor()
        cursor.execute("SELECT emp_descricao FROM tb_empresa")
        resultado = cursor.fetchone()
        conexao.close()

        if resultado:
            return resultado[0].strip()
        else:
            return "Desconhecida"
    except Exception as e:
        print(f"Erro ao buscar o nome da empresa: {e}")
        return "Erro"

def converter_xlsx_para_xlsm(caminho_xlsx, nome_empresa):
    nome_empresa = nome_empresa.replace(" ", "_")
    caminho_xlsm = caminho_xlsx.replace(".xlsx", f" - {nome_empresa}.xlsm")
    
    excel = win32com.client.Dispatch("Excel.Application")
    excel.Visible = False  

    try:
        print(f"Convertendo {caminho_xlsx} para {caminho_xlsm}...")
        wb = excel.Workbooks.Open(os.path.abspath(caminho_xlsx))
        wb.SaveAs(os.path.abspath(caminho_xlsm), FileFormat=52)  # 52 = xlsm
        wb.Close()
        print("Conversão concluída com sucesso!")
        return caminho_xlsm
    except Exception as e:
        print(f"Erro ao converter o arquivo: {e}")
        return None
    finally:
        excel.Quit()

def importar_codigo_para_aba(wb, nome_aba, caminho_codigo):
    try:
        # Verificar se a aba existe
        try:
            sheet = wb.Sheets(nome_aba)
        except:
            print(f"A aba '{nome_aba}' não foi encontrada na planilha.")
            return False

        # Verificar se o arquivo de código existe
        if not os.path.exists(caminho_codigo):
            print(f"Arquivo de código '{caminho_codigo}' não encontrado.")
            return False

        # Obter o módulo da planilha
        vba_module = wb.VBProject.VBComponents(sheet.CodeName)
        
        # Limpar código existente (se houver)
        if vba_module.CodeModule.CountOfLines > 0:
            vba_module.CodeModule.DeleteLines(1, vba_module.CodeModule.CountOfLines)
        
        # Importar o novo código
        with open(caminho_codigo, 'r', encoding='utf-8') as f:
            codigo = f.read()
            vba_module.CodeModule.AddFromString(codigo)
        
        print(f"Código importado com sucesso para a aba '{nome_aba}'")
        return True
    except Exception as e:
        print(f"Erro ao importar código para aba '{nome_aba}': {e}")
        return False

def importar_modulo_vba(caminho_arquivo, modulos_vba):
    nome_empresa = obter_nome_empresa()
    caminho_planilha_xlsm = converter_xlsx_para_xlsm(caminho_arquivo, nome_empresa)
    
    if not caminho_planilha_xlsm:
        print("Erro ao converter para XLSM, abortando o processo.")
        return

    print("Iniciando importação dos códigos VBA...")

    excel = win32com.client.Dispatch("Excel.Application")
    excel.Visible = True  

    try:
        print(f"Abrindo a planilha: {caminho_planilha_xlsm}")
        wb = excel.Workbooks.Open(os.path.abspath(caminho_planilha_xlsm))

        print("Verificando acesso ao projeto VBA...")
        
        # Verificação correta da proteção do projeto VBA (1 = protegido)
        if wb.VBProject.Protection == 1:
            print("Erro: O projeto VBA está protegido. Remova a proteção antes de importar módulos.")
            return

        # Mapeamento de abas e seus respectivos códigos
        mapeamento_abas = {
            "Cadastro de Produtos": "cadastro_de_produtos.bas",
            "Cadastro de Marcas": "cadastro_de_marcas.bas",
            "Cadastro de Segmento": "cadastro_de_segmento.bas",
            "Cadastro de Seção": "cadastro_de_secao.bas",
            "Cadastro de Espécie": "cadastro_de_especie.bas"
        }

        # Importar códigos para as abas específicas
        for nome_aba, nome_arquivo in mapeamento_abas.items():
            if nome_arquivo in modulos_vba:
                caminho_completo = os.path.abspath(nome_arquivo)
                importar_codigo_para_aba(wb, nome_aba, caminho_completo)

        # Importar outros módulos que não são específicos de abas
        for modulo in modulos_vba:
            if modulo not in mapeamento_abas.values():
                try:
                    print(f"Importando o módulo VBA: {modulo}")
                    wb.VBProject.VBComponents.Import(os.path.abspath(modulo))
                    print(f"Módulo {modulo} importado com sucesso!")
                except Exception as e:
                    print(f"Erro ao importar o módulo {modulo}: {e}")

        # Executar a macro CriarIntervalosNomeadosB se existir
        try:
            print("Executando a macro CriarIntervalosNomeadosB...")
            excel.Application.Run("CriarIntervalosNomeadosB")
            print("Macro 'CriarIntervalosNomeadosB' executada com sucesso!")
        except Exception as e:
            print(f"Erro ao executar 'CriarIntervalosNomeadosB': {e}")

        print("Salvando e fechando a planilha...")
        wb.Save()
        wb.Close()

        apagar_arquivo(caminho_arquivo)

        print("Processo concluído com sucesso!")
    except Exception as e:
        print(f"Erro durante o processo de importação: {e}")
    finally:
        print("Encerrando o Excel...")
        excel.Quit()

def apagar_arquivo(caminho_arquivo):
    try:
        if os.path.exists(caminho_arquivo):
            print(f"Apagando o arquivo original: {caminho_arquivo}")
            os.remove(caminho_arquivo)
            print("Arquivo original apagado com sucesso.")
        else:
            print(f"O arquivo {caminho_arquivo} não foi encontrado para exclusão.")
    except Exception as e:
        print(f"Erro ao excluir o arquivo: {e}")

