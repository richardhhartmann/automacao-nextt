Attribute VB_Name = "ReexibirAbas"
Sub ReexibirAbas()
    Dim abasParaReexibir As Variant
    Dim ws As Worksheet
    Dim i As Integer
    Dim wsNextt As Worksheet
    Dim wsCadastroProdutos As Worksheet
    
    abasParaReexibir = Array("Cadastro de Segmento", "Cadastro de Secao", "Cadastro de Especie", "Dados Consolidados", "Dados Pedido")

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
        Set wsCadastroProdutos = ThisWorkbook.Sheets("Cadastro de Produtos")

        wsNextt.Unprotect password:="nexttsol"
        wsCadastroProdutos.Unprotect password:="nexttsol"

        With wsNextt.Range("B13")
            .Value = "Operador:"
            .Font.Color = RGB(38, 38, 38)
            .Font.Name = "Arial"
            .Font.Size = 14
            .Font.Bold = True
        End With

        wsNextt.Hyperlinks.Add Anchor:=wsNextt.Range("B15"), Address:="", SubAddress:="'Cadastro de Segmento'!A1", TextToDisplay:="Cadastro de Segmento"
        wsNextt.Hyperlinks.Add Anchor:=wsNextt.Range("B16"), Address:="", SubAddress:="'Cadastro de Secao'!A1", TextToDisplay:="Cadastro de Secao"
        wsNextt.Hyperlinks.Add Anchor:=wsNextt.Range("B17"), Address:="", SubAddress:="'Cadastro de Especie'!A1", TextToDisplay:="Cadastro de Especie"
        
        wsCadastroProdutos.Hyperlinks.Add Anchor:=wsCadastroProdutos.Range("A6"), Address:="", SubAddress:="'Cadastro de Secao'!A1", TextToDisplay:="Para cadastro de Secao em lotes, clique aqui"
        wsCadastroProdutos.Hyperlinks.Add Anchor:=wsCadastroProdutos.Range("B6"), Address:="", SubAddress:="'Cadastro de Especie'!A1", TextToDisplay:="Para cadastro de Especie em lotes, clique aqui"

        With wsNextt.Range("B15:B17")
            .Interior.Color = RGB(217, 217, 217)
            ' .Font.Name = "Arial"
            ' .Font.Size = 10
        End With
        
        With wsCadastroProdutos.Range("A6:B6")
            .Font.Name = "Arial"
            .Font.Size = 8
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
                With .Borders
                .LineStyle = xlContinuous
                .Color = RGB(217, 217, 217)
                .Weight = xlThin
            End With
        End With

        wsNextt.Protect password:="nexttsol"
        wsCadastroProdutos.Protect password:="nexttsol"

    Else
        MsgBox "Acesso negado.", vbCritical
    End If
    
    Unload frmSenha
End Sub
