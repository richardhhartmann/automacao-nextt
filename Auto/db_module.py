import os
import win32com.client
import pyodbc
import time
import pythoncom
import json
import openpyxl
from openpyxl.drawing.image import Image
from tqdm import tqdm
from datetime import datetime
import sys

DEBUG = False 
caminho_parametros = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'conexao_temp.txt')
caminho_raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def debug_print(message):
    """Exibe mensagens de depuração quando DEBUG está ativado."""
    if DEBUG:
        print(f"[DEBUG] {message}")

def mostrar_barra_progresso(total, descricao):
    """Exibe uma barra de progresso no console."""
    return tqdm(total=total, desc=descricao, unit="step", file=sys.stdout, dynamic_ncols=True)

def carregar_parametros_conexao_arquivo():
    """Carrega os parâmetros de conexão do arquivo 'conexao_temp.txt'."""
    debug_print("Carregando parâmetros de conexão do arquivo...")
    
    if not os.path.exists(caminho_parametros):
        raise FileNotFoundError(f"Arquivo de conexão não encontrado: {caminho_parametros}")

    with open(caminho_parametros, "r") as f:
        return json.load(f)

def obter_nome_empresa():
    """Obtém o nome da empresa do banco de dados."""
    try:
        debug_print("Obtendo nome da empresa...")
        
        with mostrar_barra_progresso(4, "Buscando nome da empresa") as progresso:
            parametros = carregar_parametros_conexao_arquivo()
            progresso.update(1)
            
            string_connection = (
                f"DRIVER={parametros['driver']};"
                f"SERVER={parametros['server']};"
                f"DATABASE={parametros['database']};"
            )
            
            if parametros["trusted_connection"].lower() == "yes":
                string_connection += "Trusted_Connection=yes;"
            else:
                string_connection += f"UID={parametros['username']};PWD={parametros['password']};"
            progresso.update(1)
            
            conexao = pyodbc.connect(string_connection)
            cursor = conexao.cursor()
            cursor.execute("SELECT emp_descricao FROM tb_empresa")
            resultado = cursor.fetchone()
            conexao.close()
            progresso.update(1)
            
            nome_empresa = resultado[0].strip() if resultado else "Desconhecida"
            progresso.update(1)
            
            debug_print(f"Nome da empresa obtido: {nome_empresa}")
            return nome_empresa
            
    except Exception as e:
        print(f"Erro ao buscar o nome da empresa: {e}")
        return "Erro"

def converter_xlsx_para_xlsm(caminho_xlsx, nome_empresa):
    """Converte um arquivo .xlsx para .xlsm, incluindo o nome da empresa e data/hora."""
    if not os.path.exists(caminho_xlsx):
        print(f"Erro: O arquivo {caminho_xlsx} não foi encontrado.")
        return None

    data_formatada = datetime.now().strftime("%d-%m-%Y-%H_%M")
    base_name = os.path.splitext(caminho_xlsx)[0]
    caminho_xlsm = f"{base_name} {nome_empresa} - {data_formatada}.xlsm"
    
    excel = None
    wb = None

    try:
        pythoncom.CoInitialize()
        print(f"Iniciando conversão de {caminho_xlsx} para {caminho_xlsm}")
        
        excel = win32com.client.Dispatch("Excel.Application")
        excel.Visible = False
        excel.DisplayAlerts = False
            
        wb = excel.Workbooks.Open(os.path.abspath(caminho_xlsx))
            
        wb.SaveAs(os.path.abspath(caminho_xlsm), FileFormat=52)
            
        print("Conversão concluída com sucesso!")
        return caminho_xlsm
        
    except Exception as e:
        print(f"Erro ao converter o arquivo: {e}")
        return None
    finally:
        try:
            if wb is not None:
                wb.Close(SaveChanges=False)
            if excel is not None:
                excel.Quit()
        except Exception as e:
            print(f"Erro ao fechar Excel: {e}")
        
        pythoncom.CoUninitialize()
        del wb
        del excel
        time.sleep(1)

def importar_codigo_para_aba(wb, nome_aba, caminho_codigo):
    """Importa um código VBA para uma aba específica da planilha."""
    try:
        debug_print(f"Importando código para aba {nome_aba}...")
        
        with mostrar_barra_progresso(3, f"Importando código para {nome_aba}") as progresso:
            try:
                sheet = wb.Sheets(nome_aba)
            except:
                print(f"A aba '{nome_aba}' não foi encontrada na planilha.")
                return False
            progresso.update(1)
            
            if not os.path.exists(caminho_codigo):
                print(f"Arquivo de código '{caminho_codigo}' não encontrado.")
                return False
            progresso.update(1)
            
            vba_module = wb.VBProject.VBComponents(sheet.CodeName)
            if vba_module.CodeModule.CountOfLines > 0:
                vba_module.CodeModule.DeleteLines(1, vba_module.CodeModule.CountOfLines)

            with open(caminho_codigo, 'r', encoding='utf-8') as f:
                codigo = f.read()
                vba_module.CodeModule.AddFromString(codigo)
            progresso.update(1)
            
        print(f"Código importado com sucesso para a aba '{nome_aba}'")
        return True
        
    except Exception as e:
        print(f"Erro ao importar código para aba '{nome_aba}': {e}")
        return False

def importar_autoexec_para_thisworkbook(workbook, caminho_autoexec):
    """Importa o conteúdo de autoexec.bas para o módulo ThisWorkbook."""
    try:
        debug_print("Importando AutoExec para ThisWorkbook...")
        
        with mostrar_barra_progresso(3, "Importando AutoExec") as progresso:
            if not os.path.exists(caminho_autoexec):
                print(f"Arquivo {caminho_autoexec} não encontrado.")
                return False
            progresso.update(1)
            
            with open(caminho_autoexec, 'r', encoding='utf-8') as f:
                codigo_autoexec = f.read()
            progresso.update(1)
            
            thisworkbook = workbook.VBProject.VBComponents(workbook.CodeName)
            thisworkbook.CodeModule.DeleteLines(1, thisworkbook.CodeModule.CountOfLines)
            thisworkbook.CodeModule.AddFromString(codigo_autoexec)
            progresso.update(1)
            
        print("Código do autoexec.bas importado com sucesso!")
        return True

    except Exception as e:
        print(f"Erro ao importar autoexec.bas: {e}")
        return False

def importar_modulo_vba(caminho_arquivo, modulos_vba, pasta_modulos):
    """Importa módulos VBA para a planilha convertida."""
    debug_print("Iniciando processo de importação de módulos VBA")
    
    nome_empresa = obter_nome_empresa()
    caminho_planilha_xlsm = converter_xlsx_para_xlsm(caminho_arquivo, nome_empresa)

    if not caminho_planilha_xlsm:
        print("Erro ao converter para XLSM, abortando o processo.")
        return

    print("Iniciando importação dos códigos VBA...")
    excel = None
    wb = None

    try:
        pythoncom.CoInitialize()
        
        with mostrar_barra_progresso(10, "Importando módulos VBA") as progresso:
            excel = win32com.client.Dispatch("Excel.Application")
            excel.Visible = False
            excel.DisplayAlerts = False
            
            debug_print(f"Abrindo a planilha: {caminho_planilha_xlsm}")
            wb = excel.Workbooks.Open(os.path.abspath(caminho_planilha_xlsm))
            progresso.update(1)
            
            if wb.VBProject.Protection == 1:
                print("Erro: O projeto VBA está protegido. Remova a proteção antes de importar módulos.")
                return
            progresso.update(1)
            
            mapeamento_abas = {
                "Cadastro de Produtos": "cadastro_de_produtos.bas",
                "Cadastro de Marcas": "cadastro_de_marcas.bas",
                "Cadastro de Segmento": "cadastro_de_segmento.bas",
                "Cadastro de Secao": "cadastro_de_secao.bas",
                "Cadastro de Especie": "cadastro_de_especie.bas",
                "Cadastro de Pedidos": "cadastro_de_pedidos.bas"
            }
            
            for nome_aba, nome_arquivo in mapeamento_abas.items():
                caminho_completo = os.path.join(pasta_modulos, nome_arquivo)
                if os.path.exists(caminho_completo):
                    importar_codigo_para_aba(wb, nome_aba, caminho_completo)
                else:
                    print(f"Aviso: {nome_arquivo} não encontrado para a aba {nome_aba}.")
            progresso.update(2)
            
            for modulo in modulos_vba:
                nome_arquivo = os.path.basename(modulo)
                if nome_arquivo not in mapeamento_abas.values():
                    try:
                        debug_print(f"Importando módulo: {nome_arquivo}")
                        wb.VBProject.VBComponents.Import(modulo)
                        debug_print(f"{nome_arquivo} importado!")
                    except Exception as e:
                        print(f"Erro ao importar {nome_arquivo}: {e}")
            progresso.update(2)
            
            json_converter_path = os.path.join(caminho_raiz, "VBA-JSON-master", "JsonConverter.bas")
            if os.path.exists(json_converter_path):
                try:
                    debug_print(f"Importando JsonConverter.bas de: {json_converter_path}")
                    wb.VBProject.VBComponents.Import(json_converter_path)
                    debug_print("JsonConverter.bas importado com sucesso!")
                except Exception as e:
                    print(f"Erro ao importar JsonConverter.bas: {e}")
            else:
                print(f"AVISO: JsonConverter.bas não encontrado em {json_converter_path}")
            progresso.update(1)
            
            try:
                debug_print("Executando a macro CriarIntervalosNomeados...")
                excel.Application.Run("CriarIntervalosNomeados.CriarIntervalosNomeados")
                debug_print("Macro 'CriarIntervalosNomeados' executada com sucesso!")

                caminho_autoexec = os.path.join(pasta_modulos, "AutoExec.bas")
                if os.path.exists(caminho_autoexec):
                    importar_autoexec_para_thisworkbook(wb, caminho_autoexec)
                else:
                    print("AVISO: AutoExec.bas não encontrado em Module/")
            except Exception as e:
                print(f"Não foi possível executar macros: {e}")

            progresso.update(1)
            
            criar_botoes_e_atribuir_macros(wb)
            progresso.update(1)
            
            adicionar_referencia_vba(os.path.abspath(caminho_planilha_xlsm))
            progresso.update(1)
            
            apagar_arquivo((os.path.abspath(caminho_arquivo)))
            encerrar_processos_excel()
            progresso.update(1)
            
        print("Salvando e fechando a planilha...")
        wb.Save()
        print("Processo concluído com sucesso!")
        
    except Exception as e:
        print(f"Erro durante a importação de módulos: {e}")
    finally:
        try: 
            if wb is not None:
                debug_print("Fechando workbook...")
                wb.Close(SaveChanges=True)
            if excel is not None:
                debug_print("Encerrando Excel...")
                excel.Quit()
        except Exception as e:
            debug_print(f"Erro ao encerrar Excel: {e}")
        
        pythoncom.CoUninitialize()
        del wb
        del excel
        time.sleep(1)

def criar_botoes_e_atribuir_macros(wb):
    """Cria botões nas abas e atribui macros a eles."""
    try:
        debug_print("Criando botões e atribuindo macros...")
        
        with mostrar_barra_progresso(4, "Criando botões") as progresso:
            aba_segmento = wb.Sheets("Cadastro de Segmento")
            aba_secao = wb.Sheets("Cadastro de Secao")
            aba_especie = wb.Sheets("Cadastro de Especie")
            aba_marca = wb.Sheets("Cadastro de Marcas")
            progresso.update(1)
            
            left = aba_segmento.Range("A6").Left
            top = aba_segmento.Range("A6").Top
            largura = aba_segmento.Range("A6").Width  
            altura = aba_segmento.Range("A6").Height  
            botao_segmento = aba_segmento.Shapes.AddFormControl(5, left, top, largura, altura)
            botao_segmento.TextFrame.Characters().Text = "Executar Cadastro"
            botao_segmento.OnAction = "ExecutarCadastroSegmento"
            progresso.update(1)
            
            left = aba_secao.Range("A6").Left
            top = aba_secao.Range("A6").Top
            largura = aba_secao.Range("B6").Left + aba_secao.Range("B6").Width - left
            altura = aba_secao.Range("A6").Height 
            botao_secao = aba_secao.Shapes.AddFormControl(5, left, top, largura, altura)
            botao_secao.TextFrame.Characters().Text = "Executar Cadastro"
            botao_secao.OnAction = "ExecutarCadastroSecao"
            progresso.update(1)
            
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
            progresso.update(1)
            
        print("Botões criados e macros atribuídas com sucesso!")
    except Exception as e:
        print(f"Erro ao criar botões e atribuir macros: {e}")

def adicionar_referencia_vba(caminho_arquivo):
    """Adiciona referências necessárias ao projeto VBA."""
    try:
        debug_print("Adicionando referências VBA...")
        
        excel = None
        wb = None
        
        try:
            pythoncom.CoInitialize()
            
            with mostrar_barra_progresso(3, "Adicionando referências") as progresso:
                excel = win32com.client.Dispatch("Excel.Application")
                excel.Visible = False
                excel.DisplayAlerts = False
                progresso.update(1)
                
                wb = excel.Workbooks.Open(caminho_arquivo)
                progresso.update(1)
                
                vb_proj = wb.VBProject
                vb_proj.References.AddFromFile("C:\\Windows\\System32\\scrrun.dll")
                vb_proj.References.AddFromFile("C:\\Program Files\\Common Files\\System\\ado\\msado20.tlb")
                wb.Save()
                progresso.update(1)
                
            print("Referências adicionadas com sucesso!")
        except Exception as e:
            print(f"Erro ao adicionar referências: {e}")
        finally:
            try:
                if wb is not None:
                    wb.Close(SaveChanges=True)
                if excel is not None:
                    excel.Quit()
            except Exception as e:
                print(f"Erro ao fechar Excel: {e}")
            
            pythoncom.CoUninitialize()
            del wb
            del excel
            time.sleep(1)
            
    except Exception as e:
        print(f"Erro geral ao adicionar referências: {e}")

def apagar_arquivo(caminho_arquivo):
    """Remove o arquivo original após a conversão."""
    try:
        debug_print(f"Tentando apagar arquivo: {caminho_arquivo}")
        
        with mostrar_barra_progresso(2, "Removendo arquivo original") as progresso:
            if os.path.exists(caminho_arquivo):
                progresso.update(1)
                time.sleep(1)
                os.remove(caminho_arquivo)
                progresso.update(1)
                print("Arquivo original apagado com sucesso.")
            else:
                print(f"O arquivo {caminho_arquivo} não foi encontrado para exclusão.")
    except Exception as e:
        print(f"Erro ao excluir o arquivo: {e}")

def encerrar_processos_excel():
    """Mata qualquer processo do Excel que esteja rodando em segundo plano."""
    try:
        debug_print("Encerrando processos do Excel...")
        os.system("taskkill /f /im excel.exe")
        print("Processos do Excel encerrados.")
    except Exception as e:
        print(f"Erro ao encerrar processos do Excel: {e}")