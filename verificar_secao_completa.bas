Attribute VB_Name = "VerificarSecaoCompleta"
Sub VerificarSecaoCompleta()
    Dim ws As Worksheet, dadosWs As Worksheet
    Dim cel As Range, listaNomes As Range, item As Range
    Dim nomeLista As String, valorProcurado As Variant
    Dim encontrado As Boolean
    Dim valorLista As Variant
    Dim posicaoHifen As Integer
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set dadosWs = ThisWorkbook.Sheets("Dados Consolidados")
    
    ws.Calculate

    For Each cel In ws.Range("B7:B200")

        cel.Interior.ColorIndex = xlNone
        
        If IsEmpty(cel.Value) Then GoTo ProximaCelula
        
        nomeLista = "SecaoCompleta" & Trim(CStr(ws.Range("BC" & cel.Row).Value))
        
        On Error Resume Next
        valorProcurado = CLng(ws.Range("BD" & cel.Row).Value)
        If Err.Number <> 0 Then valorProcurado = Trim(CStr(ws.Range("BD" & cel.Row).Value)) ' Se der erro, trata como texto
        On Error GoTo 0
        
        If valorProcurado = "" Then GoTo ProximaCelula

        On Error Resume Next
        Set listaNomes = dadosWs.Range(nomeLista)
        On Error GoTo 0

        If listaNomes Is Nothing Then
            Debug.Print "Lista nao encontrada para " & nomeLista
            GoTo ProximaCelula
        End If

        encontrado = False
        
        For Each item In listaNomes
            On Error Resume Next
            valorLista = Trim(CStr(item.Value))
            On Error GoTo 0
            
            posicaoHifen = InStr(1, valorLista, " - ")
            If posicaoHifen > 0 Then
                valorLista = Trim(Left(valorLista, posicaoHifen - 1))
            End If
            If Trim(CStr(valorLista)) = Trim(CStr(valorProcurado)) Then
                encontrado = True
                Exit For
            End If
        Next item

        If Not encontrado Then
            cel.Interior.Color = RGB(244, 204, 204)
            MsgBox "Especie nao encontrada para esta secao, tente novamente.", vbExclamation, "Erro de Validacao"
            cel.ClearContents 
            cel.Interior.ColorIndex = xlNone 
        End If

ProximaCelula:
        Set listaNomes = Nothing
    Next cel
End Sub
