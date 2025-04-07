Attribute VB_Name = "GerarFormulaDinamica"
Sub GerarFormulaDinamica()
    Dim ws As Worksheet
    Dim ultimaColuna As Integer
    Dim col As Integer
    Dim linha As Integer
    Dim condicao As String
    Dim rng As Range
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    
    ultimaColuna = ws.Cells(4, ws.Columns.Count).End(xlToLeft).Column
    
    Set rng = ws.Range("BK7:BK200")
    
    For linha = 7 To 200
        condicao = "SE(E("
        
        For col = 1 To ultimaColuna
            If ws.Cells(4, col).Value = "Obrigatorio" Then
                condicao = condicao & ws.Cells(linha, col).Address(False, False) & "<>"""";"
            End If
        Next col
        
        If Right(condicao, 1) = ";" Then
            condicao = Left(condicao, Len(condicao) - 1)
        End If
        
        condicao = condicao & ");""OK"";""n/a"")"

        ws.Cells(linha, 63).FormulaLocal = "=" & condicao
    Next linha
End Sub
