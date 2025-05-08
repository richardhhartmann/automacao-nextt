Private Sub Worksheet_Change(ByVal Target As Range)
    Dim rowCheck As Long
    Dim ultimaLinha As Long
    Dim i As Long
    Dim valorA As String, valorB As String
    Dim rng As Range
    Dim cel As Range
    Dim CheckRange As Range
    Dim FoundCell As Range

    On Error GoTo Sair
    Application.EnableEvents = False

    ' Verifica alterações nas colunas A e B entre as linhas 7 e 1007
    Set rng = Intersect(Target, Me.Range("A7:B1007"))
    If rng Is Nothing Then GoTo Sair

    For Each cel In rng
        rowCheck = cel.Row
        valorA = Trim(Me.Cells(rowCheck, "A").Value)
        valorB = Trim(Me.Cells(rowCheck, "B").Value)

        ' --- Validação contra banco de dados (para coluna A apenas) ---
        If cel.Column = 1 And valorA <> "" Then
            Set CheckRange = Worksheets("Dados Consolidados").Range("AV1:AV100700")
            Set FoundCell = CheckRange.Find(valorA, LookIn:=xlValues)

            If Not FoundCell Is Nothing Then
                MsgBox "O valor digitado já existe no banco de dados. Tente novamente.", vbExclamation
                Me.Cells(rowCheck, "A").ClearContents
                GoTo Sair
            End If
        End If

        ' --- Validação local de duplicata A+B ---
        If valorA <> "" And valorB <> "" Then
            ultimaLinha = Me.Cells(Me.Rows.Count, "A").End(xlUp).Row
            For i = 7 To ultimaLinha
                If i <> rowCheck Then
                    If Trim(Me.Cells(i, "A").Value) = valorA And Trim(Me.Cells(i, "B").Value) = valorB Then
                        MsgBox "A combinação '" & valorA & " / " & valorB & "' já existe na linha " & i & ".", vbExclamation, "Duplicata detectada"
                        Me.Cells(rowCheck, "A").ClearContents
                        Me.Cells(rowCheck, "B").ClearContents
                        GoTo Sair
                    End If
                End If
            Next i

            ' Salva apenas se a tupla A+B for válida
            ThisWorkbook.Save
        End If
    Next cel

Sair:
    Application.EnableEvents = True
End Sub