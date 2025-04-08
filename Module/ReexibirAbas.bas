Attribute VB_Name = "ReexibirAbas"
Sub ReexibirAbas()
    Dim abasParaReexibir As Variant
    Dim ws As Worksheet
    Dim i As Integer
    
    abasParaReexibir = Array("Cadastro de Segmento", "Cadastro de Secao", "Cadastro de Especie", "Dados Consolidados")

    frmSenha.Show
    
    If frmSenha.senhaCorreta Then
        For i = LBound(abasParaReexibir) To UBound(abasParaReexibir)
            On Error Resume Next
            Set ws = ThisWorkbook.Sheets(abasParaReexibir(i))
            If Not ws Is Nothing Then
                ws.Visible = xlSheetVisible
            End If
            On Error GoTo 0
        Next i
        
        MsgBox "Acesso concedido!", vbInformation
        ThisWorkbook.Sheets(abasParaReexibir(0)).Select
    Else
        MsgBox "Acesso negado.", vbCritical
    End If
    
    Unload frmSenha
End Sub
