Private Sub Worksheet_Change(ByVal Target As Range)
    Dim CheckRange As Range
    Dim FoundCell As Range
    ThisWorkbook.Save

    If Not Intersect(Target, Me.Range("A7:A1007")) Is Nothing Then
        If Trim(Target.Value) = "" Then Exit Sub
        
        Set CheckRange = Worksheets("Dados Consolidados").Range("AT1:AT100700")
        Set FoundCell = CheckRange.Find(Target.Value, LookIn:=xlValues)

        If Not FoundCell Is Nothing Then
            MsgBox "O valor ja existe no banco de dados.", vbExclamation
            Application.EnableEvents = False
            Target.ClearContents
            Application.EnableEvents = True
        End If
    End If
End Sub
