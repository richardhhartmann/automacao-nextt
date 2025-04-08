Attribute VB_Name = "BloquearTodasAbas"
Sub BloquearTodasAbas()
    Dim ws As Worksheet
    Dim abasParaBloquear As Variant
    Dim i As Integer
    Dim btn As Shape
    
    abasParaBloquear = Array("Nextt")
    
    For i = LBound(abasParaBloquear) To UBound(abasParaBloquear)
        On Error Resume Next
        Set ws = ThisWorkbook.Sheets(abasParaBloquear(i))
        On Error GoTo 0
        
        If Not ws Is Nothing Then
            ' Desprotege a aba (se já estiver protegida)
            ws.Unprotect Password:="nexttsol"
            
            ' Bloqueia todas as células
            ws.Cells.Locked = True
            
            ' Desativa todos os botões da aba
            For Each btn In ws.Shapes
                If btn.Type = msoFormControl Then
                    btn.ControlFormat.Enabled = False ' Desativa o botão
                End If
            Next btn
            
            ' Reprotege a aba
            ws.Protect Password:="nexttsol", UserInterfaceOnly:=True, DrawingObjects:=False
            Set ws = Nothing
        End If
    Next i
End Sub

Sub BloquearCadastroProdutos()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")

    On Error Resume Next
    ws.Unprotect password:="nexttsol"
    On Error GoTo 0

    ws.Cells.Locked = False

    ' Define a ultima linha usada
    Dim ultimaLinha As Long
    ultimaLinha = ws.Cells.Find("*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).Row
    If ultimaLinha < 7 Then ultimaLinha = 1000 ' Define um minimo razoavel

    ' Bloquear de A1 ate XFD6
    ws.Range("A1:XFD6").Locked = True

    ' Bloquear de BL7 ate XFD(ultimaLinha)
    Dim faixaBloqueio As String
    faixaBloqueio = "BL7:XFD" & ultimaLinha
    ws.Range(faixaBloqueio).Locked = True

    ' Proteger aba
    ws.Protect password:="nexttsol", UserInterfaceOnly:=True
End Sub

