Attribute VB_Name="Formatacao"
Sub Formatacao()
    Dim ws As Worksheet
    Dim ultimaLinha As Long
    Dim rng As Range
    Dim nomePlanilha As Variant
    Dim colFinal As String

    ' Última linha da planilha
    ultimaLinha = 1048576

    ' Lista de planilhas e colunas finais
    For Each nomePlanilha In Array("Cadastro de Marcas", "Cadastro de Segmento", "Cadastro de Secao", "Cadastro de Especie")
        
        Set ws = ThisWorkbook.Sheets(nomePlanilha)
        
        ' Define a coluna final de acordo com a planilha
        If nomePlanilha = "Cadastro de Secao" Or nomePlanilha = "Cadastro de Especie" Then
            colFinal = "B"
        Else
            colFinal = "A"
        End If
        
        ' Formatação da linha 5
        With ws.Rows(5)
            .RowHeight = 85
            .Font.Name = "Arial"
            .Font.Size = 8
        End With

        ' Formatação das linhas de 7 até o final
        Set rng = ws.Range("A7:" & colFinal & ultimaLinha)
        
        With rng
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .Font.Name = "Arial"
            .Font.Size = 9
        End With
        
        ws.Rows("7:" & ultimaLinha).RowHeight = 20

    Next nomePlanilha
End Sub

