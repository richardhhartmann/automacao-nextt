Attribute VB_Name="ShowCalPt"
Sub ShowCalPt(Target As Range)
    Dim myDate As Date
    Dim linha As Long
    Dim dataInicial As Variant, dataFinal As Variant

    CalendarForm.Caption = "Selecione a data"
    myDate = CalendarForm.GetDate(Language:="pt", FirstDayOfWeek:=Sunday, SaturdayFontColor:=RGB(250, 0, 0), SundayFontColor:=RGB(250, 0, 0))
    
    If myDate > 0 Then
        Target.Value = myDate

        If Not Intersect(Target, Range("D7:D1007,E7:E1007")) Is Nothing Then
            linha = Target.Row
            
            If linha >= 7 And linha <= 1007 Then
                dataInicial = Cells(linha, "D").Value
                dataFinal = Cells(linha, "E").Value

                If IsDate(dataInicial) And IsDate(dataFinal) Then
                    If CDate(dataInicial) > CDate(dataFinal) Then
                        MsgBox "A data de entrega inicial nao pode ser posterior a data de entrega final.", vbExclamation
                        Cells(linha, "E").ClearContents
                    End If
                End If
            End If
        End If
    End If
End Sub