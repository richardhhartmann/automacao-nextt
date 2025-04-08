Attribute VB_Name = "AplicarValidacaoObrigatoria"
Sub AplicarValidacaoObrigatoria()
    Dim ws As Worksheet
    Dim wsDados As Worksheet
    Dim ultimaColuna As Integer
    Dim linhaObrigatorio As Integer
    Dim linhaInicioValidacao As Integer
    Dim linhaFimValidacao As Integer
    Dim coluna As Integer
    Dim intervalo As Range
    Dim rngLista As Range
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set wsDados = ThisWorkbook.Sheets("Dados Consolidados")

    ultimaColuna = 17
    linhaObrigatorio = 4
    linhaInicioValidacao = 7
    linhaFimValidacao = 200

    For coluna = 1 To ultimaColuna
        If ws.Cells(linhaObrigatorio, coluna).Value = "Obrigatorio" Then
            Set intervalo = ws.Range(ws.Cells(linhaInicioValidacao, coluna), ws.Cells(linhaFimValidacao, coluna))
            
            On Error Resume Next
            Dim tipoValidacao As Long
            tipoValidacao = intervalo.Validation.Type
            On Error GoTo 0
            
            If tipoValidacao = xlValidateList Then
                GoTo Proximo
            End If
            
            intervalo.Validation.Delete
            With intervalo.Validation
                .Add Type:=xlValidateInputOnly
                .IgnoreBlank = False
                .ShowInput = False
                .ShowError = True
                .ErrorTitle = "Erro de Validacao"
                .ErrorMessage = "Por favor, insira um valor valido."
            End With
        End If
        Dim intervaloLimite As Range
    
    Set intervaloLimite = ws.Range("C7:C200,D7:D200")
    intervaloLimite.Validation.Delete
    
    With intervaloLimite.Validation
        .Add Type:=xlValidateTextLength, AlertStyle:=xlValidAlertStop, Operator:=xlLessEqual, Formula1:="50"
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Erro de Validação"
        .ErrorMessage = "O texto inserido excede o tamanho máximo permitido para esta celula."
    End With

    Set EANLimite = ws.Range("Q7:Q200")
    EANLimite.Validation.Delete
    
    With EANLimite.Validation
        .Add Type:=xlValidateTextLength, AlertStyle:=xlValidAlertStop, Operator:=xlLessEqual, Formula1:="20"
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Erro de Validação"
        .ErrorMessage = "O texto inserido excede o tamanho máximo permitido para esta celula."
    End With
Proximo:
    Next coluna

    AplicarListaSuspensa ws, wsDados, "A7:A200", "A1:A100000"
    AplicarListaSuspensa ws, wsDados, "E7:E200", "E1:E100000"
    AplicarListaSuspensa ws, wsDados, "H7:H200", "H1:H100000"
    AplicarListaSuspensa ws, wsDados, "J7:J200", "J1:J100000"
    AplicarListaSuspensa ws, wsDados, "K7:K200", "K1:K100000"
    AplicarListaSuspensa ws, wsDados, "P7:P200", "P1:P100000"

End Sub

Sub AplicarListaSuspensa(wsDestino As Worksheet, wsOrigem As Worksheet, destino As String, origem As String)
    Dim intervaloDestino As Range
    Dim intervaloOrigem As Range

    Set intervaloDestino = wsDestino.Range(destino)
    Set intervaloOrigem = wsOrigem.Range(origem)

    intervaloDestino.Validation.Delete

    With intervaloDestino.Validation
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
        xlBetween, Formula1:="='" & wsOrigem.Name & "'!" & intervaloOrigem.Address
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Entrada InvÃ¡lida"
        .ErrorMessage = "Selecione um valor da lista."
    End With
End Sub
