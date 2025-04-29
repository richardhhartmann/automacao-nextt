Attribute VB_Name = "AplicarValidacaoObrigatoria"
Sub AplicarValidacaoObrigatoria()
    Dim ws As Worksheet, wsDados As Worksheet, wsPedido As Worksheet, wsDadosPedido As Worksheet
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
    
    ' ========= VALIDACA•ES BASICAS =========
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

    ' ========= VALIDACA•ES ESPECIFICAS =========
    
    ' Validacao de tamanho de texto
    ApplySimpleValidation ws.Range("C7:C1007,D7:D1007,F7:F1007,G7:G1007"), _
                         "=LEN(C7)<=50", _
                         "Limite de Caracteres", _
                         "Maximo de 50 caracteres permitidos."

    ApplySimpleValidation wsPedido.Range("A7:A1007"), _
                         "=LEN(A7)<=50", _
                         "Limite de Caracteres", _
                         "Maximo de 50 caracteres permitidos."

    ApplySimpleValidation wsPedido.Range("I7:I1007"), _
                         "=LEN(I7)<=1000", _
                         "Limite de Caracteres", _
                         "Maximo de 1000 caracteres permitidos."
    
    ApplySimpleValidation wsPedido.Range("L7:U1007"), _
                         "=LEN(L7)<=9", _
                         "Limite de Caracteres", _
                         "Maximo de 9 caracteres permitidos."

    ' Validacao de EAN
    ApplySimpleValidation ws.Range("Q7:Q1007"), _
                         "=AND(ISNUMBER(--A1),LEN(A1)<=20,INT(--A1)=--A1)", _
                         "EAN Invalido", _
                         "Digite um numero inteiro com ate 20 digitos"
    ws.Range("Q7:Q1007").NumberFormat = "@"
    
    ' Validacao numerica
    ApplySimpleValidation ws.Range("M7:M1007"), _
                         "=AND(ISNUMBER(M1),M1>=1,M1<=99999999)", _
                         "Valor Invalido", _
                         "Digite um valor entre 1 e 99.999.999"
    ws.Range("M7:M1007").NumberFormat = """R$"" #,##0.00"

    ApplySimpleValidation wsPedido.Range("V7:AE1007"), _
                         "=AND(ISNUMBER(V1),V1>=1,V1<=99999999)", _
                         "Valor Invalido", _
                         "Digite um valor entre 1 e 99.999.999"
    ws.Range("V7:AE1007").NumberFormat = """R$"" #,##0.00"
    
    ' Validacao percentual
    ApplySimpleValidation ws.Range("N7:N1007,O7:O1007"), _
                         "=AND(ISNUMBER(N1),N1>=0,N1<=100)", _
                         "Valor Invalido", _
                         "Digite um valor entre 0 e 100"
    ws.Range("N7:N1007,O7:O1007").NumberFormat = "0.00""%"""
    
    ' Validacao de atributos
    ApplySimpleValidation ws.Range("R7:Y1007"), _
                         "=LEN(R7)<=50", _
                         "Limite de Caracteres", _
                         "Maximo de 50 caracteres permitidos."
    
    
    ' ========= LISTAS SUSPENSAS =========
    
    ' Listas suspensas fixas (com tratamento de erro aprimorado)
    ApplyDropdown ws, wsDados, "A7:A1007", "A1:A100700"
    ApplyDropdown ws, wsDados, "E7:E1007", "E1:E100700"
    ApplyDropdown ws, wsDados, "H7:H1007", "H1:H100700"
    ApplyDropdown ws, wsDados, "J7:J1007", "J1:J100700"
    ApplyDropdown ws, wsDados, "K7:K1007", "K1:K100700"
    ApplyDropdown ws, wsDados, "L7:L1007", "L1:L100700"
    ApplyDropdown ws, wsDados, "P7:P1007", "P1:P100700"
    
    ApplyDropdown wsPedido, wsDadosPedido, "B7:B1007", "B1:B100700"
    ApplyDropdown wsPedido, wsDadosPedido, "C7:C1007", "C1:C100700"
    ApplyDropdown wsPedido, wsDadosPedido, "H7:H1007", "H1:H100700"
    ApplyDropdown wsPedido, wsDadosPedido, "K7:K1007", "K1:K100700"
    
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

' ========= FUNCA•ES AUXILIARES =========
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
