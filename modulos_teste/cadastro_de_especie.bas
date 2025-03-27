Attribute VB_Name = "Módulo2"
Sub cadastro_de_especie()
    Dim objShell As Object
    Dim caminhoArquivo As String
    Dim caminhoPython As String
    Dim comando As String
    
    ' Obtém o caminho do arquivo Excel aberto
    caminhoArquivo = ThisWorkbook.FullName
    
    ' Descobre o caminho do Python dinamicamente
    caminhoPython = GetPythonPath()
    
    ' Verifica se o Python foi encontrado
    If caminhoPython = "" Then
        MsgBox "Python não encontrado! Certifique-se de que está instalado e no PATH.", vbCritical, "Erro"
        Exit Sub
    End If

    ' Monta o comando para chamar o script Python e passar o caminho do Excel como argumento
    comando = """" & caminhoPython & """ """ & ThisWorkbook.Path & "\Auto\db_esp.py"" """ & caminhoArquivo & """"
    
    ' Exibe o comando para depuração
    Debug.Print "Comando executado: " & comando
    
    ' Executa o comando
    Set objShell = CreateObject("WScript.Shell")
    objShell.Run comando, 1, True
    
    ' Libera o objeto
    Set objShell = Nothing
End Sub

Function GetPythonPath() As String
    Dim objShell As Object
    Dim objExec As Object
    Dim strOutput As String
    Dim pythonPath As String
    
    ' Executa "where python" no CMD para encontrar o caminho do Python
    Set objShell = CreateObject("WScript.Shell")
    Set objExec = objShell.Exec("cmd /c where python")
    
    ' Lê a saída do comando
    Do While Not objExec.StdOut.AtEndOfStream
        strOutput = objExec.StdOut.ReadLine
        If InStr(1, strOutput, "python.exe", vbTextCompare) > 0 Then
            pythonPath = strOutput
            Exit Do
        End If
    Loop
    
    ' Exibe o caminho do Python para depuração
    Debug.Print "Caminho do Python: " & pythonPath
    
    ' Retorna o caminho do Python
    GetPythonPath = pythonPath
    
    ' Libera os objetos
    Set objExec = Nothing
    Set objShell = Nothing
End Function

