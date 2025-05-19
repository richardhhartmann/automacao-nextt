Dim CheckRange As Range
Dim FoundCell As Range
Dim cel As Range
Dim rng As Range
Dim valorAnterior As Variant
Dim corFundoAnterior As Variant
Dim ws As Worksheet

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    If Not Intersect(Target, Me.Range("C7:D1007,G7:G1007")) Is Nothing And Target.Cells.Count = 1 Then
        valorAnterior = Target.Value
        corFundoAnterior = Target.Interior.Color
    End If
End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    Me.Unprotect password:="nexttsol"
    On Error GoTo TratarErro
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    ' --- Primeiro processa as cores dinâmicas ---
    'If Not Intersect(Target, Me.Range("R7:U1007")) Is Nothing Then
        'If Target.CountLarge = 1 Then
            'Call AplicarCoresDinamicas(Target)
        'End If
        'Application.EnableEvents = False
        ' Verifica colunas R a U (18 a 21)
        'Dim i As Long
        'For i = 18 To 21
            'Dim colEntrada As Range, celula As Range
            'Dim existeValor As Boolean
    
            'Set colEntrada = Me.Range(Me.Cells(7, i), Me.Cells(1007, i))
            'existeValor = False
    
            'For Each celula In colEntrada
                'If Trim(celula.Value) <> "" Then
                    'existeValor = True
                    'Exit For
                'End If
            'Next celula
    
            ' Coluna de apoio correspondente: V (22) a Y (25)
            'Me.Columns(i + 4).Hidden = Not existeValor
        'Next i
        'Application.EnableEvents = True
        
        'GoTo Finalizar
    'End If
    
    ' --- Restante do código original ---
    Dim cRange As Range, fRange As Range, bcRange As Range, bRange As Range
    Dim intersecaoAteBB As Range
    Dim deveSalvar As Boolean
    Dim wsDados As Worksheet
    
    Set cRange = Intersect(Target, Me.Range("C7:C1007"))
    Set fRange = Intersect(Target, Me.Range("F8:F1007"))
    Set bcRange = Intersect(Target, Me.Range("BC7:BC1007"))
    Set bRange = Intersect(Target, Me.Range("A7:A1007"))
    Set intersecaoAteBB = Intersect(Target, Me.Range("A7:BB1007"))
    
    If Not Intersect(Target, Me.Range("B7:B1007")) Is Nothing Then
        If Target.Cells.Count = 1 Then
            Application.EnableEvents = False
            Call AtualizarSecaoEspecie(Target.Row)
            Application.EnableEvents = True
        End If
    End If
    
    ' --- Código para copiar C para D ---
    If Not cRange Is Nothing Then
        Dim cCell As Range, arrValues() As Variant
        Dim lastRow As Long
        
        lastRow = cRange.Rows.Count
        ReDim arrValues(1 To lastRow, 1 To 1)
        
        i = 1
        For Each cCell In cRange
            If Not IsEmpty(cCell.Value) Then
                arrValues(i, 1) = cCell.Value
            End If
            i = i + 1
        Next cCell
        
        Me.Range("D" & cRange.Row & ":D" & cRange.Row + lastRow - 1).Value = arrValues
    End If
    
    ' --- Código para duplicar valores ---
    If Not fRange Is Nothing Then
        Dim fCell As Range, hasNewValues As Boolean
        Dim resposta As VbMsgBoxResult, previousRow As Long
        
        hasNewValues = (Application.CountIf(fRange, "<>") > 0)
        
        If hasNewValues Then
            ' Verificar se a célula na coluna F da linha anterior tem valor
            previousRow = fRange.Rows(1).Row - 1
            If Not IsEmpty(Me.Cells(previousRow, "F").Value) Then
                resposta = MsgBox("Deseja duplicar os valores da linha anterior?", vbQuestion + vbYesNo, "Duplicar Valores")
                
                If resposta = vbYes Then
                    frmAguarde.Show
                    DoEvents
                    
                    On Error Resume Next
                    Me.Unprotect "nexttsol"
                    On Error GoTo 0
                    
                    For Each fCell In fRange
                        If Not IsEmpty(fCell.Value) Then
                            previousRow = fCell.Row - 1
                            
                            If WorksheetFunction.CountA(Me.Range("A" & previousRow & ":E" & previousRow & ",G" & previousRow & ":BA" & previousRow)) = 0 Then
                                frmAguarde.Hide
                                MsgBox "A linha " & previousRow & " nao contem dados para duplicacao.", vbExclamation, "Aviso"
                                GoTo Continuar
                            End If
                            
                            With Me
                                .Range("A" & fCell.Row & ":E" & fCell.Row).Value = .Range("A" & previousRow & ":E" & previousRow).Value
                                .Range("G" & fCell.Row & ":BA" & fCell.Row).Value = .Range("G" & previousRow & ":BA" & previousRow).Value
                                .Range("M" & fCell.Row & ":O" & fCell.Row).Value = .Range("M" & previousRow & ":O" & previousRow).Value
                            End With
                        End If
                    Next fCell
                    
                    On Error Resume Next
                    Me.Protect password:="nexttsol", DrawingObjects:=True, Contents:=True, Scenarios:=True
                    On Error GoTo 0
                    
                    frmAguarde.Hide
                End If
            End If
        End If
    End If


Continuar:
    ' --- Código para validação dinâmica ---
    If Not bcRange Is Nothing Or Not bRange Is Nothing Then
        On Error Resume Next
        Me.Unprotect "nexttsol"
        On Error GoTo 0
        
        Dim valRange As Range
        If Not bcRange Is Nothing And Not bRange Is Nothing Then
            Set valRange = Union(bcRange, bRange)
        ElseIf Not bcRange Is Nothing Then
            Set valRange = bcRange
        ElseIf Not bRange Is Nothing Then
            Set valRange = bRange
        End If
        
        If Not valRange Is Nothing Then
            Dim valCell As Range
            For Each valCell In valRange
                If Not IsEmpty(valCell.Value) Then
                    AplicarValidacaoDinamica Me, valCell.Row
                ElseIf Not bcRange Is Nothing And IsInRange(valCell, bcRange) Then
                    Me.Range("B" & valCell.Row).Validation.Delete
                End If
            Next valCell
        End If
        
        On Error Resume Next
        Me.Protect password:="nexttsol", DrawingObjects:=True, Contents:=True, Scenarios:=True
        On Error GoTo 0
    End If

    ' --- Código para verificação geral ---
    If Not intersecaoAteBB Is Nothing Then
        Sheets("Cadastro de Produtos").Unprotect password:="nexttsol"
        Call VerificarSecaoEspecie.VerificarSecaoCompleta
        Call VerificarSecaoEspecie.ValidarDescricoes
        Call VerificarSecaoEspecie.ValidarEspecies
        Sheets("Cadastro de Produtos").Protect password:="nexttsol", UserInterfaceOnly:=True
        
        Dim bkChanged As Range
        Set bkChanged = Intersect(Target, Me.Range("BK7:BK1007"))
        
        If Not bkChanged Is Nothing Then
            Dim bkCel As Range
            For Each bkCel In bkChanged
                If UCase(Trim(bkCel.Value)) = "OK" Then
                    On Error Resume Next
                    ThisWorkbook.Save
                    If Err.Number <> 0 Then
                        MsgBox "Erro ao salvar o arquivo: " & Err.Description, vbExclamation
                        Err.Clear
                    End If
                    On Error GoTo 0
                    Exit For
                End If
            Next bkCel
        End If
    End If

    ' --- Código para verificar valores duplicados ---
    If Not Intersect(Target, Me.Range("F7:F1007")) Is Nothing Then
        Dim fCelula As Range
        Dim dadosArray As Variant
        Dim matchFound As Boolean
        
        On Error Resume Next
        Set wsDados = Worksheets("Dados Consolidados")
        On Error GoTo TratarErro
        
        If Not wsDados Is Nothing Then
            dadosArray = wsDados.Range("AZ7:BB1007").Value
            
            For Each fCelula In Intersect(Target, Me.Range("F7:F1007"))
                If Not IsEmpty(fCelula.Value) And Trim(fCelula.Value) <> "" Then
                    matchFound = False
                    
                    Dim currentSecao As String, currentEspecie As String, currentRef As String
                    currentSecao = Trim(CStr(Me.Range("BC" & fCelula.Row).Value))
                    currentEspecie = Trim(CStr(Me.Range("BD" & fCelula.Row).Value))
                    currentRef = Trim(CStr(fCelula.Value))
                    
                    For i = 1 To UBound(dadosArray, 1)
                        Dim dbSecao As String, dbEspecie As String, dbRef As String
                        dbSecao = Trim(CStr(dadosArray(i, 1)))
                        dbEspecie = Trim(CStr(dadosArray(i, 2)))
                        dbRef = Trim(CStr(dadosArray(i, 3)))
                        
                        If dbSecao = currentSecao And _
                           dbEspecie = currentEspecie And _
                           dbRef = currentRef Then
                            matchFound = True
                            Exit For
                        End If
                    Next i
                    
                    If matchFound Then
                        MsgBox "A referência '" & currentRef & "' já existe para a secao e especie inseridas.", vbExclamation, "Duplicata detectada"
                        fCelula.ClearContents
                    End If
                End If
            Next fCelula
        End If
    End If

Finalizar:
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.EnableEvents = True
    Exit Sub

TratarErro:
    MsgBox "Erro: " & Err.Description & vbCrLf & _
           "Objeto com problema: " & TypeName(Err.Source), vbCritical
    Resume Finalizar

    Me.Protect password:="nexttsol"
End Sub

Private Sub AplicarCoresDinamicas(Target As Range)
    On Error GoTo CorErro
    Application.EnableEvents = False
    
    Dim corTexto As String
    Dim corHex As Long
    Dim fonteClara As Boolean
    Dim celDestino As Range
    
    If Trim(Target.Value) = "" Then
        Target.Interior.ColorIndex = xlColorIndexNone
        Target.Font.Color = RGB(0, 0, 0)
        Target.Offset(0, 4).Interior.ColorIndex = xlColorIndexNone
        Target.Offset(0, 4).Font.Color = RGB(0, 0, 0)
        Exit Sub
    End If

    corTexto = LCase(Trim(Target.Value))
    fonteClara = False

    Select Case corTexto
        Case "azul", "azl", "azul claro", "az"
            corHex = RGB(180, 198, 231)
        Case "azul escuro", "az esc", "azul marinho"
            corHex = RGB(0, 0, 139)
            fonteClara = True
        Case "vermelho", "vm", "vermelho claro", "vml", "vermelha"
            corHex = RGB(255, 199, 206)
        Case "vermelho escuro", "vm esc", "vinho"
            corHex = RGB(139, 0, 0)
            fonteClara = True
        Case "verde", "vrd", "verde claro"
            corHex = RGB(198, 239, 206)
        Case "verde escuro", "vrd esc", "verde musgo"
            corHex = RGB(0, 100, 0)
            fonteClara = True
        Case "amarelo", "am", "amrl", "amarela"
            corHex = RGB(255, 235, 156)
        Case "amarelo escuro", "am esc", "dourado"
            corHex = RGB(218, 165, 32)
        Case "roxo", "rox", "violeta", "roxa"
            corHex = RGB(180, 167, 214)
        Case "roxo escuro", "rox esc", "púrpura"
            corHex = RGB(128, 0, 128)
            fonteClara = True
        Case "preto", "ptr", "black", "preta"
            corHex = RGB(0, 0, 0)
            fonteClara = True
        Case "cinza", "cinzento", "cz", "grey", "gray"
            corHex = RGB(191, 191, 191)
        Case "cinza escuro", "cz esc", "cinza chumbo"
            corHex = RGB(105, 105, 105)
            fonteClara = True
        Case "rosa", "rs", "rosa claro", "pink"
            corHex = RGB(255, 182, 193)
        Case "rosa escuro", "rs esc", "fúcsia"
            corHex = RGB(199, 21, 133)
            fonteClara = True
        Case "marrom", "mrr", "castanho"
            corHex = RGB(153, 101, 21)
            fonteClara = True
        Case "laranja", "lar", "laranja claro"
            corHex = RGB(255, 165, 0)
        Case "laranja escuro", "lar esc", "tijolo"
            corHex = RGB(255, 140, 0)
            fonteClara = True
        Case "bege", "bg"
            corHex = RGB(245, 245, 220)
        Case "azul petróleo", "az pet", "teal"
            corHex = RGB(0, 128, 128)
            fonteClara = True
        Case "turquesa", "turq"
            corHex = RGB(64, 224, 208)
        Case "salmao", "salmão", "slm"
            corHex = RGB(250, 128, 114)
        Case "lilás", "lilas"
            corHex = RGB(200, 162, 200)
        Case "verde limão", "limão", "lim"
            corHex = RGB(50, 205, 50)
        Case "verde água", "verde agua", "água", "agua"
            corHex = RGB(127, 255, 212)
        Case "dourado", "ouro", "dourada"
            corHex = RGB(255, 215, 0)
        Case "prata", "silver"
            corHex = RGB(192, 192, 192)
        Case "bronze", "bronzeada"
            corHex = RGB(205, 127, 50)
        Case "caramelo"
            corHex = RGB(210, 105, 30)
        Case "pêssego", "pessego"
            corHex = RGB(255, 218, 185)
        Case "lavanda"
            corHex = RGB(230, 230, 250)
        Case "azul céu", "céu", "ceu"
            corHex = RGB(135, 206, 235)
        Case "verde oliva", "oliva"
            corHex = RGB(107, 142, 35)
            fonteClara = True
        Case "verde floresta", "floresta"
            corHex = RGB(34, 139, 34)
            fonteClara = True
        Case "azul royal", "royal"
            corHex = RGB(65, 105, 225)
            fonteClara = True
        Case "azul aço", "aço", "aco"
            corHex = RGB(70, 130, 180)
            fonteClara = True
        Case "rosa choque", "choque"
            corHex = RGB(255, 20, 147)
            fonteClara = True
        Case "verde menta", "menta"
            corHex = RGB(152, 255, 152)
        Case "azul bebê", "bebê", "bebe"
            corHex = RGB(173, 216, 230)
        Case "creme"
            corHex = RGB(255, 253, 208)
        Case "bordô", "bordo"
            corHex = RGB(128, 0, 32)
            fonteClara = True
        Case "mostarda"
            corHex = RGB(255, 219, 88)
        Case "cobre"
            corHex = RGB(184, 115, 51)
            fonteClara = True
        Case "sépia", "sepia"
            corHex = RGB(112, 66, 20)
            fonteClara = True
        Case "esmeralda"
            corHex = RGB(80, 200, 120)
        Case "âmbar", "ambar"
            corHex = RGB(255, 191, 0)
        Case "jade"
            corHex = RGB(0, 168, 107)
            fonteClara = True
        Case "coral"
            corHex = RGB(255, 127, 80)
        Case "púrpura", "purpura"
            corHex = RGB(128, 0, 128)
            fonteClara = True
        Case "magenta"
            corHex = RGB(255, 0, 255)
            fonteClara = True
        Case "ciano"
            corHex = RGB(0, 255, 255)
        Case "índigo", "indigo"
            corHex = RGB(75, 0, 130)
            fonteClara = True
        Case "branco", "white", "branca"
            corHex = RGB(255, 255, 255)
        Case Else
            corHex = RGB(255, 255, 255)
            fonteClara = False
    End Select

    With Target
        .Interior.Color = corHex
        .Font.Color = IIf(fonteClara, RGB(255, 255, 255), RGB(0, 0, 0))
    End With

    Set celDestino = Target.Offset(0, 4)
    With celDestino
        .Interior.Color = corHex
        .Font.Color = IIf(fonteClara, RGB(255, 255, 255), RGB(0, 0, 0))
    End With

CorErro:
    Application.EnableEvents = True
End Sub

Private Sub AplicarValidacaoDinamica(ws As Worksheet, linha As Long)
    On Error GoTo ValidacaoErro
    Application.EnableEvents = False
    
    Dim nomeSecao As String
    Dim wsDados As Worksheet
    
    On Error Resume Next
    ws.Unprotect "nexttsol"
    On Error GoTo ValidacaoErro
    
    nomeSecao = "SecaoCompleta" & ws.Range("BC" & linha).Value
    
    Set wsDados = ThisWorkbook.Worksheets("Dados Consolidados")
    If wsDados Is Nothing Then Exit Sub
    
    With ws.Range("B" & linha).Validation
        .Delete
        On Error Resume Next
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
             Formula1:="=INDIRECT(""'Dados Consolidados'!" & nomeSecao & """)"
        If Err.Number <> 0 Then
            .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                 Formula1:="='Dados Consolidados'!" & nomeSecao
        End If
        On Error GoTo ValidacaoErro
        
        .IgnoreBlank = True
        .ShowError = True
        .ShowInput = True
        .ShowDropDown = True
        .errorTitle = "Valor Inválido"
        .ErrorMessage = "Por favor, selecione um valor da lista."
    End With
    
ValidacaoErro:
    On Error Resume Next
    ws.Protect "nexttsol", DrawingObjects:=True, Contents:=True, Scenarios:=True
    Application.EnableEvents = True
End Sub

Function IsInRange(cell As Range, rng As Range) As Boolean
    Dim area As Range
    
    If rng Is Nothing Then
        IsInRange = False
        Exit Function
    End If
    
    For Each area In rng.Areas
        If Not Intersect(cell, area) Is Nothing Then
            IsInRange = True
            Exit Function
        End If
    Next area
    IsInRange = False
End Function