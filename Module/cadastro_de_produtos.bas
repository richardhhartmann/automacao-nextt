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
    On Error GoTo TratarErro
    Application.EnableEvents = False
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
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
    
    ' --- Codigo existente para copiar C para D ---
    If Not cRange Is Nothing Then
        Dim cCell As Range, arrValues() As Variant
        Dim i As Long, lastRow As Long
        
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
    
    ' --- Codigo existente para duplicar valores ---
    If Not fRange Is Nothing Then
        Dim fCell As Range, hasNewValues As Boolean
        Dim resposta As VbMsgBoxResult, previousRow As Long
        
        hasNewValues = (Application.CountIf(fRange, "<>") > 0)
        
        If hasNewValues Then
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

Continuar:
    ' --- Codigo existente para validacao dinâmica ---
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
                ElseIf Not bcRange Is Nothing And Not Intersect(valCell, bcRange) Is Nothing Then
                    Me.Range("B" & valCell.Row).Validation.Delete
                End If
            Next valCell
        End If
        
        On Error Resume Next
        Me.Protect password:="nexttsol", DrawingObjects:=True, Contents:=True, Scenarios:=True
        On Error GoTo 0
    End If

    ' --- Codigo existente para verificacao geral ---
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
                    ThisWorkbook.Save
                    Exit For
                End If
            Next bkCel
        End If
    End If

    ' --- Codigo existente para verificar valores duplicados ---
    If Not Intersect(Target, Me.Range("F7:F1007")) Is Nothing Then
        Dim fCelula As Range
        
        On Error Resume Next
        Set wsDados = Worksheets("Dados Consolidados")
        On Error GoTo TratarErro
        
        If Not wsDados Is Nothing Then
            Set CheckRange = wsDados.Range("AU1:AU1007")
            
            For Each fCelula In Intersect(Target, Me.Range("F7:F1007"))
                If Not IsEmpty(fCelula.Value) And Trim(fCelula.Value) <> "" Then
                    Dim searchValue As String
                    searchValue = Trim(fCelula.Value)
                    
                    Set FoundCell = CheckRange.Find(What:=searchValue, LookIn:=xlValues, LookAt:=xlWhole, MatchCase:=False)
                    
                    If Not FoundCell Is Nothing Then
                        MsgBox "O valor '" & fCelula.Value & "' ja existe no banco de dados.", vbExclamation
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
End Sub

Private Sub AplicarValidacaoDinamica(ws As Worksheet, linha As Long)
    On Error Resume Next
    Dim formula As String
    Dim nomeSecao As String
    
    nomeSecao = "SecaoCompleta" & ws.Range("BC" & linha).Value
    
    If Evaluate("ISREF('Dados Consolidados'!" & nomeSecao & ")") Then
        With ws.Range("B" & linha).Validation
            .Delete
            .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                 Formula1:="=INDIRECT(""'Dados Consolidados'!" & nomeSecao & """)"
            .IgnoreBlank = True
            .ShowError = True
            .ShowInput = True
            .ShowDropDown = True
            .errorTitle = "Valor Invalido"
            .ErrorMessage = "Por favor, selecione um valor da lista."
        End With
    Else
        ws.Range("B" & linha).Validation.Delete
    End If
End Sub