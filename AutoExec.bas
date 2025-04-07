Private Sub Workbook_Open()
    Call AtualizarDadosConsolidados
    Call GerarFormulaDinamica.GerarFormulaDinamica
    Call PreencherCelulasComAtributos.PreencherCelulasComAtributos
End Sub

