Attribute VB_Name = "Módulo7"
Sub AtualizarDadosConsolidadosSecao()
    Dim conn As Object
    Dim rs As Object
    Dim ws As Worksheet
    Dim query1 As String, query2 As String, query3 As String
    Dim linha As Long
    Dim connStr As String
    Dim driver As String
    Dim server As String
    Dim database As String
    Dim username As String
    Dim password As String
    
    ' Configuração da conexão
    driver = "SQL Server Native Client 11.0"
    server = "localhost"
    database = "NexttLoja"
    username = "sa"
    password = "" ' Sem senha

    ' Criar a string de conexão
    connStr = "Provider=SQLOLEDB;Server=localhost;Database=NexttLoja;Integrated Security=SSPI;"

    ' Criar objeto de conexão
    Set conn = CreateObject("ADODB.Connection")

    ' Tenta abrir a conexão e exibe mensagem
    On Error Resume Next
    conn.Open connStr
    
    On Error GoTo 0

    ' Definir planilha onde os dados serão inseridos
    Set ws = ThisWorkbook.Sheets("Dados Consolidados")
    
    ' Definir consultas SQL
    query1 = "SELECT sec_codigo FROM tb_secao"
    query2 = "SELECT CONCAT(sec_codigo, ' - ', sec_descricao) AS descricao_completa FROM tb_secao"
    query3 = "SELECT sec_descricao FROM tb_secao"
    
    ' Limpar colunas antes de inserir novos valores
    ws.Range("A1:A10000, R1:R10000, AV1:AV10000").ClearContents
    
    ' Preencher a coluna S com a primeira query
    linha = 1
    Set rs = conn.Execute(query1)
    Do While Not rs.EOF
        ws.Cells(linha, 18).Value = rs.Fields(0).Value ' Coluna S = 19ª coluna
        linha = linha + 1
        rs.MoveNext
    Loop
    rs.Close
    
    ' Preencher a coluna B com a segunda query
    linha = 1
    Set rs = conn.Execute(query2)
    Do While Not rs.EOF
        ws.Cells(linha, 1).Value = rs.Fields(0).Value
        linha = linha + 1
        rs.MoveNext
    Loop
    rs.Close
    
    ' Preencher a coluna AW com a terceira query
    linha = 1
    Set rs = conn.Execute(query3)
    Do While Not rs.EOF
        ws.Cells(linha, 48).Value = rs.Fields(0).Value
        linha = linha + 1
        rs.MoveNext
    Loop
    rs.Close
    
    ' Fechar conexão
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    
    Call CriarIntervalosNomeadosB
    MsgBox "Dados atualizados com sucesso!", vbInformation
    
End Sub

