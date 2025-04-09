Attribute VB_Name = "AplicarValidacaoObrigatoria"
Sub AplicarValidacaoObrigatoria()
    Dim ws As Worksheet
    Dim wsDados As Worksheet
    Dim wsPedido As Worksheet
    Dim wsSegmento As Worksheet
    Dim wsSecao As Worksheet
    Dim wsEspecie As Worksheet
    Dim ultimaColuna As Integer
    Dim linhaObrigatorio As Integer
    Dim linhaInicioValidacao As Integer
    Dim linhaFimValidacao As Integer
    Dim coluna As Integer
    Dim intervalo As Range
    Dim rngLista As Range
    Dim intervaloNumerico As Range
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set wsPedido = ThisWorkbook.Sheets("Cadastro de Pedidos")
    Set wsSecao = ThisWorkbook.Sheets("Cadastro de Secao")
    Set wsEspecie = ThisWorkbook.Sheets("Cadastro de Especie")
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
    
    Set intervaloLimite = ws.Range("C7:C200,D7:D200,F7:F200,G7:G200")
    intervaloLimite.Validation.Delete
    
    With intervaloLimite.Validation
        .Add Type:=xlValidateTextLength, AlertStyle:=xlValidAlertStop, Operator:=xlLessEqual, Formula1:="50"
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Erro de Validacao"
        .ErrorMessage = "O texto inserido excede o tamanho maximo permitido para esta celula."
    End With

    Set EANLimite = ws.Range("Q7:Q200")
    EANLimite.Validation.Delete
    
    With EANLimite.Validation
        .Add Type:=xlValidateCustom, _
            AlertStyle:=xlValidAlertStop, _
            Formula1:="=AND(ISNUMBER(--Q7),LEN(Q7)<=20,INT(--Q7)=--Q7)"
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Valor inválido"
        .ErrorMessage = "Digite até 20 dígitos numéricos, sem espaços ou símbolos."
    End With

    EANLimite.NumberFormat = "@"

    Set intervaloNumerico = ws.Range("M7:M200")
    intervaloNumerico.Validation.Delete
    
    With intervaloNumerico.Validation
        .Add Type:=xlValidateDecimal, _
             AlertStyle:=xlValidAlertStop, _
             Operator:=xlBetween, _
             Formula1:="1", _
             Formula2:="99999999"
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Valor invalido"
        .ErrorMessage = "Insira um numero entre 1 e 99.999.999."
    End With
    
    intervaloNumerico.NumberFormat = """R$"" #,##0.00"
    
    Set intervaloPercentual = ws.Range("N7:N200, O7:O200")
    intervaloPercentual.Validation.Delete
    With intervaloPercentual.Validation
        .Add Type:=xlValidateDecimal, _
             AlertStyle:=xlValidAlertStop, _
             Operator:=xlBetween, _
             Formula1:="1", _
             Formula2:="100"
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Valor invalido"
        .ErrorMessage = "Insira um numero entre 1 e 100."
    End With
    intervaloPercentual.NumberFormat = "0.00""%"""
    
    Set atributoLimite = ws.Range("R7:BB200")
    atributoLimite.Validation.Delete
    
    With atributoLimite.Validation
        .Add Type:=xlValidateTextLength, AlertStyle:=xlValidAlertStop, Operator:=xlLessEqual, Formula1:="50"
        .IgnoreBlank = True
        .ShowInput = True
        .ShowError = True
        .ErrorTitle = "Erro de Validacao"
        .ErrorMessage = "O texto inserido excede o tamanho maximo permitido para esta celula."
    End With

Proximo:
    Next coluna

    AplicarListaSuspensa ws, wsDados, "A7:A200", "A1:A100000"
    AplicarListaSuspensa ws, wsDados, "E7:E200", "E1:E100000"
    AplicarListaSuspensa ws, wsDados, "H7:H200", "H1:H100000"
    AplicarListaSuspensa ws, wsDados, "J7:J200", "J1:J100000"
    AplicarListaSuspensa ws, wsDados, "K7:K200", "K1:K100000"
    AplicarListaSuspensa ws, wsDados, "L7:L200", "L1:L100000"
    AplicarListaSuspensa ws, wsDados, "P7:P200", "P1:P100000"

    AplicarListaSuspensa wsSecao, wsDados, "B7:B200", "AR1:AR100000"
    AplicarListaSuspensa wsEspecie, wsDados, "B7:B200", "A1:A100000"

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
        .ErrorTitle = "Entrada Invalida"
        .ErrorMessage = "Selecione um valor da lista."
    End With
End Sub