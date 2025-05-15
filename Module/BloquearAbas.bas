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
            ws.Unprotect password:="nexttsol"
            
            ws.Cells.Locked = True
            
            For Each btn In ws.Shapes
                If btn.Type = msoFormControl Then
                    btn.ControlFormat.Enabled = False
                End If
            Next btn
            
            ws.Protect password:="nexttsol", UserInterfaceOnly:=True, DrawingObjects:=False
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

    ws.Range("A1:XFD6").Locked = True

    Dim ultimaColunaComValor As Long
    Dim col As Long
    For col = ws.Range("A3").Column To ws.Range("BB3").Column
        If Trim(ws.Cells(3, col).Value) <> "" Then
            ultimaColunaComValor = col
        End If
    Next col

    Dim inicioBloqueioColunaIndex As Long
    If ultimaColunaComValor = 0 Then
        inicioBloqueioColunaIndex = ws.Range("BB3").Column + 1
    Else
        inicioBloqueioColunaIndex = ultimaColunaComValor + 1
    End If

    Dim inicioBloqueioColuna As String
    inicioBloqueioColuna = Split(ws.Cells(1, inicioBloqueioColunaIndex).Address, "$")(1)

    Dim ultimaLinha As Long
    ultimaLinha = ws.Cells.Find("*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).Row
    If ultimaLinha < 7 Then ultimaLinha = 1007

    Dim faixaBloqueio As String
    faixaBloqueio = inicioBloqueioColuna & "7:XFD" & ultimaLinha
    ws.Range(faixaBloqueio).Locked = True

    ws.Protect password:="nexttsol", UserInterfaceOnly:=True
End Sub

Sub BloquearCadastroPedidos()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")

    ws.Unprotect Password:="nexttsol"

    ws.Cells.Locked = False

    ws.Range("A1:AM6").Locked = True

    ws.Protect Password:="nexttsol", _
               AllowFormattingCells:=False, _
               AllowInsertingColumns:=False, _
               AllowInsertingRows:=False, _
               AllowDeletingColumns:=False, _
               AllowDeletingRows:=False, _
               AllowSorting:=False, _
               AllowFiltering:=False, _
               AllowUsingPivotTables:=False, _
               DrawingObjects:=True, _
               Contents:=True, _
               Scenarios:=True
End Sub

Sub BloquearCadastroMarcas()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Cadastro de Marcas")
    ws.Unprotect password:="nexttsol"
    ws.Cells.Locked = False
    ws.Range("A1:A5").Locked = True
    ws.Protect password:="nexttsol", UserInterfaceOnly:=True
End Sub