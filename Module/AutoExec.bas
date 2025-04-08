Private Sub Workbook_Open()
    ' Declaração de variáveis
    Dim ws As Worksheet
    Dim Segmentows As Worksheet
    Dim imageFolder As String
    Dim brandPath As String, uploadPath As String
    Dim shp As Shape
    
    ' Chamada de procedimentos externos (verifique se estão em módulos padrão)
    Call AtualizarDadosConsolidados
    Call GerarFormulaDinamica.GerarFormulaDinamica
    Call PreencherCelulasComAtributos.PreencherCelulasComAtributos
    Call BloquearTodasAbas.BloquearTodasAbas
    Call BloquearTodasAbas.BloquearCadastroProdutos
    Call OcultarAbasProtegidas.OcultarAbasProtegidas
    
    ' Define as planilhas
    Set ws = ThisWorkbook.Sheets("Nextt")
    
    On Error Resume Next ' Evita erro se a planilha não existir
    Set Segmentows = ThisWorkbook.Sheets("Cadastro de Segmento")
    On Error GoTo 0
    
    ' Verifica se a pasta de imagens existe
    imageFolder = ThisWorkbook.Path & "\"
    brandPath = imageFolder & "brand.png"
    uploadPath = imageFolder & "upload.png"
    
    ' Remove imagens existentes (se houver)
    For Each shp In ws.Shapes
        If shp.Name = "BrandImage" Or shp.Name = "UploadImage" Then
            shp.Delete
        End If
    Next shp
    
    ' Adiciona a imagem da marca (brand.png)
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
    
    ' Adiciona a imagem de upload (upload.png)
    If Dir(uploadPath) <> "" Then
        With ws.Shapes.AddPicture( _
            Filename:=uploadPath, _
            LinkToFile:=msoFalse, _
            SaveWithDocument:=msoTrue, _
            Left:=ws.Range("G10").Left, _
            Top:=ws.Range("G10").Top - 12, _
            Width:=-1, Height:=-1)
            .Name = "UploadImage"
            .Width = 40
        End With
    End If
End Sub

