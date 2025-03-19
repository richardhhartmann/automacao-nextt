import win32com.client
import os
import shutil

def converter_xlsx_para_xlsm(caminho_xlsx):
    caminho_xlsm = caminho_xlsx.replace(".xlsx", ".xlsm")
    
    # Se o arquivo já for .xlsm, não faz nada
    if caminho_xlsx == caminho_xlsm:
        return caminho_xlsm

    excel = win32com.client.Dispatch("Excel.Application")
    excel.Visible = False  # Mantenha invisível enquanto converte

    try:
        print(f"Convertendo {caminho_xlsx} para {caminho_xlsm}...")
        wb = excel.Workbooks.Open(os.path.abspath(caminho_xlsx))
        wb.SaveAs(os.path.abspath(caminho_xlsm), FileFormat=52)  # 52 é o formato XLSM
        wb.Close()
        print("Conversão concluída com sucesso!")
        return caminho_xlsm
    except Exception as e:
        print(f"Erro ao converter o arquivo: {e}")
        return None
    finally:
        excel.Quit()

def importar_modulo_vba(caminho_arquivo, caminho_modulo_vba):
    # Converter para XLSM se necessário
    caminho_planilha_xlsm = converter_xlsx_para_xlsm(caminho_arquivo)
    if not caminho_planilha_xlsm:
        print("Erro ao converter para XLSM, abortando o processo.")
        return

    print("Iniciando importação do módulo VBA...")

    if not os.path.exists(caminho_modulo_vba):
        print(f"Erro: O arquivo do módulo VBA '{caminho_modulo_vba}' não foi encontrado.")
        return

    print("Arquivos encontrados. Abrindo o Excel...")

    excel = win32com.client.Dispatch("Excel.Application")
    excel.Visible = True  # Para visualizar a execução

    try:
        print(f"Abrindo a planilha: {caminho_planilha_xlsm}")
        wb = excel.Workbooks.Open(os.path.abspath(caminho_planilha_xlsm))
        
        print("Verificando acesso ao projeto VBA...")
        if not wb.VBProject.Protection:
            print(f"Importando o módulo VBA: {caminho_modulo_vba}")
            wb.VBProject.VBComponents.Import(os.path.abspath(caminho_modulo_vba))

            print("Módulo importado com sucesso!")

            # Chamar diretamente a macro que você deseja executar
            print("Executando a macro CriarIntervalosNomeadosB...")
            wb.Application.Run("CriarIntervalosNomeadosB")

        else:
            print("Erro: O projeto VBA está protegido. Remova a proteção antes de importar módulos.")

        print("Salvando e fechando a planilha...")
        wb.Save()
        wb.Close()

        # Agora, devemos garantir que o arquivo Cadastros Auto Nextt.xlsx seja apagado
        apagar_arquivo(caminho_arquivo)  # Chama a função para apagar o .xlsx

        print("Processo concluído com sucesso!")
    except Exception as e:
        print(f"Erro ao importar módulo VBA: {e}")
    finally:
        print("Encerrando o Excel...")
        excel.Quit()

def apagar_arquivo(caminho_arquivo):
    # Verifica se o arquivo .xlsx existe e o apaga
    try:
        if os.path.exists(caminho_arquivo):
            print(f"Apagando o arquivo original: {caminho_arquivo}")
            os.remove(caminho_arquivo)
            print("Arquivo original apagado com sucesso.")
        else:
            print(f"O arquivo {caminho_arquivo} não foi encontrado para exclusão.")
    except Exception as e:
        print(f"Erro ao excluir o arquivo: {e}")

# Caminhos para a planilha e o módulo VBA
caminho_arquivo = "Cadastros Auto Nextt.xlsx"  # Arquivo original (xlsx)
caminho_modulo_vba = "CriarIntervalosNomeadosB.bas"

importar_modulo_vba(caminho_arquivo, caminho_modulo_vba)
