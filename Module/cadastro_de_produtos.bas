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

    Dim intersecaoAteBB As Range
    Set intersecaoAteBB = Intersect(Target, Me.Range("A7:BB1007"))

    If Not intersecaoAteBB Is Nothing Then
        Sheets("Cadastro de Produtos").Unprotect Password:="nexttsol"
        Call VerificarSecaoEspecie.VerificarSecaoCompleta
        Call VerificarSecaoEspecie.ValidarDescricoes
        Call VerificarSecaoEspecie.ValidarEspecies
        Sheets("Cadastro de Produtos").Protect Password:="nexttsol", UserInterfaceOnly:=True
    End If

    Dim cel As Range
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

    If Not Intersect(Target, Me.Range("F7:F1007")) Is Nothing Then
        Dim fCelula As Range
        Dim wsDados As Worksheet
        Dim FoundCell As Range
        Dim CheckRange As Range

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
                
                On Error Resume Next
                Set FoundCell = CheckRange.Find(What:=searchValue, _
                                            LookIn:=xlValues, _
                                            LookAt:=xlWhole, _
                                            MatchCase:=False)
                On Error GoTo TratarErro
                
                If Not FoundCell Is Nothing Then
                    MsgBox "O valor '" & fCelula.Value & "' ja existe no banco de dados.", vbExclamation
                    fCelula.ClearContents
                End If
            End If
        Next fCelula
    End If

Finalizar:
    Application.EnableEvents = True
    Exit Sub

TratarErro:
    MsgBox "Erro na linha " & Erl & ": " & Err.Description & vbCrLf & _
           "Objeto com problema: " & TypeName(Err.Source), vbCritical
    Resume Finalizar

End Sub