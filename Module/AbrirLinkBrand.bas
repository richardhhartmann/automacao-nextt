Attribute VB_Name = "AbrirLinkBrand"
Sub AbrirLinkBrand()
    Dim url As String
    url = "https://www.nexttsolucoes.com.br/" 

    On Error Resume Next
    ThisWorkbook.FollowHyperlink url, NewWindow:=True
    On Error GoTo 0
End Sub
