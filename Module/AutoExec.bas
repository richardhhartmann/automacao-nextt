Private Sub Workbook_Open()
    Dim ws As Worksheet
    Dim Segmentows As Worksheet
    Dim imageFolder As String
    Dim brandPath As String, uploadPath As String
    Dim shp As Shape
    
    Call AtualizarDadosConsolidados
    Call GerarFormulaDinamica.GerarFormulaDinamica
    Call PreencherCelulasComAtributos.PreencherCelulasComAtributos
    Call BloquearTodasAbas.BloquearTodasAbas
    Call BloquearTodasAbas.BloquearCadastroProdutos
    Call OcultarAbasProtegidas.OcultarAbasProtegidas
    Call CriarShapeBotao.CriarShapeBotao
    
    Set ws = ThisWorkbook.Sheets("Nextt")
    
    On Error Resume Next
    Set Segmentows = ThisWorkbook.Sheets("Cadastro de Segmento")
    On Error GoTo 0
    
    imageFolder = ThisWorkbook.Path & "\"
    brandPath = imageFolder & "brand.png"
    uploadPath = imageFolder & "upload.png"
    
    For Each shp In ws.Shapes
        If shp.Name = "BrandImage" Or shp.Name = "UploadImage" Then
            shp.Delete
        End If
    Next shp
    
    If Dir(brandPath) <> "" Then
        With ws.Shapes.AddPicture( _
            Filename:=brandPath, _
            LinkToFile:=msoFalse, _
            SaveWithDocument:=msoTrue, _
            Left:=ws.Range("B2").Left, _
            Top:=ws.Range("B2").Top - 5, _
            Width:=-1, Height:=-1)
            .Name = "BrandImage"
            .LockAspectRatio = msoTrue
            .Width = 90
        End With
    End If
    
    If Dir(uploadPath) <> "" Then
        With ws.Shapes.AddPicture( _
            Filename:=uploadPath, _
            LinkToFile:=msoFalse, _
            SaveWithDocument:=msoTrue, _
            Left:=ws.Range("I10").Left, _
            Top:=ws.Range("I10").Top - 12, _
            Width:=-1, Height:=-1)
            .Name = "UploadImage"
            .Width = 40
        End With
    End If
End Sub

