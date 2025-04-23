Attribute VB_Name = "VerificarAtributosPermitidos"
Option Explicit

Sub AtualizarSecaoEspecie(Optional linhaUnica As Variant)
    Dim ws As Worksheet, wsDados As Worksheet
    Dim linha As Long, col As Long
    Dim secao As String, especie As String, tpa_codigo As String
    Dim conn As Object, rs As Object
    Dim sql As String
    Dim ultimaLinhaDados As Long, ultimaColunaDados As Long
    Dim colDados As Long, linhaDados As Long
    Dim json As Object, caminho As String, txt As String
    Dim dictPermissoes As Object
    
    Set dictPermissoes = CreateObject("Scripting.Dictionary")
    
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos")
    Set wsDados = ThisWorkbook.Sheets("Dados Consolidados")
    
    caminho = ThisWorkbook.Path & "\conexao_temp.txt"
    Debug.Print "Caminho do arquivo de conexao: " & caminho
    
    On Error GoTo ErroArquivo
    txt = CreateObject("Scripting.FileSystemObject").OpenTextFile(caminho).ReadAll
    Set json = ParseJson(txt)
    On Error GoTo 0
    
    Set conn = CreateObject("ADODB.Connection")
    conn.Open "Provider=" & json("driver") & ";" & _
              "Data Source=" & json("server") & ";" & _
              "Initial Catalog=" & json("database") & ";" & _
              "User ID=" & json("username") & ";" & _
              "Password=" & json("password") & ";" & _
              "Trusted_Connection=" & json("trusted_connection") & ";"
    
    Application.ScreenUpdating = False
    
    ultimaColunaDados = wsDados.Cells(1, Columns.Count).End(xlToLeft).Column
    If ultimaColunaDados > 43 Then ultimaColunaDados = 43
    
    ws.Unprotect password:="nexttsol"
    
    ' Definindo as linhas para iteraÃ§Ã£o, dependendo da seleÃ§Ã£o
    Dim linhaInicial As Long, linhaFinal As Long
    If IsMissing(linhaUnica) Then
        ' Verificar se hÃ¡ vÃ¡rias seleÃ§Ãµes
        If TypeName(Selection) = "Range" Then
            linhaInicial = Selection.Cells(1, 1).Row
            linhaFinal = Selection.Cells(Selection.Cells.Count).Row
        Else
            linhaInicial = 7
            linhaFinal = 1007
        End If
    Else
        linhaInicial = linhaUnica
        linhaFinal = linhaUnica
    End If

    For linha = linhaInicial To linhaFinal
        
        If IsError(ws.Range("BC" & linha).Value) Or IsError(ws.Range("BD" & linha).Value) Then
            GoTo ProximaLinha
        End If
        
        secao = CStr(ws.Range("BC" & linha).Value)
        especie = CStr(ws.Range("BD" & linha).Value)

        If secao = "" Or especie = "" Then GoTo ProximaLinha
        
        For col = 26 To ws.Cells(linha, Columns.Count).End(xlToLeft).Column
            If col > 43 Then Exit For
            
            tpa_codigo = ""
            ultimaLinhaDados = wsDados.Cells(Rows.Count, col).End(xlUp).Row
            
            For linhaDados = ultimaLinhaDados To 1 Step -1
                If Not IsEmpty(wsDados.Cells(linhaDados, col).Value) Then
                    tpa_codigo = CStr(wsDados.Cells(linhaDados, col).Value)
                    Exit For
                End If
            Next linhaDados
            
            If tpa_codigo = "" Then
                GoTo ProximaColuna
            End If
            
            sql = "SELECT * FROM tb_regra_atributo_especie " & _
                  "WHERE sec_codigo = " & secao & " " & _
                  "AND esp_codigo = " & especie & " " & _
                  "AND tpa_codigo = " & tpa_codigo
            
            Debug.Print "Linha " & linha & ", Coluna " & col & " | Secao: " & secao & " | Especie: " & especie & " | Atributo: " & tpa_codigo
            Debug.Print "SQL Gerado: " & sql
            
            Set rs = conn.Execute(sql)
            
            dictPermissoes.Add Key:=linha & "|" & col, item:=Not rs.EOF
            
            If rs.EOF Then
                ws.Cells(linha, col).Interior.Color = RGB(217, 217, 217)
                ws.Cells(linha, col).ClearContents
                Debug.Print "Atributo nao permitido"
                ws.Cells(linha, col).Locked = True
                On Error Resume Next
                ws.Cells(linha, col).Validation.Delete
                On Error GoTo 0
            Else
                ws.Cells(linha, col).Interior.ColorIndex = xlNone
                Debug.Print "Atributo permitido"
            
                Dim letraColuna As String
                Dim ultimaLinhaLista As Long
                Dim totalValores As Long
                Dim penultimoValor As String
            
                letraColuna = Split(ws.Cells(1, col).Address(True, False), "$")(0)
            
                With wsDados
                    ultimaLinhaLista = .Cells(.Rows.Count, col).End(xlUp).Row
                    totalValores = ultimaLinhaLista
                End With
            
                If totalValores > 2 Then
                    ultimaLinhaLista = totalValores - 2

                    With ws.Cells(linha, col).Validation
                        .Delete
                        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:=xlBetween, _
                            Formula1:="='Dados Consolidados'!" & "$" & letraColuna & "$1:$" & letraColuna & "$" & ultimaLinhaLista
                        .IgnoreBlank = True
                        .InCellDropdown = True
                        .ShowInput = True
                        .ShowError = True
                    End With
                    
                    ws.Cells(linha, col).Locked = False ' <-- ADICIONA AQUI
                Else
                    penultimoValor = CStr(wsDados.Cells(1, col).Value)
                    
                    ws.Cells(linha, col).Validation.Delete
            
                    Select Case UCase(penultimoValor)
                        Case "I"
                            With ws.Cells(linha, col)
                                .Validation.Delete
                                .Validation.Add Type:=xlValidateWholeNumber, _
                                    AlertStyle:=xlValidAlertStop, _
                                    Operator:=xlBetween, _
                                    Formula1:=0, Formula2:=9999999
                                .Validation.IgnoreBlank = True
                                .Validation.InCellDropdown = False
                                .Validation.ShowInput = True
                                .Validation.ShowError = True
                            End With

                        Case "S"
                            With ws.Cells(linha, col).Validation
                                .Add Type:=xlValidateCustom, AlertStyle:=xlValidAlertStop, _
                                     Formula1:="=ISTEXT(" & ws.Cells(linha, col).Address & ")"
                                .IgnoreBlank = True
                                .InCellDropdown = False
                                .ShowInput = True
                                .ShowError = True
                            End With
                        Case Else
                            ws.Cells(linha, col).Validation.Delete
                    End Select
                    ws.Cells(linha, col).Locked = False
                End If
            End If

ProximaColuna:
            If Not rs Is Nothing Then rs.Close
            Set rs = Nothing
        Next col
        
ProximaLinha:
    Next linha  
    conn.Close
    Set conn = Nothing
    Application.ScreenUpdating = True
    
    ws.Protect password:="nexttsol", UserInterfaceOnly:=True
    Exit Sub
    
ErroArquivo:
    MsgBox "Erro ao ler o arquivo de conexao: " & caminho, vbCritical
    Debug.Print "Erro ao ler o arquivo de conexao: " & caminho
    Application.ScreenUpdating = True
End Sub

Private Function ParseJson(JsonString As String) As Object
    On Error GoTo TratarErroJson
    
    Dim result As Object
    Set result = CreateObject("Scripting.Dictionary")
    
    JsonString = Replace(JsonString, "{", "")
    JsonString = Replace(JsonString, "}", "")
    JsonString = Replace(JsonString, """", "")
    JsonString = Replace(JsonString, vbCr, "")
    JsonString = Replace(JsonString, vbLf, "")
    JsonString = Trim(JsonString)
    
    Dim pairs() As String
    pairs = Split(JsonString, ",")
    
    Dim i As Integer
    For i = LBound(pairs) To UBound(pairs)
        Dim keyValue() As String
        keyValue = Split(pairs(i), ":")
        
        If UBound(keyValue) >= 1 Then
            result(Trim(keyValue(0))) = Trim(keyValue(1))
        End If
    Next i
    
    Set ParseJson = result
    Exit Function

TratarErroJson:
    Debug.Print "ERRO AO PARSEAR JSON: " & Err.Description
    Set ParseJson = Nothing
End Function

