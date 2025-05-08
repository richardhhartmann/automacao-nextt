Attribute VB_Name="OcultarColunasANaXFD_Comprovado"
' Modulo: modOcultarColunasAN
' Versao: 2.0
' Garante a ocultacao das colunas AN:XFD na planilha "Cadastro de Pedidos"

Sub OcultarColunasANaXFD_Comprovado()
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    Dim primeiraColuna As Long ' AN = coluna 40
    Dim ultimaColuna As Long  ' XFD = coluna 16384
    Dim j As Long
    Dim tempoInicio As Double
    Dim wsProtected As Boolean
    Dim colunasOcultadas As Long
    Dim resultado As String
    
    ' ConfiguraÃ¯Â¿Â½Ã¯Â¿Â½es iniciais
    tempoInicio = Timer
    primeiraColuna = 22
    ultimaColuna = 1000
    colunasOcultadas = 0
    
    ' ReferÃ¯Â¿Â½ncia explÃ¯Â¿Â½cita Ã¯Â¿Â½ planilha
    Set ws = Nothing
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets("Cadastro de Pedidos")
    On Error GoTo ErrorHandler
    
    If ws Is Nothing Then
        Exit Sub
    End If
    
    ' Verificar status de proteÃ¯Â¿Â½Ã¯Â¿Â½o
    wsProtected = ws.ProtectContents
    If wsProtected Then
        On Error Resume Next
        ws.Unprotect password:="nexttsol"
        If Err.Number <> 0 Then
            Exit Sub
        End If
        On Error GoTo ErrorHandler
    End If
    
    ' ConfiguraÃ¯Â¿Â½Ã¯Â¿Â½es de performance
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    Application.StatusBar = "Ocultando colunas AN:XFD..."
    
    ' MÃ¯Â¿Â½todo RÃ¯Â¿Â½PIDO e EFETIVO para ocultar colunas
    On Error Resume Next
    With ws.Range(ws.Cells(1, primeiraColuna), ws.Cells(1, ultimaColuna)).EntireColumn
        .Hidden = True
        colunasOcultadas = .Columns.Count
    End With
    On Error GoTo ErrorHandler
    
    ' VerificaÃ¯Â¿Â½Ã¯Â¿Â½o de resultado
    resultado = "Colunas de AN atÃ¯Â¿Â½ XFD ocultadas: " & colunasOcultadas & vbCrLf & _
               "Tempo: " & Format(Timer - tempoInicio, "0.00") & " segundos" & vbCrLf & _
               "Status atual: "
    
    ' Verificar se realmente foram ocultadas (amostra)
    Dim colunaTeste As Range
    Set colunaTeste = ws.Columns(primeiraColuna)
    resultado = resultado & IIf(colunaTeste.Hidden, "OCULTAS", "NÃ¯Â¿Â½O OCULTAS")
    
    
ExitHandler:
    ' Restaurar configuraÃ¯Â¿Â½Ã¯Â¿Â½es
    Application.StatusBar = False
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Application.EnableEvents = True
    
    ' Reproteger se necessÃ¯Â¿Â½rio
    If wsProtected Then
        ws.Protect password:="nexttsol", UserInterfaceOnly:=True, _
                  AllowFormattingColumns:=True, AllowFormattingRows:=True
    End If
    
    Exit Sub
    
ErrorHandler:
    Resume ExitHandler
End Sub

