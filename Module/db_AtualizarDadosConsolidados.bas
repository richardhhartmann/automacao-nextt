Attribute VB_Name = "db_AtualizarDadosConsolidados"
Option Explicit

Sub AtualizarDadosConsolidados()
    Dim conn As Object
    Dim ws As Worksheet
    Dim connStr As String
    Dim jsonConfig As Object
    Dim startTime As Double
    Dim fso As Object
    
    startTime = Timer
    
    frmAguarde.Show vbModeless
    DoEvents
    
    If Not CarregarConfiguracoes(jsonConfig) Then
        Unload frmAguarde
        Exit Sub
    End If
    
    connStr = MontarStringConexao(jsonConfig)
    If Not ConectarBanco(conn, connStr) Then
        Unload frmAguarde
        Exit Sub
    End If
    
    Set ws = ThisWorkbook.Sheets("Dados Consolidados")
    If ws Is Nothing Then
        MsgBox "Erro: planilha 'Dados Consolidados' nao encontrada.", vbCritical
        conn.Close
        Unload frmAguarde
        Exit Sub
    End If
    
    LimparIntervalosPlanilha ws
    
    ExecutarAtualizacoes conn, ws
    
    conn.Close
    Set conn = Nothing
    
    Call CriarIntervalosNomeadosB
    Unload frmAguarde
    
    Debug.Print "Tempo total de execuçao: " & Round(Timer - startTime, 2) & " segundos"
End Sub

Private Function CarregarConfiguracoes(ByRef jsonConfig As Object) As Boolean
    Dim caminhoArquivo As String
    Dim fso As Object
    Dim arquivo As Object
    Dim jsonText As String
    
    On Error GoTo ErroHandler
    
    caminhoArquivo = ThisWorkbook.Path & "\conexao_temp.txt"
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(caminhoArquivo) Then
        MsgBox "Arquivo de conexao nao encontrado!", vbExclamation
        Exit Function
    End If
    
    Set arquivo = fso.OpenTextFile(caminhoArquivo, 1)
    jsonText = arquivo.ReadAll
    arquivo.Close
    
    jsonText = Replace(jsonText, ": null", ": """"")
    jsonText = Replace(jsonText, ":null", ": """"")
    
    Set jsonConfig = JsonConverter.ParseJson(jsonText)
    
    If jsonConfig Is Nothing Then
        MsgBox "Erro ao converter JSON!", vbCritical
        Exit Function
    End If
    
    Debug.Print "Configuraçoes carregadas:"
    Debug.Print "Driver: " & jsonConfig("driver")
    Debug.Print "Server: " & jsonConfig("server")
    Debug.Print "Database: " & jsonConfig("database")
    Debug.Print "Username: " & jsonConfig("username")
    Debug.Print "Trusted Connection: " & jsonConfig("trusted_connection")
    
    CarregarConfiguracoes = True
    Exit Function
    
ErroHandler:
    MsgBox "Erro ao carregar configuraçoes: " & Err.Description, vbCritical
    CarregarConfiguracoes = False
End Function

Private Function MontarStringConexao(jsonConfig As Object) As String
    If LCase(jsonConfig("trusted_connection")) = "yes" Then
        MontarStringConexao = "Provider=SQLOLEDB;Server=" & jsonConfig("server") & _
                              ";Database=" & jsonConfig("database") & _
                              ";Integrated Security=SSPI;"
    Else
        MontarStringConexao = "Provider=SQLOLEDB;Server=" & jsonConfig("server") & _
                             ";Database=" & jsonConfig("database") & _
                             ";UID=" & jsonConfig("username") & _
                             ";PWD=" & jsonConfig("password") & ";"
    End If
End Function

Private Function ConectarBanco(ByRef conn As Object, connStr As String) As Boolean
    On Error GoTo ErroHandler
    
    Set conn = CreateObject("ADODB.Connection")
    conn.Open connStr
    
    ConectarBanco = True
    Exit Function
    
ErroHandler:
    MsgBox "Erro ao conectar ao banco de dados: " & Err.Description, vbCritical
    ConectarBanco = False
End Function

Private Sub LimparIntervalosPlanilha(ws As Worksheet)
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    With ws
        .Range("A1:A10070,B1:B10070,E1:E10070,R1:T10070,AR1:AS10070,AT1:AT10070,AV1:AW10070").ClearContents
    End With
    
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
End Sub

Private Sub ExecutarAtualizacoes(conn As Object, ws As Worksheet)
    ' Segmento
    AtualizarColuna conn, ws, "SELECT seg_descricao, seg_codigo FROM tb_segmento", Array(44, 45)
    
    ' Seção
    AtualizarColuna conn, ws, "SELECT CONCAT(sec_codigo, ' - ', sec_descricao), sec_descricao, sec_codigo FROM tb_secao", Array(1, 48, 18)
    
    ' Espécie
    AtualizarColuna conn, ws, "SELECT CAST(esp_codigo AS VARCHAR) + ' - ' + LTRIM(SUBSTRING(esp_descricao, PATINDEX('%[A-Z]%', esp_descricao), LEN(esp_descricao))), " & _
                              "LTRIM(SUBSTRING(esp_descricao, PATINDEX('%[A-Z]%', esp_descricao), LEN(esp_descricao))), " & _
                              "CAST(esp_codigo AS VARCHAR) FROM tb_especie", Array(2, 49, 19)
    
    ' Marca
    AtualizarColuna conn, ws, "SELECT CONCAT(mar_codigo, ' - ', mar_descricao), mar_descricao, mar_codigo FROM tb_marca", Array(5, 46, 20)
End Sub

Private Sub AtualizarColuna(conn As Object, ws As Worksheet, query As String, colunas As Variant)
    Dim rs As Object
    Dim linha As Long
    Dim i As Integer
    Dim startTime As Double
    
    On Error GoTo ErroHandler
    
    startTime = Timer
    
    Set rs = conn.Execute(query)
    
    If rs Is Nothing Or rs.State = 0 Then
        MsgBox "Erro: consulta SQL falhou.", vbCritical
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    linha = 1
    Do While Not rs.EOF
        For i = LBound(colunas) To UBound(colunas)
            If i <= rs.Fields.Count - 1 Then
                ws.Cells(linha, colunas(i)).Value = rs.Fields(i).Value
            End If
        Next i
        linha = linha + 1
        rs.MoveNext
    Loop
    
    Debug.Print "Consulta '" & Left(query, 30) & "...' concluida em " & Round(Timer - startTime, 2) & "s"
    
Finalizar:
    If Not rs Is Nothing Then
        If rs.State = 1 Then rs.Close
        Set rs = Nothing
    End If
    
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Exit Sub
    
ErroHandler:
    MsgBox "Erro em AtualizarColuna: " & Err.Description, vbCritical
    Resume Finalizar
End Sub