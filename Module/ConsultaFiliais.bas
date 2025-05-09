Attribute VB_Name = "ConsultaFiliais"
Sub ConsultaFiliais()

    On Error Resume Next
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    On Error GoTo 0
    
    If ws Is Nothing Then
        MsgBox "A aba 'Cadastro de Pedidos' nao foi encontrada nesta planilha.", vbExclamation
        Exit Sub
    End If

    Dim caminho As String
    Dim txt As String
    Dim json As Object
    Dim conn As Object, rs As Object
    Dim sql As String
    Dim col As Long
    Dim i As Integer, j As Integer
    Dim locais() As String
    Dim countLocais As Long
    Dim inicioBloco As Long, fimBloco As Long

    caminho = ThisWorkbook.Path & "\conexao_temp.txt"

    On Error GoTo ErroArquivo
    txt = CreateObject("Scripting.FileSystemObject").OpenTextFile(caminho).ReadAll
    Set json = ParseJson(txt)
    On Error GoTo 0

    Set conn = CreateObject("ADODB.Connection")
    conn.Open "Provider=" & json("driver") & ";" & _
              "Data Source=" & json("server") & ";" & _
              "Initial Catalog=" & json("database") & ";" & _
              "User ID=" & json("username") & ";" & _
              "Password=" & json("password") & ";" & _
              "Trusted_Connection=" & json("trusted_connection") & ";"

    sql = "SELECT fil_descricao FROM tb_filial"
    Set rs = conn.Execute(sql)

    ReDim locais(0 To 0)
    countLocais = 0
    Do While Not rs.EOF
        If countLocais > 0 Then ReDim Preserve locais(0 To countLocais)
        locais(countLocais) = rs.Fields("fil_descricao").Value
        countLocais = countLocais + 1
        rs.MoveNext
    Loop

    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing

    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    ws.Rows(1).RowHeight = 15
    ws.Rows(2).RowHeight = 30
    ws.Rows(3).RowHeight = 30
    ws.Rows(4).RowHeight = 20
    ws.Rows(5).RowHeight = 85

    col = ws.Range("AN3").Column
    
    Dim inicioTotal As Long, fimTotal As Long
    inicioTotal = 40 
    fimTotal = inicioTotal + (countLocais * 10) - 1

    With ws.Range(ws.Cells(1, inicioTotal), ws.Cells(2, fimTotal))
        .Merge
        .Value = "Distribuicao entre Filiais"
        .Font.Name = "Arial"
        .Font.Size = 10
        .Font.Bold = True
        .Interior.Color = RGB(142, 169, 219) '
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter

        With .Borders
            .LineStyle = xlContinuous
            .Color = RGB(217, 217, 217) '
            .Weight = xlThin
        End With
    End With
    
    For i = 1 To 10
        inicioBloco = col

        For j = 0 To UBound(locais)
            With ws.Cells(3, col)
                .Value = locais(j)
                .Interior.Color = RGB(56, 98, 174)
                .Font.Color = RGB(217, 217, 217)
                .Font.Name = "Arial"
                .Font.Size = 9
                .Font.Bold = True
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
                
                .ColumnWidth = 10
                If Len(.Value) > 10 Then
                    .EntireColumn.AutoFit
                    If .ColumnWidth < 10 Then .ColumnWidth = 10
                End If

                With .Borders
                    .LineStyle = xlContinuous
                    .Color = RGB(217, 217, 217)
                    .Weight = xlThin
                End With
            End With
            col = col + 1
        Next j

        fimBloco = col - 1

        With ws.Range(ws.Cells(4, inicioBloco), ws.Cells(4, fimBloco))
            .Merge
            .Interior.Color = RGB(243, 243, 243)
            .Font.Name = "Arial"
            .Font.Size = 9
            .Font.Italic = True
            .Font.Color = RGB(133, 32, 12)
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .Value = "Obrigatorio"

            With .Borders
                .LineStyle = xlContinuous
                .Color = RGB(217, 217, 217)
                .Weight = xlThin
            End With
        End With

        With ws.Range(ws.Cells(5, inicioBloco), ws.Cells(5, fimBloco))
            .Merge
            .Interior.Color = RGB(243, 243, 243)
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .WrapText = True ' Habilita a quebra de linha
            .Value = "Distribua aqui as quantidades relacionadas ao codigo " & i & ". Somente numeros inteiros positivos com ate 5 digitos sao permitidos."
            .Font.Name = "Arial"
            .Font.Size = 8

            With .Borders
                .LineStyle = xlContinuous
                .Color = RGB(217, 217, 217)
                .Weight = xlThin
            End With
        End With
        
        Dim coresLinha6 As Variant
        coresLinha6 = Array( _
            RGB(241, 153, 93), _
            RGB(248, 203, 173), _
            RGB(255, 206, 51), _
            RGB(255, 230, 153), _
            RGB(198, 224, 180), _
            RGB(118, 181, 75), _
            RGB(172, 185, 202), _
            RGB(153, 193, 221), _
            RGB(175, 109, 167), _
            RGB(96, 62, 164) _
        )

        For j = inicioBloco To fimBloco
            With ws.Cells(6, j)
                .Interior.Color = coresLinha6(i - 1)
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
                .Value = ""

                With .Borders
                    .LineStyle = xlContinuous
                    .Color = RGB(217, 217, 217)
                    .Weight = xlThin
                End With
            End With
        Next j


    Next i

    ' Adicionar as colunas "Quantidade de Peças" e "Valor total" após a última coluna criada
    Dim ultimaColuna As Long
    ultimaColuna = fimBloco ' Usa a última coluna do último bloco criado

    ' Coluna "Quantidade de Peças"
    With ws.Cells(6, ultimaColuna + 1)
        .Value = "Quantidade de Pcs"
        .Interior.Color = RGB(198, 224, 180) ' Verde claro
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .ColumnWidth = 18
        
        With .Borders
            .LineStyle = xlContinuous
            .Color = RGB(217, 217, 217)
            .Weight = xlThin
        End With
    End With

    ' Coluna "Valor total"
    With ws.Cells(6, ultimaColuna + 2)
        .Value = "Valor total"
        .Interior.Color = RGB(153, 193, 221) ' Azul claro
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .ColumnWidth = 15
        
        With .Borders
            .LineStyle = xlContinuous
            .Color = RGB(217, 217, 217)
            .Weight = xlThin
        End With
    End With

    ' Aplicar formatação às linhas de título (3 a 5) para as novas colunas
    For i = 3 To 5
        With ws.Cells(i, ultimaColuna + 1)
            .Interior.Color = RGB(243, 243, 243)
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            
            With .Borders
                .LineStyle = xlContinuous
                .Color = RGB(217, 217, 217)
                .Weight = xlThin
            End With
        End With
        
        With ws.Cells(i, ultimaColuna + 2)
            .Interior.Color = RGB(243, 243, 243)
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            
            With .Borders
                .LineStyle = xlContinuous
                .Color = RGB(217, 217, 217)
                .Weight = xlThin
            End With
        End With
    Next i

    ' Coluna "Quantidade de Peças"
    With ws.Cells(6, ultimaColuna + 1)
        .Value = "Quantidade de Pcs"
        .Interior.Color = RGB(198, 224, 180) ' Verde claro
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .ColumnWidth = 18
        
        With .Borders
            .LineStyle = xlContinuous
            .Color = RGB(217, 217, 217)
            .Weight = xlThin
        End With
    End With

    ' Adicionar fórmula SUM para somar todas as colunas de filiais
    Dim primeiraColunaFilial As Long
    primeiraColunaFilial = 40 ' Coluna AN (ajuste conforme necessário)

    ' A fórmula irá somar da primeira coluna de filial até a última coluna criada
    ws.Range(ws.Cells(7, ultimaColuna + 1), ws.Cells(100, ultimaColuna + 1)).Formula = _
        "=SUM(" & ws.Cells(7, primeiraColunaFilial).Address(False, False) & ":" & ws.Cells(7, ultimaColuna).Address(False, False) & ")"

    ' Coluna "Valor total"
    With ws.Cells(6, ultimaColuna + 2)
        .Value = "Valor total"
        .Interior.Color = RGB(153, 193, 221) ' Azul claro
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .ColumnWidth = 15
        
        With .Borders
            .LineStyle = xlContinuous
            .Color = RGB(217, 217, 217)
            .Weight = xlThin
        End With
    End With

    ' Adicionar fórmula para Valor Total que multiplica V:AE pelos intervalos correspondentes
    Dim colValorTotal As Long
    colValorTotal = ultimaColuna + 2 ' Coluna do Valor Total

    ' Encontrar quantas filiais temos por grupo (countLocais)
    Dim filiaisPorGrupo As Long
    filiaisPorGrupo = countLocais ' Número de filiais retornadas da consulta SQL

    ' Definir a primeira coluna do primeiro grupo (AN = coluna 40)
    Dim primeiraColGrupo As Long
    primeiraColGrupo = 40 ' AN

    ' Aplicar a fórmula para cada linha (7 a 100)
    For linha = 7 To 100
        Dim formulaTotal As String
        formulaTotal = ""
        Dim colAtual As Long
        colAtual = primeiraColGrupo
        
        ' Construir a fórmula para cada grupo (10 grupos máximo - V até AE)
        For grupo = 1 To 10
            Dim colMultiplicadora As Long
            colMultiplicadora = 21 + grupo ' V=22, W=23, ..., AE=31
            
            ' Verificar se existe a coluna multiplicadora (não passar de AE)
            If colMultiplicadora <= 31 Then
                ' Calcular última coluna do grupo atual
                Dim ultimaColGrupo As Long
                ultimaColGrupo = colAtual + filiaisPorGrupo - 1
                
                ' Verificar se o grupo não ultrapassa a última coluna criada
                If colAtual <= ultimaColuna Then
                    If formulaTotal <> "" Then formulaTotal = formulaTotal & "+"
                    
                    ' Se for o último grupo, ajustar para não ultrapassar a última coluna
                    If ultimaColGrupo > ultimaColuna Then
                        ultimaColGrupo = ultimaColuna
                    End If
                    
                    ' Adicionar parte da fórmula: V*SUM(AN:BC), W*SUM(BD:BS), etc.
                    formulaTotal = formulaTotal & _
                        ws.Cells(linha, colMultiplicadora).Address(False, False) & _
                        "*SUM(" & ws.Cells(linha, colAtual).Address(False, False) & ":" & _
                        ws.Cells(linha, ultimaColGrupo).Address(False, False) & ")"
                    
                    ' Preparar para o próximo grupo
                    colAtual = ultimaColGrupo + 1
                End If
            End If
        Next grupo
        
        ' Aplicar a fórmula completa na célula de Valor Total
        If formulaTotal <> "" Then
            ws.Cells(linha, colValorTotal).Formula = "=" & formulaTotal
            ' Formatar como moeda (opcional)
            ws.Cells(linha, colValorTotal).NumberFormat = """R$"" #,##0.00"
        End If
    Next linha

    Exit Sub

ErroArquivo:
    MsgBox "Erro ao ler o arquivo de conexao: " & caminho, vbCritical
End Sub

Private Function ParseJson(JsonString As String) As Object
    On Error GoTo TratarErroJson

    Dim result As Object
    Set result = CreateObject("Scripting.Dictionary")

    JsonString = Replace(JsonString, "{", "")
    JsonString = Replace(JsonString, "}", "")
    JsonString = Replace(JsonString, """", "")
    JsonString = Replace(JsonString, vbCr, "")
    JsonString = Replace(JsonString, vbLf, "")
    JsonString = Trim(JsonString)

    Dim pairs() As String
    pairs = Split(JsonString, ",")

    Dim i As Integer
    For i = LBound(pairs) To UBound(pairs)
        Dim keyValue() As String
        keyValue = Split(pairs(i), ":")
        If UBound(keyValue) >= 1 Then
            result(Trim(keyValue(0))) = Trim(keyValue(1))
        End If
    Next i

    Set ParseJson = result
    Exit Function

TratarErroJson:
    MsgBox "Erro ao interpretar o JSON de conexao.", vbCritical
    Set ParseJson = Nothing
End Function
