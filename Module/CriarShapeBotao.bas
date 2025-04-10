Attribute VB_Name = "CriarShapeBotao"
Sub CriarShapeBotao()
    Dim ws As Worksheet
    Dim wsMarca As Worksheet
    
    Set ws = ThisWorkbook.Sheets("Nextt")
    Set wsMarca = ThisWorkbook.Sheets("Cadastro de Marcas")
    
    On Error Resume Next
    ws.Shapes("btnShape").Delete
    wsMarca.Shapes("cadastroMarca").Delete
    On Error GoTo 0

    Dim botao As Shape
    Set botao = ws.Shapes.AddShape(msoShapeRoundedRectangle, 100, 1075, 200, 20)
    
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

    Dim cadastroMarca As Shape
    Set cadastroMarca = wsMarca.Shapes.AddShape(msoShapeRoundedRectangle, 0, 175, 990, 15)
    
    With cadastroMarca
        .Name = "cadastroMarca"
        .TextFrame2.TextRange.Text = "Executar Cadastro"
        .Fill.ForeColor.RGB = RGB(243, 243, 243)
        
        With .TextFrame2.TextRange
            .Font.Size = 9
            .Font.Name = "Arial"
            .Font.Bold = msoFalse
            .Font.Fill.ForeColor.RGB = RGB(0, 0, 0)
        End With

        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter

        .OnAction = "ExecutarCadastroMarca"
    End With
End Sub
