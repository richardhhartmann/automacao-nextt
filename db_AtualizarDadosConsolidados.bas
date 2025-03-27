Sub AtualizarDadosConsolidados()
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
    
    driver = "SQL Server Native Client 11.0"
    server = "localhost"
    database = "NexttLoja"
    username = "sa"
    password = ""

    connStr = "Provider=SQLOLEDB;Server=localhost;Database=NexttLoja;Integrated Security=SSPI;"

    Set conn = CreateObject("ADODB.Connection")

    On Error Resume Next
    conn.Open connStr
    
    On Error GoTo 0

    Set ws = ThisWorkbook.Sheets("Dados Consolidados")
    
    query1 = "SELECT seg_descricao FROM tb_segmento"
    query2 = "SELECT seg_codigo FROM tb_segmento"
    query3 = "SELECT sec_codigo FROM tb_secao"
    query4 = "SELECT CONCAT(sec_codigo, ' - ', sec_descricao) AS descricao_completa FROM tb_secao"
    query5 = "SELECT sec_descricao FROM tb_secao"
    query6 = "SELECT CAST(esp_codigo AS VARCHAR) AS descricao_completa FROM tb_especie"
    query7 = "SELECT CAST(esp_codigo AS VARCHAR) + ' - ' + LTRIM(SUBSTRING(esp_descricao, PATINDEX('%[A-Z]%', esp_descricao), LEN(esp_descricao))) AS descricao_completa FROM tb_especie"
    query8 = "SELECT LTRIM(SUBSTRING(esp_descricao, PATINDEX('%[A-Z]%', esp_descricao), LEN(esp_descricao))) AS descricao FROM tb_especie"
    query9 = "SELECT CONCAT(mar_codigo, ' - ', mar_descricao) AS descricao_completa FROM tb_marca"
    query10 = "SELECT mar_codigo FROM tb_marca"
    query11 = "SELECT mar_descricao from tb_marca"
    
    ws.Range("A1:A10000, B1:B10000, E1:E10000, R1:R10000, S1:S10000, T1:T10000, AR1:AR10000, AS1:AS10000, AT1:AT10000, AV1:AV10000, AW1:AW10000").ClearContents
    
    linha = 1
    Set rs = conn.Execute(query1)
    Do While Not rs.EOF
        ws.Cells(linha, 44).Value = rs.Fields(0).Value
        linha = linha + 1
        rs.MoveNext
    Loop
    rs.Close

    linha = 1
    codigo = 1
    Set rs = conn.Execute(query2)
    Do While Not rs.EOF
        ws.Cells(linha, 45).Value = codigo
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query3)
    Do While Not rs.EOF
        ws.Cells(linha, 18).Value = codigo
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query4)
    Do While Not rs.EOF
        ws.Cells(linha, 1).Value = rs.Fields(0).Value
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query5)
    Do While Not rs.EOF
        ws.Cells(linha, 48).Value = rs.Fields(0).Value
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query6)
    Do While Not rs.EOF
        ws.Cells(linha, 19).Value = codigo
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query7)
    Do While Not rs.EOF
        ws.Cells(linha, 2).Value = rs.Fields(0).Value
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query8)
    Do While Not rs.EOF
        ws.Cells(linha, 49).Value = rs.Fields(0).Value
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query9)
    Do While Not rs.EOF
        ws.Cells(linha, 5).Value = rs.Fields(0).Value
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query10)
    Do While Not rs.EOF
        ws.Cells(linha, 20).Value = rs.Fields(0).Value
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    linha = 1
    codigo = 1
    Set rs = conn.Execute(query11)
    Do While Not rs.EOF
        ws.Cells(linha, 46).Value = rs.Fields(0).Value
        linha = linha + 1
        codigo = codigo + 1
        rs.MoveNext
    Loop
    rs.Close
    
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    
    Call CriarIntervalosNomeadosB
    MsgBox "Dados atualizados com sucesso!", vbInformation
    
End Sub