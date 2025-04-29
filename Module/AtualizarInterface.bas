Attribute VB_Name = "AtualizarInterface"
Public Sub AtualizarInterface()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Nextt")
    
    ws.Unprotect password:="nexttsol"
    
    Call AtualizarDadosConsolidados
    Call AtualizarDadosPedido
    Call CheckDB.StartDBMonitoring

    With ThisWorkbook.Sheets("Nextt").Range("O3")
        .Value = "Atualizado em " & Now
        .Interior.Color = RGB(180, 198, 231)
        .Font.Color = RGB(102, 102, 102)
    End With

    ws.Protect password:="nexttsol", UserInterfaceOnly:=True
End Sub

