Attribute VB_Name = "AplicarValidacaoObrigatoria"
Sub AplicarValidacaoObrigatoria()
    Dim ws As Worksheet, wsDados As Worksheet, wsPedido As Worksheet, wsDadosPedido As Worksheet, wsSecao As Worksheet, wsEspecie As Worksheet
    Dim ultimaColuna As Integer, linhaObrigatorio As Integer
    Dim linhaInicioValidacao As Integer, linhaFimValidacao As Integer
    Dim coluna As Integer, col As Long
    Dim intervalo As Range, colLetter As String
    Dim lastRow As Long
    Const senha As String = "nexttsol" ' Definindo a senha como constante
    
    ' Inicio do timer para debug
    Dim startTime As Double
    startTime = Timer
    
    ' Verificar se as planilhas existem antes de continuar
    If Not WorksheetExists("Cadastro de Produtos") Then
        MsgBox "Planilha 'Cadastro de Produtos' nao encontrada!", vbCritical
        Exit Sub
    End If
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    
    ' Verificar se a planilha de dados existe
    If Not WorksheetExists("Dados Consolidados") Then
        MsgBox "Planilha 'Dados Consolidados' nao encontrada!", vbCritical
        Exit Sub
    End If
    Set wsDados = ThisWorkbook.Sheets("Dados Consolidados")
    
    ' Verificar se a planilha de dados de pedido existe
    If Not WorksheetExists("Dados Pedido") Then
        MsgBox "Planilha 'Dados Pedido' nao encontrada!", vbCritical
        Exit Sub
    End If
    Set wsDadosPedido = ThisWorkbook.Sheets("Dados Pedido")
    
    ' Verificar se a planilha de pedidos existe
    If Not WorksheetExists("Cadastro de Pedidos") Then
        MsgBox "Planilha 'Cadastro de Pedidos' nao encontrada!", vbCritical
        Exit Sub
    End If
    Set wsPedido = ThisWorkbook.Sheets("Cadastro de Pedidos")

    ' Verificar se a planilha de cadastro de secao existe
    If Not WorksheetExists("Cadastro de Secao") Then
        MsgBox "Planilha 'Cadastro de Secao' nao encontrada!", vbCritical
        Exit Sub
    End If
    Set wsSecao = ThisWorkbook.Sheets("Cadastro de Secao")
    
    ' Verificar se a planilha de cadastro de especie existe
    If Not WorksheetExists("Cadastro de Especie") Then
        MsgBox "Planilha 'Cadastro de Especie' nao encontrada!", vbCritical
        Exit Sub
    End If
    Set wsEspecie = ThisWorkbook.Sheets("Cadastro de Especie")

    ' ========= DESPROTEGER PLANILHAS =========
    On Error Resume Next ' Caso alguma planilha nao esteja protegida
    ws.Unprotect senha
    wsDados.Unprotect senha
    On Error GoTo ErrorHandler
    
    ' Configuracoes iniciais
    ultimaColuna = 17
    linhaObrigatorio = 4
    linhaInicioValidacao = 7
    linhaFimValidacao = 1007

    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    
    For coluna = 1 To ultimaColuna
        If ws.Cells(linhaObrigatorio, coluna).Value = "Obrigatorio" Then
            Set intervalo = ws.Range(ws.Cells(linhaInicioValidacao, coluna), ws.Cells(linhaFimValidacao, coluna))
            
            ' Validacao simples de campo obrigatorio
            With intervalo.Validation
                .Delete
                .Add Type:=xlValidateCustom, AlertStyle:=xlValidAlertStop, _
                     Formula1:="=LEN(TRIM(A1))>0"
                .IgnoreBlank = False
                .ShowError = True
                .errorTitle = "Campo Obrigatorio"
                .ErrorMessage = "Este campo deve ser preenchido."
            End With
        End If
    Next coluna
    
    ' Validacao de tamanho de texto
    ApplySimpleValidation ws.Range("C7:C1007,D7:D1007,F7:F1007"), _
                         "=LEN(C7)<=50", _
                         "Limite de Caracteres", _
                         "Maximo de 50 caracteres permitidos."

    ApplySimpleValidation ws.Range("G7:G1007"), _
                        "=AND(ISNUMBER(G7),LEN(G7)<=50)", _
                        "Valor invalido", _
                        "Somente numeros com ate 50 digitos sao permitidos."

    ApplySimpleValidation wsPedido.Range("A7:A1007"), _
                        "=AND(ISNUMBER(A7),LEN(A7)<=50)", _
                        "Valor invalido", _
                        "Somente numeros com ate 50 digitos sao permitidos."

    ApplySimpleValidation wsPedido.Range("I7:I1007"), _
                         "=LEN(I7)<=1000", _
                         "Limite de Caracteres", _
                         "Maximo de 1000 caracteres permitidos."
    
    ApplySimpleValidation wsPedido.Range("L7:U1007"), _
                     "=AND(ISNUMBER(L7), LEN(L7)=9, INT(L7)=L7)", _
                     "Codigo invalido", _
                     "O codigo de produto deve conter exatamente 9 digitos e ser um numero inteiro."


    ' Validacao de EAN
    ApplySimpleValidation ws.Range("Q7:Q1007"), _
                         "=AND(ISNUMBER(--Q7),LEN(Q7)<=20,INT(--Q7)=--Q7)", _
                         "EAN Invalido", _
                         "Digite um numero inteiro com ate 20 digitos"
    ws.Range("Q7:Q1007").NumberFormat = "@"
    
    ' Validacao numerica
    ApplySimpleValidation ws.Range("M7:M1007"), _
                         "=AND(ISNUMBER(M7),M7>=1,M7<=99999999)", _
                         "Valor Invalido", _
                         "Digite um valor entre R$ 1 e R$ 99.999.999"
    ws.Range("M7:M1007").NumberFormat = """R$"" #,##0.00"

    ApplySimpleValidation wsPedido.Range("V7:AE1007"), _
                         "=AND(ISNUMBER(V1),V1>=1,V1<=99999999)", _
                         "Valor Invalido", _
                         "Digite um valor entre 1 e 99.999.999"
    ws.Range("V7:AE1007").NumberFormat = """R$"" #,##0.00"
    
    ' Validacao percentual
    ApplySimpleValidation ws.Range("N7:N1007"), _
                        "=AND(ISNUMBER(N7),N7>=0,N7<=100)", _
                        "Valor Invalido", _
                        "Digite um valor entre 0 e 100"

    ApplySimpleValidation ws.Range("O7:O1007"), _
                        "=AND(ISNUMBER(O7),O7>=0,O7<=100)", _
                        "Valor Invalido", _
                        "Digite um valor entre 0 e 100"

    ws.Range("N7:N1007,O7:O1007").NumberFormat = "0.00""%"""
    
    ' Validacao de atributos
    ApplySimpleValidation ws.Range("R7:BB1007"), _
                         "=LEN(R7)<=50", _
                         "Limite de Caracteres", _
                         "Maximo de 50 caracteres permitidos."
    
    ' Validao de fator filial
    ApplySimpleValidation wsPedido.Range("AN7:ZZ7"), _
                        "=AND(ISNUMBER(AN7), AN7=INT(AN7), LEN(AN7)<=5, AN7>=0)", _
                        "Valor inválido", _
                        "Somente numeros inteiros positivos com ate 5 digitos sao permitidos."
    
    
    ' ========= LISTAS SUSPENSAS =========
    
    ' Listas suspensas fixas (com tratamento de erro aprimorado)
    ApplyDropdown ws, wsDados, "A7:A1007", "A1:A100700"
    ApplyDropdown ws, wsDados, "E7:E1007", "E1:E100700"
    ApplyDropdown ws, wsDados, "H7:H1007", "H1:H100700"
    ApplyDropdown ws, wsDados, "J7:J1007", "J1:J100700"
    ApplyDropdown ws, wsDados, "K7:K1007", "K1:K100700"
    ApplyDropdown ws, wsDados, "L7:L1007", "L1:L100700"
    ApplyDropdown ws, wsDados, "P7:P1007", "P1:P100700"
    
    ApplyDropdown wsSecao, wsDados, "B7:B1007", "AR1:AR100700"
    ApplyDropdown wsEspecie, wsDados, "B7:B1007", "AV1:AV100700"
    
    ApplyDropdown wsPedido, wsDadosPedido, "B7:B1007", "B1:B100700"
    ApplyDropdown wsPedido, wsDadosPedido, "C7:C1007", "C1:C100700"
    ApplyOnlyValidation wsPedido, wsDadosPedido, "J7:J1007", "J1:J100700"
    
    ' Listas suspensas dinamicas (colunas Z a BB)
    For col = Columns("Z").Column To Columns("BB").Column
        colLetter = Split(ws.Cells(1, col).Address(True, False), "$")(0)
        
        ' Verifica se a coluna deve ter dropdown (cabecalho nao vazio)
        If Not IsEmpty(ws.Cells(3, col).Value) Then
            ' Encontra a ultima linha preenchida na coluna de dados
            lastRow = wsDados.Cells(wsDados.Rows.Count, col).End(xlUp).Row
            
            ' Verifica se ha dados suficientes para criar dropdown
            If lastRow > 2 Then
                Dim dropdownRange As String
                dropdownRange = colLetter & "1:" & colLetter & (lastRow - 2)
                
                ' Aplica o dropdown apenas se houver dados
                If WorksheetFunction.CountA(wsDados.Range(dropdownRange)) > 0 Then
                    ApplyDropdown ws, wsDados, colLetter & "7:" & colLetter & "1007", dropdownRange
                End If
            End If
        End If
    Next col
    
    ' ========= REPROTEGER PLANILHAS =========
    On Error Resume Next ' Caso a protecao falhe por algum motivo
    ws.Protect password:=senha, DrawingObjects:=True, Contents:=True, Scenarios:=True
    On Error GoTo 0
    
    ' Restaurar configuracoes do Excel
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.EnableEvents = True
    
    Exit Sub
    
ErrorHandler:
    ' Tentar reproteger as planilhas mesmo em caso de erro
    On Error Resume Next
    ws.Protect password:=senha
    On Error GoTo 0
    
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.EnableEvents = True
    
    MsgBox "Ocorreu um erro: " & Err.Description & vbCrLf & _
           "Na linha: " & Erl, vbCritical
End Sub

Function WorksheetExists(sheetName As String) As Boolean
    On Error Resume Next
    WorksheetExists = (ThisWorkbook.Sheets(sheetName).Name <> "")
    On Error GoTo 0
End Function

Sub ApplySimpleValidation(rng As Range, validationFormula As String, _
                         errorTitle As String, ErrorMessage As String)
    If rng Is Nothing Then Exit Sub
    
    On Error Resume Next
    With rng.Validation
        .Delete
        .Add Type:=xlValidateCustom, AlertStyle:=xlValidAlertStop, _
             Formula1:=validationFormula
        If Err.Number = 0 Then
            .IgnoreBlank = True
            .ShowError = True
            .errorTitle = errorTitle
            .ErrorMessage = ErrorMessage
        Else
            Err.Clear
        End If
    End With
    On Error GoTo 0
End Sub

Sub ApplyDropdown(wsDestino As Worksheet, wsOrigem As Worksheet, _
                 destino As String, origem As String)
    Dim rngDest As Range, rngOrig As Range
    Dim listFormula As String
    
    On Error Resume Next
    Set rngDest = wsDestino.Range(destino)
    Set rngOrig = wsOrigem.Range(origem)
    
    If rngDest Is Nothing Or rngOrig Is Nothing Then
        Debug.Print "Intervalo invalido. Destino: " & destino & ", Origem: " & origem
        Exit Sub
    End If
    
    ' Verificar se o intervalo de origem tem dados
    If WorksheetFunction.CountA(rngOrig) = 0 Then
        Debug.Print "Intervalo de origem vazio: " & rngOrig.Address
        Exit Sub
    End If
    
    ' Criar formula da lista (versao simplificada)
    listFormula = "=" & rngOrig.Address(External:=True)
    
    With rngDest.Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Formula1:=listFormula
        If Err.Number = 0 Then
            .IgnoreBlank = True
            .ShowError = True
            .errorTitle = "Selecao Necessaria"
            .ErrorMessage = "Por favor, selecione um valor da lista."
            Debug.Print "  Dropdown aplicado com sucesso em " & rngDest.Address
        Else
            Debug.Print "  ERRO ao criar lista em " & rngDest.Address & ": " & Err.Description
            Err.Clear
        End If
    End With
    On Error GoTo 0
End Sub

Sub ApplyOnlyValidation(wsDestino As Worksheet, wsOrigem As Worksheet, _
                 destino As String, origem As String)
    Dim rngDest As Range, rngOrig As Range
    Dim listFormula As String
    
    On Error Resume Next
    Set rngDest = wsDestino.Range(destino)
    Set rngOrig = wsOrigem.Range(origem)
    
    If rngDest Is Nothing Or rngOrig Is Nothing Then
        Debug.Print "Intervalo invalido. Destino: " & destino & ", Origem: " & origem
        Exit Sub
    End If
    
    ' Verificar se o intervalo de origem tem dados
    If WorksheetFunction.CountA(rngOrig) = 0 Then
        Debug.Print "Intervalo de origem vazio: " & rngOrig.Address
        Exit Sub
    End If
    
    ' Criar formula da lista (versao simplificada)
    listFormula = "=" & rngOrig.Address(External:=True)
    
    With rngDest.Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Formula1:=listFormula
        If Err.Number = 0 Then
            .IgnoreBlank = True
            .ShowError = True
            .errorTitle = "Selecao Necessaria"
            .ErrorMessage = "Por favor, selecione um valor da lista."
            .InCellDropdown = False
            Debug.Print "  Dropdown aplicado com sucesso em " & rngDest.Address
        Else
            Debug.Print "  ERRO ao criar lista em " & rngDest.Address & ": " & Err.Description
            Err.Clear
        End If
    End With
    On Error GoTo 0
End Sub

Sub VerificarEDefinirDropDowns()
    Dim conn As Object, rs As Object
    Dim sqlF As String, sqlH As String, sqlK As String
    Dim wsPedido As Worksheet, wsDados As Worksheet
    Dim conexaoStr As String, linha As String
    Dim arq As Integer, caminhoArquivo As String

    Set wsPedido = ThisWorkbook.Sheets("Cadastro de Pedidos")
    Set wsDados = ThisWorkbook.Sheets("Dados Pedido")

    ' Caminho do arquivo com os parâmetros de conexao
    caminhoArquivo = ThisWorkbook.Path & "\conexao_temp.txt"
    Dim jsonTexto As String
    Dim driver As String, server As String, database As String
    Dim username As String, password As String, trusted As String

    arq = FreeFile
    Open caminhoArquivo For Input As #arq
    Do Until EOF(arq)
        Line Input #arq, linha
        jsonTexto = jsonTexto & linha
    Loop
    Close #arq

    ' Extrair dados manualmente (simples e rapido para esse caso fixo)
    driver = ExtrairJSON(jsonTexto, "driver")
    server = ExtrairJSON(jsonTexto, "server")
    database = ExtrairJSON(jsonTexto, "database")
    username = ExtrairJSON(jsonTexto, "username")
    password = ExtrairJSON(jsonTexto, "password")
    trusted = ExtrairJSON(jsonTexto, "trusted_connection")

    ' Montar a string de conexao
    If LCase(trusted) = "yes" Then
        conexaoStr = "Driver={" & driver & "};Server=" & server & ";Database=" & database & ";Trusted_Connection=Yes;"
    Else
        conexaoStr = "Driver={" & driver & "};Server=" & server & ";Database=" & database & ";UID=" & username & ";PWD=" & password & ";"
    End If

    ' Define as consultas específicas
    sqlF = "SELECT TOP 1 * FROM tb_condicao_pagamento ORDER BY cpg_descricao ASC"   ' Para coluna F
    sqlH = "SELECT TOP 1 * FROM tb_condicao_pagamento ORDER BY cpg_descricao ASC"   ' Para coluna H
    sqlK = "SELECT TOP 1 * FROM tb_atributo_pedido ORDER BY apd_descricao ASC"      ' Para coluna K

    Set conn = CreateObject("ADODB.Connection")
    Set rs = CreateObject("ADODB.Recordset")

    On Error GoTo Erro
    conn.Open conexaoStr

        ' Verifica dados para coluna F
    rs.Open sqlF, conn
    If Not rs.EOF Then
        ApplyDropdown wsPedido, wsDados, "F7:F1007", "F1:F100700"
        ' Remove bloqueio e formatacao se existir
        With wsPedido.Range("F7:F1007")
            .Locked = False
            .Interior.Pattern = xlNone
            .Borders.LineStyle = xlNone
        End With
    Else
        wsPedido.Columns("F:F").EntireColumn.Hidden = True
        With wsPedido.Range("F7:F1007")
            .Locked = True
            .Interior.Color = RGB(217, 217, 217)  ' #D9D9D9 em RGB
            .Borders.Color = RGB(191, 191, 191)
            .Borders.Weight = xlThin
            .Borders.LineStyle = xlContinuous
            .Validation.Delete
        End With
        With wsPedido.Range("F5")
            .Value = "Nenhuma condicao disponivel para esta coluna."
        End With
    End If
    rs.Close

    ' Verifica dados para coluna H
    rs.Open sqlH, conn
    If Not rs.EOF Then
        ApplyDropdown wsPedido, wsDados, "H7:H1007", "H1:H100700"
        With wsPedido.Range("H7:H1007")
            .Locked = False
            .Interior.Pattern = xlNone
            .Borders.LineStyle = xlNone
        End With
    Else
        wsPedido.Columns("H:H").EntireColumn.Hidden = True
        With wsPedido.Range("H7:H1007")
            .Locked = True
            .Interior.Color = RGB(217, 217, 217)
            .Borders.Color = RGB(191, 191, 191)
            .Borders.Weight = xlThin
            .Borders.LineStyle = xlContinuous
            .Validation.Delete
        End With
        With wsPedido.Range("H5")
            .Value = "Nenhuma condicao disponivel para esta coluna."
        End With
    End If
    rs.Close

    ' Verifica dados para coluna K
    rs.Open sqlK, conn
    If Not rs.EOF Then
        ApplyDropdown wsPedido, wsDados, "K7:K1007", "K1:K100700"
        With wsPedido.Range("K7:K1007")
            .Locked = False
            .Interior.Pattern = xlNone
            .Borders.LineStyle = xlNone
        End With
    Else
        wsPedido.Columns("K:K").EntireColumn.Hidden = True
        With wsPedido.Range("K7:K1007")
            .Locked = True
            .Interior.Color = RGB(217, 217, 217)
            .Borders.Color = RGB(191, 191, 191)
            .Borders.Weight = xlThin
            .Borders.LineStyle = xlContinuous
            .Validation.Delete
        End With
        With wsPedido.Range("K5")
            .Value = "Nenhuma condicao disponivel para esta coluna."
        End With
    End If
    rs.Close

    conn.Close
    Set rs = Nothing
    Set conn = Nothing

    Exit Sub

Erro:
    MsgBox "Erro ao executar a verificacao de dados: " & Err.Description, vbCritical
    On Error Resume Next
    If Not rs Is Nothing Then If rs.State = 1 Then rs.Close
    If Not conn Is Nothing Then If conn.State = 1 Then conn.Close
    ' Garante que a planilha seja protegida mesmo em caso de erro
End Sub

Function ExtrairJSON(json As String, chave As String) As String
    Dim padrao As String
    padrao = """" & chave & """" & "\s*:\s*""([^""]*)"""
    With CreateObject("VBScript.RegExp")
        .Global = False
        .IgnoreCase = True
        .Pattern = padrao
        If .test(json) Then
            ExtrairJSON = .Execute(json)(0).SubMatches(0)
        Else
            ExtrairJSON = ""
        End If
    End With
End Function