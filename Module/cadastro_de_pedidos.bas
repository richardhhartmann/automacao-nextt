Private Sub Worksheet_Activate()
    CriarListBoxSeNecessario
    CarregarItensListBox
    Me.OLEObjects("ListBox1").Visible = False
End Sub

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    CriarListBoxSeNecessario
    CarregarItensListBox
    
    If Not Intersect(Target, Me.Range("J7:J1007")) Is Nothing Then
        With Me.OLEObjects("ListBox1")
            .Visible = True
            .Top = Target.Top + Target.Height
            .Left = Target.Left
            .Width = 150
        End With
    Else
        Me.OLEObjects("ListBox1").Visible = False
    End If
    If Not Intersect(Target, Me.Range("D7:E1007")) Is Nothing Then
        If Target.Cells.Count = 1 Then
            If IsEmpty(Target.Value) Then
                Application.EnableEvents = False
                ShowCalPt.ShowCalPt Target
                Application.EnableEvents = True
            End If
        End If
    End If
End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    Dim rngMonitorada As Range
    Dim cel As Range
    On Error GoTo Finalizar

    Set rngMonitorada = Me.Range("L7:U1007")
    
    If Not Intersect(Target, rngMonitorada) Is Nothing Then
        Application.EnableEvents = False
        
        Dim linhasProcessadas As Object
        Set linhasProcessadas = CreateObject("Scripting.Dictionary")
        
        For Each cel In Intersect(Target, rngMonitorada)
            If Not linhasProcessadas.Exists(cel.Row) Then
                linhasProcessadas.Add cel.Row, True
                Call VerificarCodigosDuplicadosLinha(cel.Row)
            End If
        Next cel
    End If

Finalizar:
    Application.EnableEvents = True
End Sub


Private Sub ListBox1_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
    Dim ws As Worksheet
    Dim i As Long
    Dim linha As Long
    Dim valor As String
    Dim jaExiste As Boolean
    Dim resposta As VbMsgBoxResult
    Dim ultimaColuna As Long
    Dim colunaInicial As Long
    Dim ProximaColuna As Long
    Dim valoresJ As String
    Dim valoresEG As String
    Dim celulaJ As Range
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    
    linha = ActiveCell.Row
    colunaInicial = ws.Range("EG1").Column
    Set celulaJ = ws.Cells(linha, 10) ' Coluna J
    
    ' Inicializa strings para armazenar valores
    valoresJ = celulaJ.Value
    valoresEG = ""
    
    ' Processa cada item selecionado na ListBox
    For i = 0 To ListBox1.ListCount - 1
        If ListBox1.Selected(i) Then
            valor = ListBox1.List(i)
            jaExiste = False
            
            ' Verifica se ja existe na coluna EG
            For ultimaColuna = colunaInicial To 255
                If ws.Cells(linha, ultimaColuna).Value = valor Then
                    jaExiste = True
                    resposta = MsgBox("Este item ja esta na lista. Deseja removê-lo?", vbYesNo + vbQuestion, "Remover Item")
                    If resposta = vbYes Then
                        ' Remove da coluna EG
                        ws.Cells(linha, ultimaColuna).ClearContents
                        
                        ' Remove da celula J
                        valoresJ = Replace(valoresJ, valor, "")
                        valoresJ = Replace(valoresJ, "//", "/")
                        If Left(valoresJ, 1) = "/" Then valoresJ = Mid(valoresJ, 2)
                        If Right(valoresJ, 1) = "/" Then valoresJ = Left(valoresJ, Len(valoresJ) - 1)
                        
                        ' Reorganiza coluna EG
                        For ProximaColuna = ultimaColuna + 1 To 255
                            If ws.Cells(linha, ProximaColuna).Value <> "" Then
                                ws.Cells(linha, ProximaColuna - 1).Value = ws.Cells(linha, ProximaColuna).Value
                                ws.Cells(linha, ProximaColuna).ClearContents
                            End If
                        Next ProximaColuna
                    End If
                    Exit For
                End If
            Next ultimaColuna
            
            ' Se nao existe, adiciona
            If Not jaExiste Then
                ' Adiciona na coluna EG
                For ultimaColuna = colunaInicial To 255
                    If ws.Cells(linha, ultimaColuna).Value = "" Then
                        ws.Cells(linha, ultimaColuna).Value = valor
                        Exit For
                    End If
                Next ultimaColuna
                
                ' Adiciona na celula J
                If valoresJ = "" Then
                    valoresJ = valor
                Else
                    valoresJ = valoresJ & "/" & valor
                End If
            End If
        End If
    Next i
    
    ' Atualiza celula J
    celulaJ.Value = valoresJ
    Me.OLEObjects("ListBox1").Visible = False
End Sub

Private Sub CriarListBoxSeNecessario()
    Dim ws As Worksheet
    Dim listBox As Object
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    
    On Error Resume Next
    Set listBox = ws.OLEObjects("ListBox1")
    On Error GoTo 0
    
    If listBox Is Nothing Then
        Set listBox = ws.OLEObjects.Add(ClassType:="Forms.ListBox.1", _
                                        Left:=100, Top:=100, Width:=150, Height:=100)
        listBox.Name = "ListBox1"
        listBox.Visible = False
    End If
End Sub

Private Sub CarregarItensListBox()
    Dim dadosWs As Worksheet
    Dim rngDados As Range
    Dim celula As Range
    Dim listBox As Object
    Dim ws As Worksheet
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    Set listBox = ws.OLEObjects("ListBox1").Object
    
    Set dadosWs = ThisWorkbook.Sheets("Dados Pedido")
    Set rngDados = dadosWs.Range("J1:J100")
    
    With listBox
        .Clear
        For Each celula In rngDados
            If celula.Value <> "" Then
                .AddItem celula.Value
            End If
        Next celula
        .MultiSelect = fmMultiSelectMulti
    End With
End Sub