Attribute VB_Name = "PreencherCelulasComAtributos"
Sub PreencherCelulasComAtributos()
    Dim conn As Object
    Dim rs As Object
    Dim ws As Worksheet
    Dim query As String
    Dim connStr As String
    Dim driver As String
    Dim server As String
    Dim database As String
    Dim username As String
    Dim password As String
    Dim trusted_connection As String
    Dim fso As Object
    Dim arquivo As Object
    Dim jsonText As String
    Dim json As Object
    Dim caminhoArquivo As String
    Dim colunaInicial As Integer
    Dim ultimaColuna As Integer
    Dim qtdValores As Integer
    Dim i As Integer
    Dim j As Long
    Dim espacoSuficiente As Boolean

    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")

    caminhoArquivo = ThisWorkbook.Path & "\conexao_temp.txt"

    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(caminhoArquivo) Then
        MsgBox "Arquivo de conexao nao encontrado!", vbExclamation
        Exit Sub
    End If

    Set arquivo = fso.OpenTextFile(caminhoArquivo, 1)
    jsonText = arquivo.ReadAll
    arquivo.Close

    jsonText = Replace(jsonText, ": null", ": """"")
    jsonText = Replace(jsonText, ":null", ": """"")

    Set json = JsonConverter.ParseJson(jsonText)
    If json Is Nothing Then
        MsgBox "Erro ao converter JSON!", vbCritical
        Exit Sub
    End If

    driver = json("driver")
    server = json("server")
    database = json("database")
    username = json("username")
    password = json("password")
    trusted_connection = json("trusted_connection")

    If trusted_connection = "yes" Then
        connStr = "Provider=SQLOLEDB;Server=" & server & ";Database=" & database & ";Integrated Security=SSPI;"
    Else
        connStr = "Provider=SQLOLEDB;Server=" & server & ";Database=" & database & ";UID=" & username & ";PWD=" & password & ";"
    End If

    Set conn = CreateObject("ADODB.Connection")

    On Error Resume Next
    conn.Open connStr
    If Err.Number <> 0 Then
        MsgBox "Erro ao conectar ao banco de dados: " & Err.Description, vbCritical
        Exit Sub
    End If
    On Error GoTo 0

    If conn Is Nothing Then
        MsgBox "Erro: conexao nao foi inicializada.", vbCritical
        Exit Sub
    End If

    query = "SELECT tpa_descricao FROM tb_tipo_atributo WHERE tpa_codigo > 2 AND tba_codigo = 1 AND tpa_ordem = 0"

    Set rs = conn.Execute(query)

    qtdValores = 0
    If Not rs.EOF Then
        rs.MoveFirst
        Do While Not rs.EOF
            qtdValores = qtdValores + 1
            rs.MoveNext
        Loop
    End If

    If qtdValores > 0 Then
        colunaInicial = 56
        ultimaColuna = colunaInicial + qtdValores - 1
        
        espacoSuficiente = False
        For j = colunaInicial To ws.Columns.Count - qtdValores
            espacoSuficiente = True
            For i = 0 To qtdValores - 1
                If ws.Cells(3, j + i).Value <> "" Then
                    espacoSuficiente = False
                    Exit For
                End If
            Next i
            If espacoSuficiente Then
                colunaInicial = j
                ultimaColuna = colunaInicial + qtdValores - 1
                Exit For
            End If
        Next j
        
        If Not espacoSuficiente Then
            ws.Columns(colunaInicial).Resize(, qtdValores).Insert Shift:=xlToRight
        End If

        With ws.Range(ws.Cells(1, 18), ws.Cells(2, ultimaColuna))
            .Merge
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .Font.Bold = True
            .Value = "Atributos"
            
            With .Borders
                .LineStyle = xlContinuous
                .Weight = xlThin
                .Color = RGB(217, 217, 217)
            End With
        End With
        
        rs.MoveFirst
        
        For i = 0 To qtdValores - 1
            If Not rs.EOF Then
                With ws.Cells(3, colunaInicial + i)
                    If .Value = "" Then
                        .Value = rs.Fields(0).Value
                        .Font.Bold = True
                        .Interior.Color = RGB(142, 169, 219)
                        .HorizontalAlignment = xlCenter
                        .VerticalAlignment = xlCenter
                        
                        With .Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                            .Color = RGB(217, 217, 217)
                        End With
                    End If
                End With

                With ws.Cells(4, colunaInicial + i)
                    .Interior.Color = RGB(243, 243, 243)
                    With .Borders
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .Color = RGB(217, 217, 217)
                    End With
                End With

                With ws.Range(ws.Cells(5, colunaInicial + i), ws.Cells(6, colunaInicial + i))
                    .Merge
                    .Value = "Maximo 50 caracteres." 
                    .Interior.Color = RGB(243, 243, 243)
                    .HorizontalAlignment = xlCenter
                    .VerticalAlignment = xlCenter
                    With .Font
                        .Name = "Arial"
                        .Size = 8
                        .Color = RGB(0, 0, 0)
                        .Italic = False
                    End With
                    
                    With .Borders
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .Color = RGB(217, 217, 217)
                    End With
                End With
                
                rs.MoveNext
            End If
        Next i
        
        ws.Columns(colunaInicial).Resize(, qtdValores).ColumnWidth = 20
    End If

    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
End Sub

