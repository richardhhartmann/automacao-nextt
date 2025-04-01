Private Sub Worksheet_Change(ByVal Target As Range)
    Dim CheckRange As Range
    Dim FoundCell As Range
    Dim cel As Range
    Dim rng As Range

    If Not Intersect(Target, Me.Range("F7:F200")) Is Nothing Then
        If Trim(Target.Value) = "" Then Exit Sub

        Set CheckRange = Worksheets("Dados Consolidados").Range("AU1:AU100000")
        Set FoundCell = CheckRange.Find(Target.Value, LookIn:=xlValues)

        If Not FoundCell Is Nothing Then
            MsgBox "O valor ja existe no banco de dados.", vbExclamation
            Application.EnableEvents = False
            Target.ClearContents
            Application.EnableEvents = True
            Exit Sub
        End If
    End If
    
    If Not Intersect(Target, Me.Range("A7:A200, B7:B200, Y7:Y200, Z7:Z200")) Is Nothing Then
        Application.EnableEvents = False 
        Call VerificarSecaoCompleta.VerificarSecaoCompleta 
        Application.EnableEvents = True
    End If

    Set rng = Union(Me.Range("C7:C200"), _
                    Me.Range("D7:D200"), Me.Range("F7:F200"), Me.Range("E7:E200"), _
                    Me.Range("F7:F200"), Me.Range("H7:H200"), Me.Range("J7:J200"), _
                    Me.Range("K7:K200"), Me.Range("L7:L200"), Me.Range("M7:M200"), _
                    Me.Range("N7:N200"), Me.Range("O7:O200"), Me.Range("P7:P200"))

    Application.EnableEvents = False

    For Each cel In rng
        If Not Intersect(Target, cel) Is Nothing Then
            If Trim(cel.Value) = "" Then
                MsgBox "A celula nao pode ficar vazia apos ser editada.", vbExclamation, "Erro"
                Application.Undo
                Exit For
            End If
        End If
    Next cel

    Application.EnableEvents = True
End Sub


