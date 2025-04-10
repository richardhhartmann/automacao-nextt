Private Sub Worksheet_Change(ByVal Target As Range)
    Dim CheckRange As Range
    Dim FoundCell As Range
    ThisWorkbook.Save

    If Not Intersect(Target, Me.Range("A7:A200")) Is Nothing Then
        If Trim(Target.Value) = "" Then Exit Sub
        Set CheckRange = Worksheets("Dados Consolidados").Range("AW1:AW100000")
        Set FoundCell = CheckRange.Find(Target.Value, LookIn:=xlValues)
        If Not FoundCell Is Nothing Then
            MsgBox "O valor digitado ja existe no banco de dados. Tente novamente.", vbExclamation
            Application.EnableEvents = False
            Target.ClearContents
            Application.EnableEvents = True
        End If
    End If
End Sub