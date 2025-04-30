Attribute VB_Name = "CheckDB"
Public dbListener As clsDBListener

Sub StartDBMonitoring()
    Dim tables(1 To 4) As String
    Dim macros(1 To 4) As String
    
    tables(1) = "tb_marca"
    macros(1) = "AtualizarInterface.AtualizarInterface"
    
    tables(2) = "tb_secao"
    macros(2) = "AtualizarInterface.AtualizarInterface"

    tables(3) = "tb_especie"
    macros(3) = "AtualizarInterface.AtualizarInterface"

    tables(4) = "tb_segmento"
    macros(4) = "AtualizarInterface.AtualizarInterface"
    
    Set dbListener = New clsDBListener
    dbListener.Initialize ThisWorkbook.Path & "\conexao_temp.txt", tables, macros
End Sub

Sub CheckDBChange()
    On Error Resume Next
    If Not dbListener Is Nothing Then
        dbListener.CheckForChanges
    End If
End Sub