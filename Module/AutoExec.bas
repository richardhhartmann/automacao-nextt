Private Sub Workbook_Open()
    Dim ws As Worksheet
    Dim imageFolder As String
    Dim brandPath As String, uploadPath As String, refreshPath As String
    Dim shp As Shape
    Dim response As Integer
    
    Set ws = ThisWorkbook.Sheets("Nextt")
    imageFolder = ThisWorkbook.Path & "\Public\"
    brandPath = imageFolder & "brand.png"
    uploadPath = imageFolder & "upload.png"
    refreshPath = imageFolder & "refresh.png"
    
    With ws
        If Not .Range("O3").Value Like "Atualizado*" Then
            
            Call AtualizarDadosConsolidados
            Call AtualizarDadosPedido
            Call GerarFormulaDinamica.GerarFormulaDinamica
            Call PreencherCelulasComAtributos.PreencherCelulasComAtributos
            Call BloquearTodasAbas.BloquearTodasAbas
            Call BloquearTodasAbas.BloquearCadastroProdutos
            Call BloquearTodasAbas.BloquearCadastroMarcas
            'Call BloquearTodasAbas.BloquearCadastroPedidos
            Call OcultarAbasProtegidas.OcultarAbasProtegidas
            Call CriarShapeBotao.CriarShapeBotao
            Call CriarShapeBotao.CriarShapeBotaoCadastroPedidos
            Call AplicarValidacaoObrigatoria.AplicarValidacaoObrigatoria
            Call AplicarValidacaoObrigatoria.VerificarEDefinirDropDowns
            Call ConsultaFiliais.ConsultaFiliais
            Call Formatacao.Formatacao
            Call OcultarColunasANaXFD_Comprovado.OcultarColunasANaXFD_Comprovado
        
            Application.EnableEvents = False
            With ThisWorkbook.Sheets("Nextt").Range("O3")
                .Value = "Atualizado em " & Now
                .Interior.Color = RGB(180, 198, 231)
                .Font.Color = RGB(102, 102, 102)
            End With
            Application.EnableEvents = True

            response = MsgBox("Deseja executar o monitoramento do banco de dados em tempo real?", vbQuestion + vbYesNo, "Monitoramento em Tempo Real")
            
            If response = vbYes Then
                Call CheckDB.StartDBMonitoring
            End If

        Else
            Call AtualizarInterface.AtualizarInterface

            response = MsgBox("Deseja executar o monitoramento do banco de dados em tempo real?", vbQuestion + vbYesNo, "Monitoramento em Tempo Real")
            
            If response = vbYes Then
                Call CheckDB.StartDBMonitoring
            End If
            
        End If

        ' Remove imagens antigas
        For Each shp In .Shapes
            If shp.Name = "BrandImage" Or shp.Name = "UploadImage" Or shp.Name = "RefreshImage" Then shp.Delete
        Next shp

        ' Adiciona BrandImage com hyperlink
        If Dir(brandPath) <> "" Then
            .Unprotect password:="nexttsol"
            
            ' Adiciona a imagem
            Dim img As Shape
            Set img = .Shapes.AddPicture(brandPath, msoFalse, msoTrue, .Range("B2").Left, .Range("B2").Top - 5, -1, -1)
            
            With img
                .Name = "BrandImage"
                .LockAspectRatio = msoTrue
                .Width = 90
                
                ' Atribui macro de hyperlink
                .OnAction = "AbrirLinkBrand"
            End With
            
            .Protect password:="nexttsol", UserInterfaceOnly:=True
        Else
            MsgBox "A imagem 'brand.png' não foi encontrada em: " & brandPath
        End If
        ' Upload Image
        If Dir(uploadPath) <> "" Then
            With .Shapes.AddPicture(uploadPath, msoFalse, msoTrue, .Range("I10").Left, .Range("I10").Top - 12, -1, -1)
                .Name = "UploadImage"
                .Width = 40
            End With
        End If

        ' Refresh Image
        If Dir(refreshPath) <> "" Then
            .Columns("Q:XFD").EntireColumn.Hidden = False ' Revela as colunas ocultas

            With .Shapes.AddPicture(refreshPath, msoFalse, msoTrue, .Range("N3").Left + 15, .Range("N3").Top, -1, -1)
                .Name = "RefreshImage"
                .LockAspectRatio = msoTrue
                .Width = 20
                .OnAction = "AtualizarInterface.AtualizarInterface"
            End With

            .Columns("Q:XFD").EntireColumn.Hidden = True ' Oculta novamente após inserir
        End If
    End With
End Sub

Private Sub Workbook_BeforeClose(Cancel As Boolean)
    On Error Resume Next
    If Not dbListener Is Nothing Then
        dbListener.Terminate
        Set dbListener = Nothing
    End If
End Sub

