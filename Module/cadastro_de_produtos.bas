Dim CheckRange As Range
Dim FoundCell As Range
Dim cel As Range
Dim rng As Range
Dim valorAnterior As Variant
Dim corFundoAnterior As Variant
Dim ws As Worksheet

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    If Not Intersect(Target, Me.Range("C7:D1007,G7:G1007")) Is Nothing Then
        If Target.Cells.Count = 1 Then
            valorAnterior = Target.Value
            corFundoAnterior = Target.Interior.Color
        End If
    End If
End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    On Error GoTo TratarErro
    Application.EnableEvents = False
    Application.ScreenUpdating = False

    ' --- Copiar C para D ---
    Dim cRange As Range
    Set cRange = Intersect(Target, Me.Range("C7:C1007"))
    
    If Not cRange Is Nothing Then
        Dim cCell As Range
        For Each cCell In cRange
            If Not IsEmpty(cCell.Value) Then
                Me.Cells(cCell.Row, "D").Value = cCell.Value
            End If
        Next cCell
    End If

    ' --- Duplicar dados se F preenchido ---
    Dim fRange As Range
    Set fRange = Intersect(Target, Me.Range("F8:F1007"))

    If Not fRange Is Nothing Then
        Dim fCell As Range
        Dim hasNewValues As Boolean
        hasNewValues = False
        
        For Each fCell In fRange
            If Not IsEmpty(fCell.Value) Then
                hasNewValues = True
                Exit For
            End If
        Next fCell
        
        If hasNewValues Then
            Dim resposta As VbMsgBoxResult
            Dim previousRow As Long
            
            resposta = MsgBox("Deseja duplicar os valores da linha anterior?", vbQuestion + vbYesNo, "Duplicar Valores")
            
            If resposta = vbYes Then
                frmAguarde.Show
                DoEvents
                
                For Each fCell In fRange
                    If Not IsEmpty(fCell.Value) Then
                        previousRow = fCell.Row - 1
                        
                        If WorksheetFunction.CountA(Me.Range("A" & previousRow & ":E" & previousRow & ",G" & previousRow & ":BA" & previousRow)) = 0 Then
                            frmAguarde.Hide
                            MsgBox "A linha " & previousRow & " não contém dados para duplicação.", vbExclamation, "Aviso"
                            GoTo Continuar
                        End If
                        
                        Me.Range("A" & previousRow & ":E" & previousRow).Copy Destination:=Me.Range("A" & fCell.Row & ":E" & fCell.Row)
                        Me.Range("G" & previousRow & ":BA" & previousRow).Copy Destination:=Me.Range("G" & fCell.Row & ":BA" & fCell.Row)
                    End If
                Next fCell
                frmAguarde.Hide
            End If
        End If
    End If

Continuar:
    ' --- Validação dinâmica na coluna B ao alterar BC ---
    Dim bcRange As Range
    Set bcRange = Intersect(Target, Me.Range("BC7:BC1007"))
    
    If Not bcRange Is Nothing Then
        On Error Resume Next
        Me.Unprotect "nexttsol"
        On Error GoTo 0
        
        Dim bcCell As Range
        For Each bcCell In bcRange
            If Not IsEmpty(bcCell.Value) Then
                AplicarValidacaoDinamica Me, bcCell.Row
            Else
                Me.Range("B" & bcCell.Row).Validation.Delete
            End If
        Next bcCell
        
        On Error Resume Next
        Me.Protect password:="nexttsol", DrawingObjects:=True, Contents:=True, Scenarios:=True
        On Error GoTo 0
    End If

    ' --- Validação dinâmica na coluna B ao alterar B diretamente ---
    Dim bRange As Range
    Set bRange = Intersect(Target, Me.Range("A7:A1007"))

    If Not bRange Is Nothing Then
        On Error Resume Next
        Me.Unprotect "nexttsol"
        On Error GoTo 0
        
        Dim bCell As Range
        For Each bCell In bRange
            If Not IsEmpty(bCell.Value) Then
                AplicarValidacaoDinamica Me, bCell.Row
            End If
        Next bCell
        
        On Error Resume Next
        Me.Protect password:="nexttsol", DrawingObjects:=True, Contents:=True, Scenarios:=True
        On Error GoTo 0
    End If

    ' --- Verificação geral da planilha ---
    Dim intersecaoAteBB As Range
    Set intersecaoAteBB = Intersect(Target, Me.Range("A7:BB1007"))

    If Not intersecaoAteBB Is Nothing Then
        Sheets("Cadastro de Produtos").Unprotect password:="nexttsol"
        Call VerificarSecaoEspecie.VerificarSecaoCompleta
        Call VerificarSecaoEspecie.ValidarDescricoes
        Call VerificarSecaoEspecie.ValidarEspecies
        Sheets("Cadastro de Produtos").Protect password:="nexttsol", UserInterfaceOnly:=True
    End If

    ' --- Verifica se deve salvar ---
    Dim linha As Long
    Dim deveSalvar As Boolean
    deveSalvar = False

    If Not intersecaoAteBB Is Nothing Then
        For Each cel In intersecaoAteBB.Cells
            linha = cel.Row
            If linha >= 7 And linha <= 1007 Then
                If Trim(UCase(Me.Cells(linha, "BK").Value)) = "OK" Then
                    deveSalvar = True
                    Exit For
                End If
            End If
        Next cel
    End If

    If deveSalvar Then ThisWorkbook.Save

    ' --- Verificação de duplicatas em F com Dados Consolidados ---
    If Not Intersect(Target, Me.Range("F7:F1007")) Is Nothing Then
        Dim fCelula As Range
        Dim wsDados As Worksheet

        On Error Resume Next
        Set wsDados = Nothing
        On Error Resume Next

        For Each ws In ThisWorkbook.Worksheets
            If LCase(ws.Name) = LCase("Dados Consolidados") Then
                Set wsDados = ws
                Exit For
            End If
        Next ws
        On Error GoTo TratarErro

        Set CheckRange = wsDados.Range("AU1:AU1007")

        For Each fCelula In Intersect(Target, Me.Range("F7:F1007"))
            If Not IsEmpty(fCelula.Value) And Trim(fCelula.Value) <> "" Then
                Dim searchValue As String
                searchValue = Trim(fCelula.Value)
                
                Set FoundCell = CheckRange.Find(What:=searchValue, LookIn:=xlValues, LookAt:=xlWhole, MatchCase:=False)
                
                If Not FoundCell Is Nothing Then
                    MsgBox "O valor '" & fCelula.Value & "' já existe no banco de dados.", vbExclamation
                    fCelula.ClearContents
                End If
            End If
        Next fCelula
    End If

Finalizar:
    Application.ScreenUpdating = True
    Application.EnableEvents = True
    Exit Sub

TratarErro:
    MsgBox "Erro na linha " & Erl & ": " & Err.Description & vbCrLf & _
           "Objeto com problema: " & TypeName(Err.Source), vbCritical
    Resume Finalizar
End Sub


' === Função auxiliar de validação dinâmica ===
Private Sub AplicarValidacaoDinamica(ws As Worksheet, linha As Long)
    On Error Resume Next
    Dim formula As String
    Dim nomeSecao As String
    
    nomeSecao = "SecaoCompleta" & ws.Range("BC" & linha).Value
    
    If Evaluate("ISREF('Dados Consolidados'!" & nomeSecao & ")") Then
        ws.Range("B" & linha).Validation.Delete
        formula = "=INDIRECT(""'Dados Consolidados'!" & nomeSecao & """)"
        
        With ws.Range("B" & linha).Validation
            .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Formula1:=formula
            .IgnoreBlank = True
            .ShowError = True
            .ShowInput = True
            .ShowDropDown = True
            .errorTitle = "Valor Inválido"
            .errorMessage = "Por favor, selecione um valor da lista."
        End With
    Else
        ws.Range("B" & linha).Validation.Delete
    End If
End Sub


