Dim CheckRange As Range
Dim FoundCell As Range
Dim cel As Range
Dim rng As Range
Dim valorAnterior As Variant

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    If Not Intersect(Target, Me.Range("C7:D200,G7:G200")) Is Nothing Then
        If Target.Cells.Count = 1 Then
            valorAnterior = Target.Value
        End If
    End If
End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    Dim CheckRange As Range
    Dim FoundCell As Range
    Dim cel As Range
    Dim rng As Range
    Dim intervaloPreenchimento As Range
    Dim celula As Range

    If Not Intersect(Target, Me.Range("F7:F200")) Is Nothing Then
        If Trim(Target.Value) = "" Then Exit Sub

        Set CheckRange = Worksheets("Dados Consolidados").Range("AU1:AU100000")
        Set FoundCell = CheckRange.Find(Target.Value, LookIn:=xlValues)

        If Not FoundCell Is Nothing Then
            MsgBox "O valor digitado ja existe no banco de dados. Tente novamente.", vbExclamation
            Application.EnableEvents = False
            Target.ClearContents
            Application.EnableEvents = True
            Exit Sub
        End If
    End If

    If Not Intersect(Target, Me.Range("A7:A200, B7:B200, BC7:BC200, BD7:BD200")) Is Nothing Then
        Application.EnableEvents = False
        Call VerificarSecaoEspecie.VerificarSecaoCompleta
        Call VerificarSecaoEspecie.ValidarDescricoes
        Application.EnableEvents = True
    End If

    Set rng = Union(Me.Range("C7:C200"), Me.Range("D7:D200"), Me.Range("E7:E200"), _
                    Me.Range("F7:F200"), Me.Range("H7:H200"), Me.Range("J7:J200"), _
                    Me.Range("K7:K200"), Me.Range("L7:L200"), Me.Range("M7:M200"), _
                    Me.Range("N7:N200"), Me.Range("O7:O200"), Me.Range("P7:P200"))

    Application.EnableEvents = False

    For Each cel In rng
        If Not Intersect(Target, cel) Is Nothing Then
            If Trim(cel.Value) = "" Then
                MsgBox "A celula nao pode ficar vazia apos ser editada.", vbExclamation, "Erro"
                cel.Value = valorAnterior
                GoTo Finalizar
            End If
        End If
    Next cel

    Set intervaloPreenchimento = Me.Range("A7:BB200")
    If Not Intersect(Target, intervaloPreenchimento) Is Nothing Then
        For Each celula In Intersect(Target, intervaloPreenchimento)
            If Trim(celula.Value) <> "" Then
                celula.Interior.Color = RGB(221, 235, 247)
            End If
        Next celula
    End If

Finalizar:
    Application.EnableEvents = True
End Sub