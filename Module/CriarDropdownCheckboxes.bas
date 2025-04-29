Attribute VB_Name = "CriarDropdownCheckboxes"
Sub CriarDropdownCheckboxes()
    Dim conn As Object
    Dim rs As Object
    Dim ws As Worksheet
    Dim strConexao As String
    Dim strSQL As String
    Dim i As Long
    Dim listBox As Object
    Dim json As Object
    Dim fso As Object
    Dim arquivo As Object
    Dim caminhoArquivo As String
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    
    On Error Resume Next 
    Set listBox = ws.OLEObjects("ListBox1").Object
    On Error GoTo 0 
    
    If listBox Is Nothing Then
        Set listBox = ws.OLEObjects.Add(ClassType:="Forms.ListBox.1", _
                                        Left:=100, Top:=100, Width:=150, Height:=100).Object
        listBox.Name = "ListBox1" 
    End If
    
    listBox.MultiSelect = fmMultiSelectExtended
    
    caminhoArquivo = ThisWorkbook.Path & "\conexao_temp.txt"
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If fso.FileExists(caminhoArquivo) Then
        Set arquivo = fso.OpenTextFile(caminhoArquivo, 1)
        Dim conteudo As String
        conteudo = arquivo.ReadAll
        arquivo.Close
        
        Set json = JsonConverter.ParseJson(conteudo)
        
        strConexao = "Driver=" & json("driver") & ";" & _
                     "Server=" & json("server") & ";" & _
                     "Database=" & json("database") & ";" & _
                     "Uid=" & json("username") & ";" & _
                     "Pwd=" & json("password") & ";" & _
                     "Trusted_Connection=" & json("trusted_connection") & ";"
        
    Else
        MsgBox "O arquivo 'conexao_temp.txt' nao foi encontrado.", vbCritical
        Exit Sub
    End If
    
    strSQL = "SELECT tid_descricao FROM tb_tipo_documento"
    
    Set conn = CreateObject("ADODB.Connection")
    Set rs = CreateObject("ADODB.Recordset")
    
    conn.Open strConexao
    rs.Open strSQL, conn, 1, 3
    
    listBox.Clear
    
    i = 1
    Do While Not rs.EOF
        listBox.AddItem rs.Fields("tid_descricao").Value
        i = i + 1
        rs.MoveNext
    Loop
    
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    
End Sub
