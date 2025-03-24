Sub CriarIntervalosNomeadosB()
    Dim ws As Worksheet
    Dim ultimaLinha As Long
    Dim inicio As Long
    Dim i As Long
    Dim secao As Integer
    Dim nomeSecao As String
    Dim rng As Range
    
    Set ws = ThisWorkbook.Sheets("Dados Consolidados")

    ultimaLinha = ws.Cells(ws.Rows.Count, 2).End(xlUp).Row

    secao = 1
    inicio = 1

    For i = 1 To ultimaLinha
        If Left(ws.Cells(i, 2).Value, 2) = "1 " Then
            If inicio < i Then
                nomeSecao = "SecaoCompleta" & secao
                Set rng = ws.Range("B" & inicio & ":B" & (i - 1))
                ws.Names.Add Name:=nomeSecao, RefersTo:=rng
                secao = secao + 1
            End If
            inicio = i
        End If
    Next i

    If inicio <= ultimaLinha Then
        nomeSecao = "SecaoCompleta" & secao
        Set rng = ws.Range("B" & inicio & ":B" & ultimaLinha)
        ws.Names.Add Name:=nomeSecao, RefersTo:=rng
    End If

End Sub
