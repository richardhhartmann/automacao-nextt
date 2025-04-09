Attribute VB_Name = "ReexibirAbas"
Sub ReexibirAbas()
    Dim abasParaReexibir As Variant
    Dim ws As Worksheet
    Dim i As Integer
    Dim wsNextt As Worksheet
    
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
        ThisWorkbook.Sheets("Nextt").Select
        
        Set wsNextt = ThisWorkbook.Sheets("Nextt")
        
        With wsNextt.Range("B13")
            .Value = "Operador:"
            .Font.Color = RGB(38, 38, 38)
            .Font.Name = "Arial"
            .Font.Size = 14
            .Font.Bold = True
        End With

        wsNextt.Hyperlinks.Add Anchor:=wsNextt.Range("B15"), Address:="", SubAddress:="'Cadastro de Segmento'!A1", TextToDisplay:="Cadastro de Segmento"
        wsNextt.Hyperlinks.Add Anchor:=wsNextt.Range("B16"), Address:="", SubAddress:="'Cadastro de Secao'!A1", TextToDisplay:="Cadastro de Seção"
        wsNextt.Hyperlinks.Add Anchor:=wsNextt.Range("B17"), Address:="", SubAddress:="'Cadastro de Especie'!A1", TextToDisplay:="Cadastro de Espécie"
        
        With wsNextt.Range("B15:B17")
            .Interior.Color = RGB(217, 217, 217)
            .Font.Name = "Arial"
            .Font.Size = 10
        End With

    Else
        MsgBox "Acesso negado.", vbCritical
    End If
    
    Unload frmSenha
End Sub
