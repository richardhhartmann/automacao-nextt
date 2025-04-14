Dim CheckRange As Range
Dim FoundCell As Range
Dim cel As Range
Dim rng As Range
Dim valorAnterior As Variant
Dim corFundoAnterior As Variant

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

    If Not Me.Name = "Cadastro de Produtos" Then GoTo Finalizar
    
    Call VerificarSecaoEspecie.VerificarSecaoCompleta
    Call VerificarSecaoEspecie.ValidarDescricoes

    Dim CheckRange As Range
    Dim FoundCell As Range
    Dim cel As Range
    Dim rng As Range
    Dim intervaloPreenchimento As Range
    Dim celula As Range
    Dim deveSalvar As Boolean
    Dim linha As Long

    deveSalvar = False

    If Not Intersect(Target, Me.Range("A7:BB1007")) Is Nothing Then
        For Each cel In Target.Cells
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
        If Target.Cells.Count > 1 Then
            Dim c As Range, todasVazias As Boolean
            todasVazias = True
            For Each c In Target
                If Trim(c.Value) <> "" Then
                    todasVazias = False
                    Exit For
                End If
            Next c
            If todasVazias Then GoTo Finalizar
        Else
            If Trim(Target.Value) = "" Then GoTo Finalizar
        End If

        Set CheckRange = Worksheets("Dados Consolidados").Range("AU1:AU100700")
        Set FoundCell = CheckRange.Find(Target.Value, LookIn:=xlValues)

        If Not FoundCell Is Nothing Then
            MsgBox "O valor digitado ja existe no banco de dados. Tente novamente.", vbExclamation
            Target.ClearContents
            GoTo Finalizar
        End If
    End If

    If Not Intersect(Target, Me.Range("A7:A1007")) Is Nothing _
        Or Not Intersect(Target, Me.Range("B7:B1007")) Is Nothing _
        Or Not Intersect(Target, Me.Range("BC7:BC1007")) Is Nothing _
        Or Not Intersect(Target, Me.Range("BD7:BD1007")) Is Nothing Then

    End If

Finalizar:
    Application.EnableEvents = True
    Exit Sub

TratarErro:
    MsgBox "Erro durante a execuçao do evento de alteraçao: " & Err.Description, vbCritical
    Resume Finalizar
End Sub




