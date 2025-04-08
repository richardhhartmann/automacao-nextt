import win32com.client
import os
import pyodbc
import time
import pythoncom
import json
import openpyxl
from openpyxl.drawing.image import Image

caminho_parametros = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'conexao_temp.txt')
caminho_raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def adicionar_imagens(caminho_arquivo):
    """ Adiciona as imagens nas células B2 e G10 da aba 'Nextt' """
    try:
        wb = openpyxl.load_workbook(caminho_arquivo)
        aba = wb['Nextt']

        caminho_imagem_brand = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'brand.png')
        caminho_imagem_upload = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'upload.png')

        if not os.path.exists(caminho_imagem_brand):
            print(f"Erro: O arquivo de imagem 'brand.png' não foi encontrado.")
            return
        if not os.path.exists(caminho_imagem_upload):
            print(f"Erro: O arquivo de imagem 'upload.png' não foi encontrado.")
            return

        img_brand = Image(caminho_imagem_brand)
        img_upload = Image(caminho_imagem_upload)

        aba.add_image(img_brand, 'B2')
        aba.add_image(img_upload, 'G10')

        wb.save(caminho_arquivo)
        print("Imagens inseridas com sucesso!")

    except Exception as e:
        print(f"Erro ao adicionar as imagens: {e}")

def carregar_parametros_conexao_arquivo():
    """Carrega os parâmetros de conexão do arquivo 'conexao_temp.txt'."""
    if not os.path.exists(caminho_parametros):
        raise FileNotFoundError(f"Arquivo de conexão não encontrado: {caminho_parametros}")

    with open(caminho_parametros, "r") as f:
        return json.load(f)

def obter_nome_empresa():
    """Obtém o nome da empresa do banco de dados usando os parâmetros do arquivo de conexão 'conexao_temp.txt'."""
    try:
        parametros = carregar_parametros_conexao_arquivo()
        
        string_connection = (
            f"DRIVER={parametros['driver']};"
            f"SERVER={parametros['server']};"
            f"DATABASE={parametros['database']};"
        )
        
        if parametros["trusted_connection"].lower() == "yes":
            string_connection += "Trusted_Connection=yes;"
        else:
            string_connection += f"UID={parametros['username']};PWD={parametros['password']};"

        conexao = pyodbc.connect(string_connection)
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

def importar_autoexec_para_thisworkbook(workbook, caminho_autoexec):
    """Importa o conteúdo de autoexec.bas para o módulo ThisWorkbook (evento Workbook_Open)."""
    try:
        if not os.path.exists(caminho_autoexec):
            print(f"Arquivo {caminho_autoexec} não encontrado.")
            return False

        with open(caminho_autoexec, 'r', encoding='utf-8') as f:
            codigo_autoexec = f.read()

        thisworkbook = workbook.VBProject.VBComponents(workbook.CodeName)
        thisworkbook.CodeModule.DeleteLines(1, thisworkbook.CodeModule.CountOfLines)
        thisworkbook.CodeModule.AddFromString(codigo_autoexec)

        print("Código do autoexec.bas importado com sucesso!")
        return True

    except Exception as e:
        print(f"Erro ao importar autoexec.bas: {e}")
        return False

def importar_modulo_vba(caminho_arquivo, modulos_vba, pasta_modulos):
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
            "Cadastro de Secao": "cadastro_de_secao.bas",
            "Cadastro de Especie": "cadastro_de_especie.bas"
        }

        for nome_aba, nome_arquivo in mapeamento_abas.items():
            caminho_completo = os.path.join(pasta_modulos, nome_arquivo)
            if os.path.exists(caminho_completo):
                importar_codigo_para_aba(wb, nome_aba, caminho_completo)
            else:
                print(f"Aviso: {nome_arquivo} não encontrado para a aba {nome_aba}.")

        for modulo in modulos_vba:
            nome_arquivo = os.path.basename(modulo)
            if nome_arquivo not in mapeamento_abas.values():
                try:
                    print(f"Importando módulo: {nome_arquivo}")
                    wb.VBProject.VBComponents.Import(modulo)
                    print(f"{nome_arquivo} importado!")
                except Exception as e:
                    print(f"Erro ao importar {nome_arquivo}: {e}")

        json_converter_path = os.path.join(caminho_raiz, "VBA-JSON-master", "JsonConverter.bas")
        if os.path.exists(json_converter_path):
            try:
                print(f"Importando JsonConverter.bas de: {json_converter_path}")
                wb.VBProject.VBComponents.Import(json_converter_path)
                print("JsonConverter.bas importado com sucesso!")
            except Exception as e:
                print(f"Erro ao importar JsonConverter.bas: {e}")
        else:
            print(f"AVISO: JsonConverter.bas não encontrado em {json_converter_path}")

        try:
            print("Executando a macro CriarIntervalosNomeadosB...")
            excel.Application.Run("CriarIntervalosNomeadosB")
            print("Macro 'CriarIntervalosNomeadosB' executada com sucesso!")

            print("Executando a macro AplicarValidacaoObrigatoria...")
            excel.Application.Run("AplicarValidacaoObrigatoria.AplicarValidacaoObrigatoria")
            print("Macro 'AplicarValidacaoObrigatoria' executada com sucesso!")

            caminho_autoexec = os.path.join(pasta_modulos, "AutoExec.bas")
            if os.path.exists(caminho_autoexec):
                importar_autoexec_para_thisworkbook(wb, caminho_autoexec)
            else:
                print("AVISO: AutoExec.bas não encontrado em Module/")

        except Exception as e:
            print(f"Erro ao executar as macros: {e}")

        print("Criando botões e atribuindo macros...")
        criar_botoes_e_atribuir_macros(wb)

        adicionar_referencia_vba(os.path.abspath(caminho_planilha_xlsm))
        apagar_arquivo((os.path.abspath(caminho_arquivo)))
        encerrar_processos_excel()

        print("Salvando e fechando a planilha...")
        wb.Save()
        wb.Close()

        print("Processo concluído com sucesso!")
    except Exception as e:
        None
    finally:
        try: 
            if wb is not None:
                print("Encerrando o Excel...")
                wb.Close(SaveChanges=False)
                excel.Quit()
                del excel
                pythoncom.CoUninitialize()
        except Exception as e:
            None
        
        
def criar_botoes_e_atribuir_macros(wb):
    """ Cria botões nas abas e atribui macros a eles. """
    try:
        aba_segmento = wb.Sheets("Cadastro de Segmento")
        aba_secao = wb.Sheets("Cadastro de Secao")
        aba_especie = wb.Sheets("Cadastro de Especie")
        aba_marca = wb.Sheets("Cadastro de Marcas")
        aba_nextt = wb.Sheets("Nextt")

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

        left = aba_nextt.Range("B19").Left
        top = aba_nextt.Range("B19").Top
        largura = aba_nextt.Range("B19").Width + aba_nextt.Range("C19").Width
        altura = aba_nextt.Range("B19").Height  

        botao_reexibir = aba_nextt.Shapes.AddFormControl(5, left, top, largura, altura)
        botao_reexibir.TextFrame.Characters().Text = "Modo operador"
        botao_reexibir.OnAction = "ReexibirAbas.ReexibirAbas"

        print("Botões criados e macros atribuídas com sucesso!")

    except Exception as e:
        print(f"Erro ao criar botões e atribuir macros: {e}")

def adicionar_referencia_vba(caminho_arquivo):

    excel = win32com.client.Dispatch("Excel.Application")
    excel.Visible = False  

    wb = excel.Workbooks.Open(caminho_arquivo)

    vb_proj = wb.VBProject
    vb_proj.References.AddFromFile("C:\\Windows\\System32\\scrrun.dll")

    wb.Save()
    wb.Close()
    excel.Quit()
    print("Referências adicionadas com sucesso!")

def apagar_arquivo(caminho_arquivo):
    """ Remove o arquivo original após a conversão. """
    try:
        if os.path.exists(caminho_arquivo):
            print(f"Apagando o arquivo original: {caminho_arquivo}")
            time.sleep(1)
            os.remove(caminho_arquivo)
            print("Arquivo original apagado com sucesso.")
        else:
            print(f"O arquivo {caminho_arquivo} não foi encontrado para exclusão.")
    except Exception as e:
        print(f"Erro ao excluir o arquivo: {e}")

def encerrar_processos_excel():
    """ Mata qualquer processo do Excel que esteja rodando em segundo plano. """
    try:
        os.system("taskkill /f /im excel.exe")
        print("Processos do Excel encerrados.")
    except Exception as e:
        print(f"Erro ao encerrar processos do Excel: {e}")