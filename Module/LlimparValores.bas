Attribute VB_Name="LimparValores"
Sub LimparValoresCadastroDeProdutos()
    Dim ws As Worksheet
    Dim celulasComValor As Range
    
    Set ws = Worksheets("Cadastro de Produtos")
    
    On Error Resume Next ' Evita erro se não houver valores constantes
    Set celulasComValor = ws.Range("A7:BA1007").SpecialCells(xlCellTypeConstants)
    On Error GoTo 0
    
    If Not celulasComValor Is Nothing Then
        celulasComValor.ClearContents
    End If
End Sub

Sub LimparValoresCadastroDePedidos()
    Dim ws As Worksheet
    Dim celulasComValor As Range
    
    Set ws = Worksheets("Cadastro de Pedidos")
    
    On Error Resume Next ' Evita erro se não houver valores constantes
    Set celulasComValor = ws.Range("A7:ZZ1007").SpecialCells(xlCellTypeConstants)
    On Error GoTo 0
    
    If Not celulasComValor Is Nothing Then
        celulasComValor.ClearContents
    End If
End Sub