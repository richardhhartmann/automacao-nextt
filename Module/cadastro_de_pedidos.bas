Private Sub Worksheet_Activate()
    VerificarOcultarColunasDinamicas
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
    On Error GoTo Finalizar

    Application.EnableEvents = False
    Application.ScreenUpdating = False

    Dim rngMonitorada As Range
    Set rngMonitorada = Me.Range("L7:U1007")

    Dim cel As Range
    Dim linhasProcessadas As Object
    Dim colEntrada As Range
    Dim celula As Range
    Dim i As Integer
    Dim existeValor As Boolean

    ' 1. Verificação de códigos duplicados por linha
    If Not Intersect(Target, rngMonitorada) Is Nothing Then
        Set linhasProcessadas = CreateObject("Scripting.Dictionary")
        For Each cel In Intersect(Target, rngMonitorada)
            If Not linhasProcessadas.Exists(cel.Row) Then
                linhasProcessadas.Add cel.Row, True
                Call VerificarCodigosDuplicadosLinha(cel.Row)
            End If
        Next cel
    End If

    ' 2. Ocultação de colunas auxiliares (colunas AB a AK)
    If Not Intersect(Target, rngMonitorada) Is Nothing Then
        For i = 12 To 21 ' colunas L (12) a U (21)
            Set colEntrada = Me.Range(Me.Cells(7, i), Me.Cells(1007, i))
            existeValor = False
            For Each celula In colEntrada
                If Trim(celula.Value) <> "" Then
                    existeValor = True
                    Exit For
                End If
            Next celula
            Me.Columns(i + 10).Hidden = Not existeValor ' oculta colunas V a AE
        Next i
    End If

    ' 3. Desocultar colunas de filial associadas (AF em diante)
    Dim rngTrigger As Range
    Set rngTrigger = Me.Range("V7:AE1007")

    If Not Intersect(Target, rngTrigger) Is Nothing Then
        Dim affectedColumn As Integer
        Dim columnsToUnhide As Integer
        Dim startColumn As Integer
        Dim endColumn As Integer
        Dim j As Integer
        Dim rngToCheck As Range

        affectedColumn = Target.Column - rngTrigger.Column + 1
        columnsToUnhide = GetTotalFiliais()

        If columnsToUnhide > 0 Then
            startColumn = 40 + (affectedColumn - 1) * columnsToUnhide
            endColumn = startColumn + columnsToUnhide - 1
            If endColumn > Me.Columns.Count Then endColumn = Me.Columns.Count

            Set rngToCheck = Me.Range(Me.Cells(7, Target.Column), Me.Cells(1007, Target.Column))
            existeValor = False
            For Each celula In rngToCheck
                If Trim(celula.Value) <> "" Then
                    existeValor = True
                    Exit For
                End If
            Next celula

            For j = startColumn To endColumn
                Me.Columns(j).Hidden = Not existeValor
            Next j
        End If
    End If

    ' 4. Validação de códigos (SQL)
    If Not Intersect(Target, rngMonitorada) Is Nothing Then
        If codigosValidos Is Nothing Then Call modValidacaoCodigo.CarregarCodigosValidos

        For Each cel In Intersect(Target, rngMonitorada)
            If Not IsEmpty(cel.Value) Then
                If Not CodigoExiste(CStr(cel.Value)) Then
                    MsgBox "O código '" & cel.Value & "' não existe na base de dados.", vbExclamation
                    cel.ClearContents
                End If
            End If
        Next cel
    End If

Finalizar:
    Application.EnableEvents = True
    Application.ScreenUpdating = True
End Sub

Private Sub VerificarOcultarColunasDinamicas()
    On Error GoTo ErrorHandler

    Dim columnsToUnhide As Integer
    Dim i As Integer, j As Integer
    Dim startColumn As Integer, endColumn As Integer
    Dim rngTriggerCol As Range
    Dim celula As Range
    Dim existeValor As Boolean
    Dim wsProtected As Boolean
    
    columnsToUnhide = GetTotalFiliais()
    
    If columnsToUnhide > 0 Then
        Application.ScreenUpdating = False
        
        For i = 1 To 11
            Set rngTriggerCol = Me.Range(Me.Cells(7, 21 + i), Me.Cells(1007, 21 + i))
            existeValor = False
            
            For Each celula In rngTriggerCol
                If Trim(celula.Value) <> "" Then
                    existeValor = True
                    Exit For
                End If
            Next celula
            
            startColumn = 40 + (i - 1) * columnsToUnhide
            endColumn = startColumn + columnsToUnhide - 1
            
            If existeValor Then
                For j = startColumn To endColumn
                    If j <= Me.Columns.Count Then
                        If Not Me.Columns(j).Locked Then
                            Me.Columns(j).Hidden = False
                        End If
                    End If
                Next j
            End If
        Next i
        
        Application.ScreenUpdating = True
    End If

    Exit Sub

ErrorHandler:
    MsgBox "Erro ao gerenciar visibilidade das colunas: " & Err.Description, vbExclamation
End Sub

Private Function GetTotalFiliais() As Integer
    On Error GoTo ErroHandler
    
    Dim conn As Object
    Dim rs As Object
    Dim connectionString As String
    Dim jsonText As String
    Dim json As Object
    Dim filePath As String
    Dim result As Integer
    
    GetTotalFiliais = 0
    
    filePath = ThisWorkbook.Path & "\conexao_temp.txt"
    
    On Error GoTo ErroArquivo
    jsonText = CreateObject("Scripting.FileSystemObject").OpenTextFile(filePath).ReadAll
    Set json = ParseJson(jsonText)
    On Error GoTo ErroHandler
    
    If json Is Nothing Then
        MsgBox "Erro ao ler configurações de conexão!", vbExclamation
        Exit Function
    End If
    
    Set conn = CreateObject("ADODB.Connection")
    Set rs = CreateObject("ADODB.Recordset")
    
    connectionString = "Provider=" & json("driver") & ";" & _
                       "Data Source=" & json("server") & ";" & _
                       "Initial Catalog=" & json("database") & ";" & _
                       "User ID=" & json("username") & ";" & _
                       "Password=" & json("password") & ";" & _
                       "Trusted_Connection=" & json("trusted_connection") & ";"
    
    conn.Open connectionString
    rs.Open "SELECT COUNT(*) AS Total FROM tb_filial", conn
    
    result = rs.Fields("Total").Value
    
    rs.Close
    conn.Close
    
    GetTotalFiliais = result
    Exit Function

ErroArquivo:
    MsgBox "Erro ao ler o arquivo de conexão: " & Err.Description, vbExclamation
    Exit Function

ErroHandler:
    MsgBox "Erro ao obter total de filiais: " & Err.Description, vbExclamation
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    If Not conn Is Nothing Then conn.Close
    GetTotalFiliais = 0
End Function

Private Function ParseJsonString(jsonText As String) As Object
    Dim json As Object
    Dim lines As Variant
    Dim line As Variant
    Dim key As String
    Dim Value As String
    Dim i As Integer
    
    Set json = CreateObject("Scripting.Dictionary")
    
    jsonText = Replace(jsonText, "{", "")
    jsonText = Replace(jsonText, "}", "")
    jsonText = Replace(jsonText, Chr(34), "")
    jsonText = Replace(jsonText, vbCr, "")
    jsonText = Replace(jsonText, vbLf, "")
    jsonText = Replace(jsonText, " ", "")
    
    lines = Split(jsonText, ",")
    
    For Each line In lines
        i = InStr(line, ":")
        If i > 0 Then
            key = Left(line, i - 1)
            Value = Mid(line, i + 1)
            json(key) = Value
        End If
    Next line
    
    Set ParseJsonString = json
End Function

Private Sub ListBox1_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
    Dim ws As Worksheet
    Dim i As Long
    Dim linha As Long
    Dim valor As String
    Dim numeroItem As Long
    Dim jaExiste As Boolean
    Dim resposta As VbMsgBoxResult
    Dim ultimaColuna As Long
    Dim colunaInicial As Long
    Dim ProximaColuna As Long
    Dim valoresJ As String
    Dim celulaJ As Range

    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    
    linha = ActiveCell.Row
    colunaInicial = ws.Range("AAF1").Column 
    Set celulaJ = ws.Cells(linha, 10)
    
    valoresJ = celulaJ.Value
    
    For i = 0 To ListBox1.ListCount - 1
        If ListBox1.Selected(i) Then
            valor = ListBox1.List(i)
            numeroItem = i + 1
            jaExiste = False
            
            For ultimaColuna = colunaInicial To 16384
                If ws.Cells(linha, ultimaColuna).Value = numeroItem Then
                    jaExiste = True
                    resposta = MsgBox("Este item já está na lista. Deseja removê-lo?", vbYesNo + vbQuestion, "Remover Item")
                    If resposta = vbYes Then
                        ws.Cells(linha, ultimaColuna).ClearContents
                        valoresJ = Replace(valoresJ, valor, "")
                        valoresJ = Replace(valoresJ, "//", "/")
                        If Left(valoresJ, 1) = "/" Then valoresJ = Mid(valoresJ, 2)
                        If Right(valoresJ, 1) = "/" Then valoresJ = Left(valoresJ, Len(valoresJ) - 1)
                        
                        For ProximaColuna = ultimaColuna + 1 To 16384
                            If ws.Cells(linha, ProximaColuna).Value <> "" Then
                                ws.Cells(linha, ProximaColuna - 1).Value = ws.Cells(linha, ProximaColuna).Value
                                ws.Cells(linha, ProximaColuna).ClearContents
                            End If
                        Next ProximaColuna
                    End If
                    Exit For
                End If
            Next ultimaColuna

            If Not jaExiste Then
                For ultimaColuna = colunaInicial To 16384
                    If ws.Cells(linha, ultimaColuna).Value = "" Then
                        ws.Cells(linha, ultimaColuna).Value = numeroItem
                        Exit For
                    End If
                Next ultimaColuna
                
                If valoresJ = "" Then
                    valoresJ = valor
                Else
                    valoresJ = valoresJ & "/" & valor
                End If
            End If
        End If
    Next i

    celulaJ.Value = valoresJ
    Me.OLEObjects("ListBox1").Visible = False

End Sub

Private Sub CriarListBoxSeNecessario()
    Dim ws As Worksheet
    Dim listBox As Object
    
    On Error GoTo ErrorHandler
    
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
    
    If Not listBox Is Nothing Then
        listBox.Object.MultiSelect = fmMultiSelectMulti
    End If
    
ExitSub:
    Exit Sub
    
ErrorHandler:
    MsgBox "Erro ao criar ListBox: " & Err.Description, vbExclamation
    Resume ExitSub
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