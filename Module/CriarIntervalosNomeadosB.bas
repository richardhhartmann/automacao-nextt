Sub CriarIntervalosNomeadosB()
    Dim ws As Worksheet
    Dim ultimaLinha As Long, i As Long
    Dim secAtual As Integer, primeiraLinha As Long
    Dim rng As Range
    
    On Error GoTo ErrorHandler
    
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets("Dados Consolidados")
    On Error GoTo ErrorHandler
    
    If ws Is Nothing Then
        MsgBox "Planilha 'Dados Consolidados' não encontrada!", vbExclamation
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    
    With ws
        ultimaLinha = .Cells(.Rows.Count, "AY").End(xlUp).Row
        
        If ultimaLinha < 1 Then
            MsgBox "Nenhum dado encontrado na coluna AY!", vbExclamation
            Exit Sub
        End If
        
        secAtual = .Cells(1, "AY").Value
        primeiraLinha = 1
        
        For i = 1 To ultimaLinha + 1
            If i > ultimaLinha Or .Cells(i, "AY").Value <> secAtual Then
                Set rng = .Range("B" & primeiraLinha & ":B" & i - 1)
                
                On Error Resume Next
                ThisWorkbook.Names("SecaoCompleta" & secAtual).Delete
                On Error GoTo 0
                
                ThisWorkbook.Names.Add _
                    Name:="SecaoCompleta" & secAtual, _
                    RefersTo:=rng
                
                If i <= ultimaLinha Then
                    secAtual = .Cells(i, "AY").Value
                    primeiraLinha = i
                End If
            End If
        Next i
    End With
    
    Application.ScreenUpdating = True
    Exit Sub
    
ErrorHandler:
    MsgBox "Erro: " & Err.Description, vbCritical
    Application.ScreenUpdating = True
End Sub
