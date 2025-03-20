Attribute VB_Name = "ValidarCamposCadastro"

Private Sub Worksheet_Change(ByVal Target As Range)
    Dim cel As Range
    Dim rng As Range
    
    Set rng = Union(Me.Range("C7:C200"), Me.Range("D7:D200"), Me.Range("F7:F200"), _
                    Me.Range("L7:L200"), Me.Range("M7:M200"), Me.Range("N7:N200"), Me.Range("O7:O200"))

    Application.EnableEvents = False

    For Each cel In rng
        If Not Intersect(Target, cel) Is Nothing Then
            If cel.Value = "" Then
                MsgBox "A celula nao pode ficar vazia apos ser editada.", vbExclamation, "Erro"
                Application.Undo
            End If
        End If
    Next cel

    Application.EnableEvents = True
End Sub
