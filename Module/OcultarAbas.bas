Attribute VB_Name = "OcultarAbasProtegidas"
Public Sub OcultarAbasProtegidas()
    On Error Resume Next
    Dim abasParaOcultar As Variant
    abasParaOcultar = Array("Cadastro de Segmento", "Cadastro de Secao", "Cadastro de Especie", "Dados Consolidados")
    
    Dim ws As Worksheet
    Dim nomeAba As Variant
    Dim wsNextt As Worksheet
    
    For Each nomeAba In abasParaOcultar
        Set ws = ThisWorkbook.Sheets(nomeAba)
        If Not ws Is Nothing Then
            ws.Visible = xlSheetVeryHidden
        End If
    Next nomeAba
    
    Set wsNextt = ThisWorkbook.Sheets("Nextt")
    For Each celula In wsNextt.Range("B13:B17")
        If celula.MergeCells Then
            celula.MergeArea.ClearContents
        Else
            celula.ClearContents
        End If
    Next celula
    
    On Error GoTo 0
End Sub

Public Sub MostrarAbasComSenha()
    Dim senha As String
    senha = InputBox("Digite a senha para acessar as abas ocultas:", "Acesso Restrito")
    
    If senha = "nexttsol" Then
        On Error Resume Next
        ThisWorkbook.Sheets("Cadastro de Segmento").Visible = xlSheetVisible
        ThisWorkbook.Sheets("Cadastro de Secao").Visible = xlSheetVisible
        ThisWorkbook.Sheets("Cadastro de Especie").Visible = xlSheetVisible
        ThisWorkbook.Sheets("Dados Consolidados").Visible = xlSheetVisible
        On Error GoTo 0
        MsgBox "Abas liberadas!", vbInformation
    Else
        MsgBox "Senha incorreta!", vbCritical
    End If
End Sub