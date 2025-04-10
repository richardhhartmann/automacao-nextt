Attribute VB_Name = "db_cadastro_de_segmento"
Sub cadastro_de_segmento()
    Dim objShell As Object
    Dim caminhoArquivo As String
    Dim caminhoPython As String
    Dim comando As String
    Dim ws As Worksheet
    Dim celula As Range
    Dim temValor As Boolean
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Segmento")
    For Each celula In ws.Range("A7:A200")
        If Trim(celula.Value) <> "" Then
            temValor = True
            Exit For
        End If
    Next celula
    
    If Not temValor Then
        MsgBox "Nenhum valor encontrado para ser cadastrado.", vbExclamation, "Aviso"
        Exit Sub
    End If

    caminhoArquivo = ThisWorkbook.FullName
    
    caminhoPython = GetPythonPath()
    
    If caminhoPython = "" Then
        MsgBox "Python nao encontrado! Certifique-se de que esta instalado e no PATH.", vbCritical, "Erro"
        Exit Sub
    End If

    comando = """" & caminhoPython & """ """ & ThisWorkbook.Path & "\Auto\db_seg.py"" """ & caminhoArquivo & """"
    
    Debug.Print "Comando executado: " & comando
    
    Set objShell = CreateObject("WScript.Shell")
    objShell.Run comando, 1, True
    
    Set objShell = Nothing
    Call AtualizarDadosConsolidados
End Sub

Function GetPythonPath() As String
    Dim objShell As Object
    Dim objExec As Object
    Dim strOutput As String
    Dim pythonPath As String
    
    Set objShell = CreateObject("WScript.Shell")
    Set objExec = objShell.Exec("cmd /c where python")
    
    Do While Not objExec.StdOut.AtEndOfStream
        strOutput = objExec.StdOut.ReadLine
        If InStr(1, strOutput, "python.exe", vbTextCompare) > 0 Then
            pythonPath = strOutput
            Exit Do
        End If
    Loop
    
    Debug.Print "Caminho do Python: " & pythonPath
    
    GetPythonPath = pythonPath
    
    Set objExec = Nothing
    Set objShell = Nothing
End Function

