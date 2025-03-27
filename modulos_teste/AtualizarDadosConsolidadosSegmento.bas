Attribute VB_Name = "Módulo10"
Sub AtualizarDadosConsolidadosSegmento()
    Dim conn As Object
    Dim rs As Object
    Dim ws As Worksheet
    Dim query1 As String, query2 As String
    Dim linha As Long
    Dim connStr As String
    Dim driver As String
    Dim server As String
    Dim database As String
    Dim username As String
    Dim password As String
    Dim codigo As Long
    
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
    query1 = "SELECT seg_descricao FROM tb_segmento"
    query2 = "SELECT seg_codigo FROM tb_segmento"
    
    ' Limpar colunas antes de inserir novos valores
    ws.Range("AR1:AR10000, AS1:AS10000").ClearContents
    
    ' Preencher a coluna AR com as descrições
    linha = 1
    Set rs = conn.Execute(query1)
    Do While Not rs.EOF
        ws.Cells(linha, 44).Value = rs.Fields(0).Value
        linha = linha + 1
        rs.MoveNext
    Loop
    rs.Close

    ' Preencher a coluna AS com os códigos começando de 1
    linha = 1
    codigo = 1 ' Começar do código 1
    Set rs = conn.Execute(query2)
    Do While Not rs.EOF
        ws.Cells(linha, 45).Value = codigo
        linha = linha + 1
        codigo = codigo + 1 ' Incrementar o código
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



