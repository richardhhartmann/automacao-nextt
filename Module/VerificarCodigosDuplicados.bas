Attribute VB_Name = "VerificarCodigosDuplicados"
Public Sub VerificarCodigosDuplicadosLinha(ByVal linha As Long)
    Dim ws As Worksheet
    Dim dict As Object
    Dim rng As Range
    Dim cel As Range
    Dim valor As Variant
    Dim mensagem As String
    Dim encontrouDuplicata As Boolean
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Pedidos")
    Set dict = CreateObject("Scripting.Dictionary")
    encontrouDuplicata = False
    
    ' Define o intervalo apenas para a linha especifica
    Set rng = ws.Range("L" & linha & ":U" & linha)
    
    For Each cel In rng
        valor = cel.Value
        
        If Not IsEmpty(valor) And valor <> "" Then
            If dict.Exists(valor) Then
                encontrouDuplicata = True
                mensagem = mensagem & "Codigo duplicado encontrado: " & valor & cel.Address & vbCrLf
                cel.ClearContents
            Else
                dict.Add valor, cel.Address
            End If
        End If
    Next cel
    
    If encontrouDuplicata Then
        MsgBox "Na linha " & linha & " foram encontrados valores duplicados:" & vbCrLf & vbCrLf & mensagem & vbCrLf & "Os valores repetidos foram removidos.", _
               vbExclamation, "Valores Duplicados"
    End If
End Sub


