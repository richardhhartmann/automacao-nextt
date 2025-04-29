VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsDBListener"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' M�dulo de classe clsDBListener (vers�o para m�ltiplas tabelas)
'-----------------------------------------------------
Private conn As ADODB.Connection
Private tableCounts As Collection ' Armazena as �ltimas contagens por tabela
Private tableNames As Collection ' Nomes das tabelas a monitorar
Private macroNames As Collection ' Macros correspondentes a cada tabela
Private configPath As String
Private nextCheckTime As Date
Private isActive As Boolean

Public Sub Initialize(configFilePath As String, tables As Variant, macros As Variant)
    On Error GoTo ErroInicializacao
    
    configPath = configFilePath
    isActive = True
    
    ' Inicializa as cole��es
    Set tableCounts = New Collection
    Set tableNames = New Collection
    Set macroNames = New Collection
    
    ' Adiciona tabelas e macros �s cole��es
    Dim i As Integer
    For i = LBound(tables) To UBound(tables)
        tableNames.Add tables(i)
        macroNames.Add macros(i)
        tableCounts.Add -1, tables(i) ' Valor inicial
    Next i

    ' Carrega configura��es
    Dim fso As Object, jsonText As String, json As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    jsonText = fso.OpenTextFile(configPath).ReadAll
    jsonText = Replace(jsonText, ": null", ": """"")
    jsonText = Replace(jsonText, ":null", ": """"")
    Set json = JsonConverter.ParseJson(jsonText)

    ' String de conex�o
    Dim connStr As String
    If LCase(json("trusted_connection")) = "yes" Then
        connStr = "Driver={" & json("driver") & "};" & _
                "Server=" & json("server") & ";" & _
                "Database=" & json("database") & ";" & _
                "Trusted_Connection=yes;"
    Else
        connStr = "Driver={" & json("driver") & "};" & _
                "Server=" & json("server") & ";" & _
                "Database=" & json("database") & ";" & _
                "Uid=" & json("username") & ";" & _
                "Pwd=" & json("password") & ";"
    End If

    ' Conecta ao banco
    Set conn = New ADODB.Connection
    conn.Open connStr
    
    ' Obt�m a contagem inicial de registros para cada tabela
    For i = 1 To tableNames.Count
        tableCounts.Remove tableNames(i)
        tableCounts.Add GetRecordCount(tableNames(i)), tableNames(i)
        Debug.Print "Monitoramento iniciado para " & tableNames(i) & ". Quantidade inicial: " & tableCounts(tableNames(i)) & " registros"
    Next i
    
    ' Agenda a primeira verifica��o
    ScheduleNextCheck
    
    Exit Sub
    
ErroInicializacao:
    MsgBox "Erro na inicializa��o: " & Err.Description, vbCritical
    isActive = False
End Sub

Private Function GetRecordCount(tableName As String) As Long
    On Error GoTo ErroContagem
    Dim rs As ADODB.Recordset
    Set rs = conn.Execute("SELECT COUNT(*) FROM " & tableName)
    GetRecordCount = rs.Fields(0).Value
    rs.Close
    Exit Function
    
ErroContagem:
    GetRecordCount = -1
    If Not rs Is Nothing Then rs.Close
End Function

Private Sub ScheduleNextCheck()
    If Not isActive Then Exit Sub
    
    nextCheckTime = Now + TimeSerial(0, 0, 10)
    Application.OnTime nextCheckTime, "CheckDBChange"
End Sub

Public Sub CheckForChanges()
    If Not isActive Then Exit Sub
    
    On Error GoTo ErroVerificacao
    
    If conn.State <> 1 Then conn.Open
    
    Dim currentCount As Long
    Dim i As Integer
    
    For i = 1 To tableNames.Count
        Dim tableName As String
        tableName = tableNames(i)
        
        currentCount = GetRecordCount(tableName)
        
        Debug.Print "Verificacao em " & Now & " | Tabela: " & tableName & " | Registros: " & currentCount & " | Ultima contagem: " & tableCounts(tableName)
        
        If currentCount <> tableCounts(tableName) Then
            tableCounts.Remove tableName
            tableCounts.Add currentCount, tableName
            Debug.Print "Mudanca na tabela " & tableName & " detectada! Executando macro " & macroNames(i)
            Application.Run macroNames(i)
        End If
    Next i
    
    ScheduleNextCheck
    Exit Sub
    
ErroVerificacao:
    Debug.Print "Erro na verifica��o: " & Err.Description
    ' Tenta reconectar na pr�xima verifica��o
    If Not conn Is Nothing Then
        If conn.State = 1 Then conn.Close
    End If
    Set conn = Nothing
    
    ' Reconstruir arrays para reinicializa��o
    Dim tables() As String, macros() As String
    ReDim tables(1 To tableNames.Count)
    ReDim macros(1 To macroNames.Count)
    
    For i = 1 To tableNames.Count
        tables(i) = tableNames(i)
        macros(i) = macroNames(i)
    Next i
    
    Initialize configPath, tables, macros
End Sub

Public Sub Terminate()
    On Error Resume Next
    isActive = False
    Application.OnTime earliestTime:=nextCheckTime, procedure:="CheckDBChange", schedule:=False
    If Not conn Is Nothing Then
        If conn.State = 1 Then conn.Close
        Set conn = Nothing
    End If
    Debug.Print "Monitoramento parado"
End Sub

