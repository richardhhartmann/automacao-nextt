Attribute VB_Name="ShowCalPt"
Sub ShowCalPt(Target As Range)
    Dim myDate As Date

    CalendarForm.Caption = "Selecione a data"
    myDate = CalendarForm.GetDate(Language:="pt", FirstDayOfWeek:=Sunday, SaturdayFontColor:=RGB(250, 0, 0), SundayFontColor:=RGB(250, 0, 0))
    
    If myDate > 0 Then
        Target.Value = myDate
    End If
End Sub