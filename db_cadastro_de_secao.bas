Attribute VB_Name = "db_cadastro_de_secao"
Sub cadastro_de_secao()
    Dim objShell As Object
    Dim caminhoArquivo As String
    Dim caminhoPython As String
    Dim comando As String
    
    caminhoArquivo = ThisWorkbook.FullName
    
    caminhoPython = GetPythonPath()
    
    If caminhoPython = "" Then
        MsgBox "Python nao encontrado! Certifique-se de que esta instalado e no PATH.", vbCritical, "Erro"
        Exit Sub
    End If

    comando = """" & caminhoPython & """ """ & ThisWorkbook.Path & "\Auto\db_sec.py"" """ & caminhoArquivo & """"
    
    Debug.Print "Comando executado: " & comando
    
    Set objShell = CreateObject("WScript.Shell")
    objShell.Run comando, 1, True
    
    Set objShell = Nothing
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
