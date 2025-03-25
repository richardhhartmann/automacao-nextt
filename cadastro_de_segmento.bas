Private Sub Worksheet_Change(ByVal Target As Range)
    Dim CheckRange As Range
    Dim FoundCell As Range
    Dim cel As Range
    Dim rng As Range

    If Not Intersect(Target, Me.Range("A7:A200")) Is Nothing Then
        Set CheckRange = Worksheets("Dados Consolidados").Range("AR1:AR100000")
        Set FoundCell = CheckRange.Find(Target.Value, LookIn:=xlValues)
        If Not FoundCell Is Nothing Then
            MsgBox "O valor ja existe no banco de dados.", vbExclamation
            Application.EnableEvents = False
            Target.ClearContents
            Application.EnableEvents = True
            Exit Sub
        End If
    End If
    
End Sub
