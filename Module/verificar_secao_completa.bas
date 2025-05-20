Attribute VB_Name = "VerificarSecaoEspecie"
Sub VerificarSecaoCompleta()
    Dim ws As Worksheet, dadosWs As Worksheet
    Dim cel As Range, listaNomes As Range, item As Range
    Dim nomeLista As String, valorProcurado As Variant
    Dim encontrado As Boolean
    Dim valorLista As Variant

    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set dadosWs = ThisWorkbook.Sheets("Dados Consolidados")

    ws.Calculate

    For Each cel In ws.Range("B7:B1007")
        If IsEmpty(cel.Value) Then
            cel.Interior.ColorIndex = xlNone
            GoTo ProximaCelula
        End If
        
        valorProcurado = Trim(CStr(cel.Value))
        nomeLista = "SecaoCompleta" & Trim(CStr(ws.Range("BC" & cel.Row).Value))

        Set listaNomes = Nothing
        On Error Resume Next
        Set listaNomes = dadosWs.Range(nomeLista)
        On Error GoTo 0

        If listaNomes Is Nothing Then GoTo ProximaCelula

        encontrado = False
        For Each item In listaNomes
            valorLista = Trim(CStr(item.Value))
            If valorLista = valorProcurado Then
                encontrado = True
                Exit For
            End If
        Next item

        If encontrado Then
            cel.Interior.Color = RGB(221, 235, 247)
        Else
            cel.Interior.Color = RGB(244, 204, 204)
            'MsgBox "Especie nao encontrada para esta secao, tente novamente.", vbExclamation, "Erro de Validacao"
            cel.ClearContents
            cel.Interior.ColorIndex = xlNone
        End If

ProximaCelula:
        Set listaNomes = Nothing
    Next cel
End Sub


Sub ValidarDescricoes()
    Dim ws As Worksheet, dadosWs As Worksheet
    Dim cel As Range, celDado As Range
    Dim valorProcurado As Variant
    Dim encontrado As Boolean

    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set dadosWs = ThisWorkbook.Sheets("Dados Consolidados")

    For Each cel In ws.Range("A7:A1007")
        If IsEmpty(cel.Value) Then
            cel.Interior.ColorIndex = xlNone
            GoTo ProximaCelula
        End If

        valorProcurado = Trim(CStr(cel.Value))
        encontrado = False

        For Each celDado In dadosWs.Range("A1:A" & dadosWs.Cells(dadosWs.Rows.Count, 1).End(xlUp).Row)
            If Trim(CStr(celDado.Value)) = valorProcurado Then
                encontrado = True
                Exit For
            End If
        Next celDado

        If encontrado Then
            cel.Interior.Color = RGB(221, 235, 247)
        Else
            cel.Interior.Color = RGB(244, 204, 204)
            MsgBox "Secao nao encontrada na sua lista de secoes, tente novamente.", vbExclamation, "Erro de Validacao"
            cel.ClearContents
            cel.Interior.ColorIndex = xlNone
        End If

ProximaCelula:
    Next cel
End Sub

Sub ValidarEspecies()
    On Error GoTo TratarErro
    
    Dim ws As Worksheet, dadosWs As Worksheet
    Dim cel As Range, celDado As Range
    Dim valorProcurado As String, grupoSecao As String
    Dim encontrado As Boolean
    Dim grupoRange As Range
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set dadosWs = ThisWorkbook.Sheets("Dados Consolidados")
    
    If ws Is Nothing Or dadosWs Is Nothing Then
        MsgBox "Planilha 'Cadastro de Produtos' ou 'Dados Consolidados' nao encontrada!", vbExclamation
        Exit Sub
    End If
    
    For Each cel In ws.Range("B7:B1007")
        If IsEmpty(cel.Value) Then
            cel.Interior.ColorIndex = xlNone
            GoTo ProximaCelula
        End If

        valorProcurado = Trim(CStr(cel.Value))
        grupoSecao = "SecaoCompleta" & Trim(CStr(ws.Range("BC" & cel.Row).Value))
        encontrado = False
        
        On Error Resume Next
        Set grupoRange = dadosWs.Range(grupoSecao)
        On Error GoTo TratarErro
        
        If Not grupoRange Is Nothing Then
            For Each celDado In grupoRange
                If Trim(CStr(celDado.Value)) = valorProcurado Then
                    encontrado = True
                    Exit For
                End If
            Next celDado
        End If

        If encontrado Then
            cel.Interior.Color = RGB(221, 235, 247)
        Else
            cel.Interior.Color = RGB(244, 204, 204)
            MsgBox "Especie nao encontrada na sua lista de especies.", vbExclamation, "Erro de Validacao"
            cel.ClearContents
            cel.Interior.ColorIndex = xlNone
        End If

ProximaCelula:
        Set grupoRange = Nothing
    Next cel
    
    Exit Sub
    
TratarErro:
    MsgBox "Ocorreu um erro na validacao: " & Err.Description, vbCritical, "Erro"
    Resume ProximaCelula
End Sub
