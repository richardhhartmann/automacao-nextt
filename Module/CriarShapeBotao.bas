Attribute VB_Name = "CriarShapeBotao"
Sub CriarShapeBotao()
    Dim ws As Worksheet
    Dim wsMarca As Worksheet
    Dim wsCadastro As Worksheet

    Set ws = ThisWorkbook.Sheets("Nextt")
    Set wsMarca = ThisWorkbook.Sheets("Cadastro de Marcas")
    Set wsCadastro = ThisWorkbook.Sheets("Cadastro de Produtos")
    
    On Error Resume Next
    ws.Shapes("btnShape").Delete
    wsMarca.Shapes("cadastroMarca").Delete
    wsCadastro.Shapes("limparValoresBtn").Delete
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

    Dim limparBtn As Shape
    Set limparBtn = wsCadastro.Shapes.AddShape(msoShapeRoundedRectangle, _
        wsCadastro.Range("A1").Left + wsCadastro.Range("A1").Width - 75, _
        wsCadastro.Range("A1").Top, 75, 15)

    With limparBtn
        .Name = "limparValoresBtn"
        .TextFrame2.TextRange.Text = "Limpar Valores"
        .Fill.ForeColor.RGB = RGB(180, 198, 231) ' Igual ao botÃ£o operador

        With .TextFrame2.TextRange
            .Font.Size = 7
            .Font.Name = "Arial"
            .Font.Bold = msoFalse
            .Font.Fill.ForeColor.RGB = RGB(61, 61, 61)
        End With

        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter

        .OnAction = "ConfirmarLimpeza"
    End With
End Sub

Sub ConfirmarLimpeza()
    Dim resposta As VbMsgBoxResult
    resposta = MsgBox("Deseja limpar os valores da planilha?", vbQuestion + vbYesNo, "Confirmacao")

    If resposta = vbYes Then
        LimparValores.LimparValoresCadastroDeProdutos
    End If
End Sub

Sub CriarShapeBotaoCadastroPedidos()
    Dim ws As Worksheet
    Dim wsCadastroPedidos As Worksheet

    ' Definindo as abas
    Set ws = ThisWorkbook.Sheets("Nextt")
    Set wsCadastroPedidos = ThisWorkbook.Sheets("Cadastro de Pedidos")
    
    ' Remover botão anterior, se houver
    On Error Resume Next
    wsCadastroPedidos.Shapes("limparValoresBtnPedidos").Delete
    On Error GoTo 0

    ' Criar o botão na aba Cadastro de Pedidos
    Dim limparBtnPedidos As Shape
    Set limparBtnPedidos = wsCadastroPedidos.Shapes.AddShape(msoShapeRoundedRectangle, _
        wsCadastroPedidos.Range("A1").Left + wsCadastroPedidos.Range("A1").Width + 20, _
        wsCadastroPedidos.Range("A1").Top, 75, 15)

    ' Configurar o botão
    With limparBtnPedidos
        .Name = "limparValoresBtnPedidos"
        .TextFrame2.TextRange.Text = "Limpar Valores"
        .Fill.ForeColor.RGB = RGB(180, 198, 231) ' Mesmo estilo do botão anterior

        ' Configurar fonte do botão
        With .TextFrame2.TextRange
            .Font.Size = 7
            .Font.Name = "Arial"
            .Font.Bold = msoFalse
            .Font.Fill.ForeColor.RGB = RGB(61, 61, 61)
        End With

        ' Alinhar o texto verticalmente e no centro
        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter

        ' Associar a macro ao botão
        .OnAction = "ConfirmarLimpezaCadastroPedidos"
    End With
End Sub

Sub ConfirmarLimpezaCadastroPedidos()
    Dim resposta As VbMsgBoxResult
    resposta = MsgBox("Deseja limpar os valores da planilha?", vbQuestion + vbYesNo, "Confirmacao")

    If resposta = vbYes Then
        LimparValores.LimparValoresCadastroDePedidos
    End If
End Sub