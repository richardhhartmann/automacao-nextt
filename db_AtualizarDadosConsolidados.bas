Attribute VB_Name = "db_AtualizarDadosConsolidados"
Sub AtualizarDadosConsolidados()
    Dim conn As Object
    Dim rs As Object
    Dim ws As Worksheet
    Dim query As String
    Dim linha As Long
    Dim connStr As String
    Dim caminhoArquivo As String
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

    caminhoArquivo = ThisWorkbook.Path & "\conexao_temp.txt"

    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(caminhoArquivo) Then
        MsgBox "Arquivo de conexÃ£o nÃ£o encontrado!", vbExclamation
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

    Debug.Print "Driver: " & driver
    Debug.Print "Server: " & server
    Debug.Print "Database: " & database
    Debug.Print "Username: " & username
    Debug.Print "Password: " & password
    Debug.Print "Trusted Connection: " & trusted_connection

    ' Deleta o arquivo temporario
    ' fso.DeleteFile caminhoArquivo, True

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

    Set ws = ThisWorkbook.Sheets("Dados Consolidados")
    If ws Is Nothing Then
        MsgBox "Erro: planilha 'Dados Consolidados' nao encontrada.", vbCritical
        conn.Close
        Exit Sub
    End If

    ws.Range("A1:A10000").ClearContents
    ws.Range("B1:B10000").ClearContents
    ws.Range("E1:E10000").ClearContents
    ws.Range("R1:R10000").ClearContents
    ws.Range("S1:S10000").ClearContents
    ws.Range("T1:T10000").ClearContents
    ws.Range("AR1:AR10000").ClearContents
    ws.Range("AS1:AS10000").ClearContents
    ws.Range("AT1:AT10000").ClearContents
    ws.Range("AV1:AV10000").ClearContents
    ws.Range("AW1:AW10000").ClearContents

    AtualizarColuna conn, ws, "SELECT seg_descricao FROM tb_segmento", 44
    AtualizarColunaComCodigo conn, ws, "SELECT seg_codigo FROM tb_segmento", 45
    AtualizarColunaComCodigo conn, ws, "SELECT sec_codigo FROM tb_secao", 18
    AtualizarColuna conn, ws, "SELECT CONCAT(sec_codigo, ' - ', sec_descricao) AS descricao_completa FROM tb_secao", 1
    AtualizarColuna conn, ws, "SELECT sec_descricao FROM tb_secao", 48
    AtualizarColunaComCodigo conn, ws, "SELECT CAST(esp_codigo AS VARCHAR) AS descricao_completa FROM tb_especie ORDER BY (SELECT NULL)", 19
    AtualizarColuna conn, ws, "SELECT CAST(esp_codigo AS VARCHAR) + ' - ' + LTRIM(SUBSTRING(esp_descricao, PATINDEX('%[A-Z]%', esp_descricao), LEN(esp_descricao))) AS descricao_completa FROM tb_especie", 2
    AtualizarColuna conn, ws, "SELECT LTRIM(SUBSTRING(esp_descricao, PATINDEX('%[A-Z]%', esp_descricao), LEN(esp_descricao))) AS descricao FROM tb_especie", 49
    AtualizarColuna conn, ws, "SELECT CONCAT(mar_codigo, ' - ', mar_descricao) AS descricao_completa FROM tb_marca", 5
    AtualizarColuna conn, ws, "SELECT mar_codigo FROM tb_marca", 20
    AtualizarColuna conn, ws, "SELECT mar_descricao FROM tb_marca", 46

    conn.Close
    Set rs = Nothing
    Set conn = Nothing

    Call CriarIntervalosNomeadosB
End Sub

Sub AtualizarColuna(conn As Object, ws As Worksheet, query As String, coluna As Integer)
    Dim rs As Object
    Dim linha As Long
    linha = 1

    Set rs = conn.Execute(query)
    
    If rs Is Nothing Then
        MsgBox "Erro: consulta SQL falhou.", vbCritical
        Exit Sub
    End If
    
    Do While Not rs.EOF
        ws.Cells(linha, coluna).Value = rs.Fields(0).Value
        linha = linha + 1
        rs.MoveNext
    Loop
    
    rs.Close
End Sub

Sub AtualizarColunaComCodigo(conn As Object, ws As Worksheet, query As String, coluna As Integer)
    Dim rs As Object
    Dim linha As Long
    linha = 1

    Set rs = conn.Execute(query)
    
    If rs Is Nothing Then
        MsgBox "Erro: consulta SQL falhou.", vbCritical
        Exit Sub
    End If

    Do While Not rs.EOF
        ws.Cells(linha, coluna).Value = rs.Fields(0).Value
        linha = linha + 1
        rs.MoveNext
    Loop

    rs.Close
End Sub

