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
            return resultado[0].strip()  # Remove espaços extras caso existam
        else:
            return "Desconhecida"
    except Exception as e:
        print(f"Erro ao buscar o nome da empresa: {e}")
        return "Erro"

def converter_xlsx_para_xlsm(caminho_xlsx, nome_empresa):
    nome_empresa = nome_empresa.replace(" ", "_")  # Substituir espaços por underline para evitar erros
    caminho_xlsm = caminho_xlsx.replace(".xlsx", f" - {nome_empresa}.xlsm")
    
    excel = win32com.client.Dispatch("Excel.Application")
    excel.Visible = False  

    try:
        print(f"Convertendo {caminho_xlsx} para {caminho_xlsm}...")
        wb = excel.Workbooks.Open(os.path.abspath(caminho_xlsx))
        wb.SaveAs(os.path.abspath(caminho_xlsm), FileFormat=52)  
        wb.Close()
        print("Conversão concluída com sucesso!")
        return caminho_xlsm
    except Exception as e:
        print(f"Erro ao converter o arquivo: {e}")
        return None
    finally:
        excel.Quit()

def importar_modulo_vba(caminho_arquivo, modulos_vba):
    nome_empresa = obter_nome_empresa()
    caminho_planilha_xlsm = converter_xlsx_para_xlsm(caminho_arquivo, nome_empresa)
    
    if not caminho_planilha_xlsm:
        print("Erro ao converter para XLSM, abortando o processo.")
        return

    print("Iniciando importação dos módulos VBA...")

    for modulo in modulos_vba:
        if not os.path.exists(modulo):
            print(f"Erro: O arquivo do módulo VBA '{modulo}' não foi encontrado.")
            return

    excel = win32com.client.Dispatch("Excel.Application")
    excel.Visible = True  

    try:
        print(f"Abrindo a planilha: {caminho_planilha_xlsm}")
        wb = excel.Workbooks.Open(os.path.abspath(caminho_planilha_xlsm))

        print("Verificando acesso ao projeto VBA...")

        if not wb.VBProject.Protection:
            ws = wb.Sheets("Cadastro de Produtos") 
            vba_module_planilha = wb.VBProject.VBComponents(ws.CodeName) 

            # Caminho completo para o módulo ValidarCamposCadastro.bas na pasta "Module" dentro do repositório
            caminho_modulo_vba = os.path.join(os.getcwd(), "Module", "ValidarCamposCadastro.bas")

            if "ValidarCamposCadastro.bas" in modulos_vba:
                print(f"Importando o módulo VBA 'ValidarCamposCadastro' para a planilha.")
                if os.path.exists(caminho_modulo_vba):
                    vba_module_planilha.CodeModule.AddFromFile(caminho_modulo_vba)
                    print(f"Módulo 'ValidarCamposCadastro' importado com sucesso!")
                    
                    try:
                        print("Executando a macro ValidarCamposCadastro...")
                        wb.Application.Run("ValidarCamposCadastro")  # Executa a macro após importar
                        print("Macro ValidarCamposCadastro executada com sucesso!")
                    except Exception as e:
                        print(f"Erro ao executar a macro ValidarCamposCadastro: {e}")
                else:
                    print(f"Erro: O módulo 'ValidarCamposCadastro.bas' não foi encontrado na pasta 'Module'.")
            
            # Importação de outros módulos VBA
            for modulo in modulos_vba:
                if modulo != "ValidarCamposCadastro.bas": 
                    try:
                        print(f"Importando o módulo VBA: {modulo}")
                        wb.VBProject.VBComponents.Import(os.path.abspath(modulo))  
                        print(f"Módulo {modulo} importado com sucesso!")
                    except Exception as e:
                        print(f"Erro ao importar o módulo {modulo}: {e}")

            print("Módulos importados com sucesso!")

            try:
                print("Executando a macro CriarIntervalosNomeadosB...")
                wb.Application.Run("CriarIntervalosNomeadosB") 
                print("Macro executada com sucesso!")
            except Exception as e:
                print(f"Erro ao executar a macro CriarIntervalosNomeadosB: {e}")
                
        else:
            print("Erro: O projeto VBA está protegido. Remova a proteção antes de importar módulos.")

        print("Salvando e fechando a planilha...")
        wb.Save()
        wb.Close()

        apagar_arquivo(caminho_arquivo)

        print("Processo concluído com sucesso!")
    except Exception as e:
        print(f"Erro ao importar módulos VBA: {e}")
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
