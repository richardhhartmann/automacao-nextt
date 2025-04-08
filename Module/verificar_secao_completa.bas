Attribute VB_Name = "VerificarSecaoCompleta"
Sub VerificarSecaoCompleta()
    Dim ws As Worksheet, dadosWs As Worksheet
    Dim cel As Range, listaNomes As Range, item As Range
    Dim nomeLista As String, valorProcurado As Variant
    Dim encontrado As Boolean
    Dim valorLista As Variant

    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set dadosWs = ThisWorkbook.Sheets("Dados Consolidados")
    
    ws.Calculate

    For Each cel In ws.Range("B7:B200")

        cel.Interior.ColorIndex = xlNone
        
        If IsEmpty(cel.Value) Then GoTo ProximaCelula
        
        valorProcurado = Trim(CStr(cel.Value))
        nomeLista = "SecaoCompleta" & Trim(CStr(ws.Range("BC" & cel.Row).Value))
        
        Debug.Print ">>> Linha " & cel.Row
        Debug.Print "Valor procurado (coluna B): " & valorProcurado
        Debug.Print "Nome da lista esperada: " & nomeLista

        On Error Resume Next
        Set listaNomes = dadosWs.Range(nomeLista)
        On Error GoTo 0

        If listaNomes Is Nothing Then
            Debug.Print "!!! Lista nao encontrada para " & nomeLista
            GoTo ProximaCelula
        End If

        encontrado = False

        For Each item In listaNomes
            valorLista = Trim(CStr(item.Value))
            Debug.Print "Comparando com: " & valorLista

            If valorLista = valorProcurado Then
                encontrado = True
                Debug.Print ">>> Valor encontrado!"
                Exit For
            End If
        Next item

        If Not encontrado Then
            Debug.Print "!!! Valor NAO encontrado, sera limpo"
            cel.Interior.Color = RGB(244, 204, 204)
            MsgBox "Especie nao encontrada para esta secao, tente novamente.", vbExclamation, "Erro de Validacao"
            cel.ClearContents
            cel.Interior.ColorIndex = xlNone
        End If

ProximaCelula:
        Set listaNomes = Nothing
    Next cel
End Sub