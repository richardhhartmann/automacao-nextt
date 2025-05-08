Private Sub Worksheet_Change(ByVal Target As Range)
    ' Verifica se a alteração ocorreu no intervalo A7:A1007
    If Intersect(Target, Me.Range("A7:A1007")) Is Nothing Then Exit Sub
    
    ' Desativa recursos para melhor performance
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    On Error GoTo CleanUp
    
    Dim wsDados As Worksheet
    Dim rngDados As Range, rngLocal As Range
    Dim dictDados As Object, dictLocal As Object
    Dim cell As Range
    Dim valor As String
    Dim ultimaLinhaDados As Long, ultimaLinhaLocal As Long
    
    ' Configura acesso às planilhas
    Set wsDados = ThisWorkbook.Worksheets("Dados Consolidados")
    
    ' 1. PREPARA VERIFICAÇÃO EM DADOS CONSOLIDADOS (coluna AR)
    ultimaLinhaDados = wsDados.Cells(wsDados.Rows.Count, "AR").End(xlUp).Row
    If ultimaLinhaDados < 1 Then ultimaLinhaDados = 1
    Set rngDados = wsDados.Range("AR1:AR" & ultimaLinhaDados)
    
    ' 2. PREPARA VERIFICAÇÃO NA PLANILHA ATUAL (coluna A)
    ultimaLinhaLocal = Me.Cells(Me.Rows.Count, "A").End(xlUp).Row
    If ultimaLinhaLocal < 7 Then ultimaLinhaLocal = 7 ' Começa em A7
    Set rngLocal = Me.Range("A7:A" & ultimaLinhaLocal)
    
    ' Cria dicionários para verificação rápida
    Set dictDados = CreateObject("Scripting.Dictionary")
    Set dictLocal = CreateObject("Scripting.Dictionary")
    dictDados.CompareMode = vbTextCompare
    dictLocal.CompareMode = vbTextCompare
    
    ' Preenche dicionário de Dados Consolidados
    Dim celDado As Range
    For Each celDado In rngDados
        If Not IsEmpty(celDado.value) Then
            valor = Trim(CStr(celDado.value))
            If Not dictDados.Exists(valor) Then dictDados.Add valor, Nothing
        End If
    Next celDado
    
    ' Preenche dicionário da planilha atual (exceto célula sendo editada)
    Dim celLocal As Range
    For Each celLocal In rngLocal
        If Not Intersect(celLocal, Target) Is Nothing Then
            ' Ignora a célula sendo editada
        Else
            If Not IsEmpty(celLocal.value) Then
                valor = Trim(CStr(celLocal.value))
                If Not dictLocal.Exists(valor) Then dictLocal.Add valor, Nothing
            End If
        End If
    Next celLocal
    
    ' VERIFICA CADA CÉLULA ALTERADA
    For Each cell In Intersect(Target, Me.Range("A7:A1007"))
        valor = Trim(cell.value)
        If Len(valor) = 0 Then GoTo NextCell ' Ignora células vazias
        
        ' Verifica duplicata em Dados Consolidados
        If dictDados.Exists(valor) Then
            MsgBox "O valor '" & valor & "' ja foi cadastrado!", vbExclamation, "Duplicata Detectada"
            Application.Undo
            cell.Select
            GoTo CleanUp
        End If
        
        ' Verifica duplicata na planilha atual
        If dictLocal.Exists(valor) Then
            MsgBox "O valor '" & valor & "' ja existe nesta planilha!", vbExclamation, "Duplicata Local"
            Application.Undo
            cell.Select
            GoTo CleanUp
        End If
        
NextCell:
    Next cell
    
CleanUp:
    ' Restaura configurações do Excel
    Application.EnableEvents = True
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    
    ' Limpa objetos
    Set dictDados = Nothing
    Set dictLocal = Nothing
    Set rngDados = Nothing
    Set rngLocal = Nothing
    Set wsDados = Nothing
End Sub