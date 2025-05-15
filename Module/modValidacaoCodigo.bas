Attribute VB_Name = "modValidacaoCodigo"
Option Explicit

Dim codigosValidos As Collection

Sub CarregarCodigosValidos()
    Dim fso As Object, arquivo As Object
    Dim jsonText As String, json As Object
    Dim conn As Object, rs As Object
    Dim sql As String
    
    Set codigosValidos = New Collection

    ' Ler JSON
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set arquivo = fso.OpenTextFile(ThisWorkbook.Path & "\conexao_temp.txt", 1)
    jsonText = arquivo.ReadAll
    arquivo.Close
    Set json = JsonConverter.ParseJson(jsonText)

    ' Conexão com banco
    Set conn = CreateObject("ADODB.Connection")
    conn.connectionString = "Driver={" & json("driver") & "};" & _
                            "Server=" & json("server") & ";Database=" & json("database") & ";" & _
                            IIf(json("trusted_connection") = "yes", "Trusted_Connection=Yes;", _
                            "Uid=" & json("username") & ";Pwd=" & json("password") & ";")
    conn.Open

    ' Consulta SQL
    sql = "SELECT Codigo FROM vw_sync_foto_produto"
    Set rs = conn.Execute(sql)

    Do While Not rs.EOF
        codigosValidos.Add CStr(rs.Fields("Codigo").Value)
        rs.MoveNext
    Loop

    rs.Close
    conn.Close
End Sub

Function CodigoExiste(cod As String) As Boolean
    Dim item As Variant
    On Error GoTo NotFound
    item = codigosValidos(cod)
    CodigoExiste = True
    Exit Function
NotFound:
    CodigoExiste = False
End Function


