Attribute VB_Name = "CriarShapeBotao"
Sub CriarShapeBotao()
    Dim ws As Worksheet
    Dim wsMarca As Worksheet
    Dim wsCadastro As Worksheet

    Set ws = ThisWorkbook.Sheets("Nextt")
    Set wsMarca = ThisWorkbook.Sheets("Cadastro de Marcas")
    Set wsCadastro = ThisWorkbook.Sheets("Cadastro de Produtos")
    
    ' Remover shapes anteriores, se existirem
    On Error Resume Next
    ws.Shapes("btnShape").Delete
    wsMarca.Shapes("cadastroMarca").Delete
    wsCadastro.Shapes("limparValoresBtn").Delete
    On Error GoTo 0

    ' Botão: Nextt
    Dim botao As Shape
    Set botao = ws.Shapes.AddShape(msoShapeRoundedRectangle, 100, 1075, 200, 20)
    
    With botao
        .Name = "btnShape"
        .TextFrame2.TextRange.Text = "Habilitar Modo Operador"
        .Fill.ForeColor.RGB = RGB(180, 198, 231)
        .line.Visible = msoFalse
        
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

    ' Botão: Cadastro de Marcas
    Dim cadastroMarca As Shape
    Set cadastroMarca = wsMarca.Shapes.AddShape(msoShapeRoundedRectangle, 0, 175, 990, 15)
    
    With cadastroMarca
        .Name = "cadastroMarca"
        .TextFrame2.TextRange.Text = "Executar Cadastro"
        .Fill.ForeColor.RGB = RGB(243, 243, 243)
        .line.Visible = msoFalse
        
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

    ' Botão: Cadastro de Produtos (limpar valores)
    Dim limparBtn As Shape
    With wsCadastro
        .Unprotect password:="nexttsol" ' Garante que a aba esteja desbloqueada

        Set limparBtn = .Shapes.AddShape(msoShapeRoundedRectangle, _
            .Range("A1").Left + 125, .Range("A1").Top, 80, 20)

        With limparBtn
            .Name = "limparValoresBtn"
            .TextFrame2.TextRange.Text = "Limpar Valores"
            .Fill.ForeColor.RGB = RGB(180, 198, 231)
            .line.Visible = msoFalse

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

        ' Protege novamente a aba após inserir o botão
        .Protect password:="nexttsol", _
                 AllowFormattingCells:=False, _
                 AllowInsertingColumns:=False, _
                 AllowInsertingRows:=False, _
                 AllowDeletingColumns:=False, _
                 AllowDeletingRows:=False, _
                 AllowSorting:=False, _
                 AllowFiltering:=False, _
                 AllowUsingPivotTables:=False, _
                 DrawingObjects:=True, _
                 Contents:=True, _
                 Scenarios:=True, _
                 UserInterfaceOnly:=True

        .EnableSelection = xlUnlockedCells ' Evita seleção de células protegidas
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

    Set ws = ThisWorkbook.Sheets("Nextt")
    Set wsCadastroPedidos = ThisWorkbook.Sheets("Cadastro de Pedidos")
    
    On Error Resume Next
    wsCadastroPedidos.Shapes("limparValoresBtnPedidos").Delete
    On Error GoTo 0

    Dim limparBtnPedidos As Shape
    Dim celulaBase As Range
    Set celulaBase = wsCadastroPedidos.Range("A1")
    
    wsCadastroPedidos.Activate
    wsCadastroPedidos.Unprotect password:="nexttsol"
    
    Set limparBtnPedidos = wsCadastroPedidos.Shapes.AddShape( _
        Type:=msoShapeRoundedRectangle, _
        Left:=celulaBase.Left + 125, _
        Top:=celulaBase.Top, _
        Width:=80, _
        Height:=20)

    With limparBtnPedidos
        .Name = "limparValoresBtnPedidos"
        .TextFrame2.TextRange.Text = "Limpar Valores"
        .Fill.ForeColor.RGB = RGB(180, 198, 231)
        .line.Visible = msoFalse

        With .TextFrame2.TextRange
            .Font.Size = 7
            .Font.Name = "Arial"
            .Font.Bold = msoFalse
            .Font.Fill.ForeColor.RGB = RGB(61, 61, 61)
        End With

        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter

        .OnAction = "ConfirmarLimpezaCadastroPedidos"
    End With
    ws.Protect password:="nexttsol", UserInterfaceOnly:=True, DrawingObjects:=False
End Sub

Sub ConfirmarLimpezaCadastroPedidos()
    Dim resposta As VbMsgBoxResult
    resposta = MsgBox("Deseja limpar os valores da planilha?", vbQuestion + vbYesNo, "Confirmacao")

    If resposta = vbYes Then
        LimparValores.LimparValoresCadastroDePedidos
    End If
End Sub