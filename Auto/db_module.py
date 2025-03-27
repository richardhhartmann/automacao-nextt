import win32com.client
import os
import pyodbc
import time

def obter_nome_empresa():
    """ Obtém o nome da empresa do banco de dados. """
    try:
        conexao = pyodbc.connect(
            "DRIVER=SQL Server Native Client 11.0;SERVER=localhost;DATABASE=NexttLoja;UID=sa;PWD=;Trusted_Connection=yes"
        )
        cursor = conexao.cursor()
        cursor.execute("SELECT emp_descricao FROM tb_empresa")
        resultado = cursor.fetchone()
        conexao.close()

        return resultado[0].strip() if resultado else "Desconhecida"
    except Exception as e:
        print(f"Erro ao buscar o nome da empresa: {e}")
        return "Erro"

def converter_xlsx_para_xlsm(caminho_xlsx, nome_empresa):
    """ Converte um arquivo .xlsx para .xlsm, incluindo o nome da empresa no nome do arquivo. """
    if not os.path.exists(caminho_xlsx):
        print(f"Erro: O arquivo {caminho_xlsx} não foi encontrado.")
        return None

    nome_empresa = nome_empresa.replace(" ", "_")
    caminho_xlsm = caminho_xlsx.replace(".xlsx", f" - {nome_empresa}.xlsm")

    try:
        excel = win32com.client.Dispatch("Excel.Application")
        excel.Visible = False  

        print(f"Convertendo {caminho_xlsx} para {caminho_xlsm}...")

        wb = excel.Workbooks.Open(os.path.abspath(caminho_xlsx))
        time.sleep(1) 

        wb.SaveAs(os.path.abspath(caminho_xlsm), FileFormat=52)  
        wb.Close(False)
        
        print("Conversão concluída com sucesso!")
        return caminho_xlsm
    except Exception as e:
        print(f"Erro ao converter o arquivo: {e}")
        return None
    finally:
        excel.Quit()

def importar_codigo_para_aba(wb, nome_aba, caminho_codigo):
    """ Importa um código VBA para uma aba específica da planilha. """
    try:
        try:
            sheet = wb.Sheets(nome_aba)
        except:
            print(f"A aba '{nome_aba}' não foi encontrada na planilha.")
            return False

        if not os.path.exists(caminho_codigo):
            print(f"Arquivo de código '{caminho_codigo}' não encontrado.")
            return False

        vba_module = wb.VBProject.VBComponents(sheet.CodeName)

        if vba_module.CodeModule.CountOfLines > 0:
            vba_module.CodeModule.DeleteLines(1, vba_module.CodeModule.CountOfLines)

        with open(caminho_codigo, 'r', encoding='utf-8') as f:
            codigo = f.read()
            vba_module.CodeModule.AddFromString(codigo)

        print(f"Código importado com sucesso para a aba '{nome_aba}'")
        return True
    except Exception as e:
        print(f"Erro ao importar código para aba '{nome_aba}': {e}")
        return False

def importar_modulo_vba(caminho_arquivo, modulos_vba):
    """ Importa módulos VBA para a planilha convertida. """
    nome_empresa = obter_nome_empresa()
    caminho_planilha_xlsm = converter_xlsx_para_xlsm(caminho_arquivo, nome_empresa)

    if not caminho_planilha_xlsm:
        print("Erro ao converter para XLSM, abortando o processo.")
        return

    print("Iniciando importação dos códigos VBA...")

    try:
        excel = win32com.client.Dispatch("Excel.Application")
        excel.Visible = False  

        print(f"Abrindo a planilha: {caminho_planilha_xlsm}")
        wb = excel.Workbooks.Open(os.path.abspath(caminho_planilha_xlsm))

        if wb.VBProject.Protection == 1:
            print("Erro: O projeto VBA está protegido. Remova a proteção antes de importar módulos.")
            return

        mapeamento_abas = {
            "Cadastro de Produtos": "cadastro_de_produtos.bas",
            "Cadastro de Marcas": "cadastro_de_marcas.bas",
            "Cadastro de Segmento": "cadastro_de_segmento.bas",
            "Cadastro de Seção": "cadastro_de_secao.bas",
            "Cadastro de Espécie": "cadastro_de_especie.bas"
        }

        for nome_aba, nome_arquivo in mapeamento_abas.items():
            if nome_arquivo in modulos_vba:
                caminho_completo = os.path.abspath(nome_arquivo)
                importar_codigo_para_aba(wb, nome_aba, caminho_completo)

        for modulo in modulos_vba:
            if modulo not in mapeamento_abas.values():
                try:
                    print(f"Importando o módulo VBA: {modulo}")
                    wb.VBProject.VBComponents.Import(os.path.abspath(modulo))
                    print(f"Módulo {modulo} importado com sucesso!")
                except Exception as e:
                    print(f"Erro ao importar o módulo {modulo}: {e}")

        try:
            print("Executando a macro CriarIntervalosNomeadosB...")
            excel.Application.Run("CriarIntervalosNomeadosB")
            print("Macro 'CriarIntervalosNomeadosB' executada com sucesso!")
        except Exception as e:
            print(f"Erro ao executar 'CriarIntervalosNomeadosB': {e}")

        print("Criando botões e atribuindo macros...")
        criar_botoes_e_atribuir_macros(wb)

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

import win32com.client

def criar_botoes_e_atribuir_macros(wb):
    """ Cria botões nas abas e atribui macros a eles. """
    try:
        aba_segmento = wb.Sheets("Cadastro de Segmento")
        aba_secao = wb.Sheets("Cadastro de Seção")
        aba_especie = wb.Sheets("Cadastro de Espécie")
        aba_marca = wb.Sheets("Cadastro de Marcas")

        left = aba_segmento.Range("A6").Left
        top = aba_segmento.Range("A6").Top
        largura = aba_segmento.Range("A6").Width  
        altura = aba_segmento.Range("A6").Height  

        botao_segmento = aba_segmento.Shapes.AddFormControl(5, left, top, largura, altura)
        botao_segmento.TextFrame.Characters().Text = "Executar Cadastro"
        botao_segmento.OnAction = "ExecutarCadastroSegmento"

        left = aba_secao.Range("A6").Left
        top = aba_secao.Range("A6").Top
        largura = aba_secao.Range("B6").Left + aba_secao.Range("B6").Width - left
        altura = aba_secao.Range("A6").Height 
        botao_secao = aba_secao.Shapes.AddFormControl(5, left, top, largura, altura)
        botao_secao.TextFrame.Characters().Text = "Executar Cadastro"
        botao_secao.OnAction = "ExecutarCadastroSecao"

        left = aba_especie.Range("A6").Left
        top = aba_especie.Range("A6").Top
        largura = aba_especie.Range("B6").Left + aba_especie.Range("B6").Width - left 
        altura = aba_especie.Range("A6").Height

        botao_especie = aba_especie.Shapes.AddFormControl(5, left, top, largura, altura)
        botao_especie.TextFrame.Characters().Text = "Executar Cadastro"
        botao_especie.OnAction = "ExecutarCadastroEspecie"

        left = aba_marca.Range("A6").Left
        top = aba_marca.Range("A6").Top
        largura = aba_marca.Range("A6").Width  
        altura = aba_marca.Range("A6").Height  

        botao_marca = aba_marca.Shapes.AddFormControl(5, left, top, largura, altura)
        botao_marca.TextFrame.Characters().Text = "Executar Cadastro"
        botao_marca.OnAction = "ExecutarCadastroMarca"

        print("Botões criados e macros atribuídas com sucesso!")

    except Exception as e:
        print(f"Erro ao criar botões e atribuir macros: {e}")

def apagar_arquivo(caminho_arquivo):
    """ Remove o arquivo original após a conversão. """
    try:
        if os.path.exists(caminho_arquivo):
            print(f"Apagando o arquivo original: {caminho_arquivo}")
            os.remove(caminho_arquivo)
            print("Arquivo original apagado com sucesso.")
        else:
            print(f"O arquivo {caminho_arquivo} não foi encontrado para exclusão.")
    except Exception as e:
        print(f"Erro ao excluir o arquivo: {e}")