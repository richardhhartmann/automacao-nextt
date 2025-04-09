Attribute VB_Name = "CriarShapeBotao"
Sub CriarShapeBotao()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Nextt")

    Dim botao As Shape
    Set botao = ws.Shapes.AddShape(msoShapeRoundedRectangle, 100, 1000, 200, 20)
    
    With botao
        .Name = "btnShape"
        .TextFrame2.TextRange.Text = "Habilitar Modo Operador"
        .Fill.ForeColor.RGB = RGB(180, 198, 231)
        
        With .TextFrame2.TextRange
            .Font.Size = 9
            .Font.Name = "Arial"
            .Font.Bold = msoFalse
            .Font.Fill.ForeColor.RGB = RGB(61, 61, 61)
        End With

        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter

        .OnAction = "ReexibirAbas.ReexibirAbas"
    End With
End Sub

Sub RemoverBotaoEspecifico()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Nextt")

    On Error Resume Next
    ws.Shapes("btnShape").Delete
    On Error GoTo 0
End Sub
