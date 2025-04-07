Attribute VB_Name = "PreencherCelulasComAtributos"
Sub PreencherCelulasComAtributos()
    Dim conn As Object
    Dim rs As Object
    Dim ws As Worksheet
    Dim query As String
    Dim connStr As String
    Dim driver As String
    Dim server As String
    Dim database As String
    Dim username As String
    Dim password As String
    Dim trusted_connection As String
    Dim fso As Object
    Dim arquivo As Object
    Dim jsonText As String
    Dim json As Object
    Dim caminhoArquivo As String
    Dim colunaInicial As Integer
    Dim ultimaColuna As Integer
    Dim qtdValores As Integer
    Dim i As Integer
    Dim rng As Range

    ' Define a planilha onde os dados ser�o inseridos
    Set ws = ThisWorkbook.Sheets("Cadastro de Produtos") ' Altere conforme necess�rio

    ' Caminho do arquivo de conex�o tempor�rio
    caminhoArquivo = ThisWorkbook.Path & "\conexao_temp.txt"

    ' Verifica se o arquivo existe
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(caminhoArquivo) Then
        MsgBox "Arquivo de conex�o n�o encontrado!", vbExclamation
        Exit Sub
    End If

    ' L� o conte�do do arquivo
    Set arquivo = fso.OpenTextFile(caminhoArquivo, 1)
    jsonText = arquivo.ReadAll
    arquivo.Close

    ' Corrige valores nulos no JSON
    jsonText = Replace(jsonText, ": null", ": """"")
    jsonText = Replace(jsonText, ":null", ": """"")

    ' Converte JSON
    Set json = JsonConverter.ParseJson(jsonText)
    If json Is Nothing Then
        MsgBox "Erro ao converter JSON!", vbCritical
        Exit Sub
    End If

    ' Atribui os valores do JSON �s vari�veis de conex�o
    driver = json("driver")
    server = json("server")
    database = json("database")
    username = json("username")
    password = json("password")
    trusted_connection = json("trusted_connection")

    ' Define a string de conex�o
    If trusted_connection = "yes" Then
        connStr = "Provider=SQLOLEDB;Server=" & server & ";Database=" & database & ";Integrated Security=SSPI;"
    Else
        connStr = "Provider=SQLOLEDB;Server=" & server & ";Database=" & database & ";UID=" & username & ";PWD=" & password & ";"
    End If

    ' Inicializa a conex�o
    Set conn = CreateObject("ADODB.Connection")

    ' Tenta abrir a conex�o com tratamento de erro
    On Error Resume Next
    conn.Open connStr
    If Err.Number <> 0 Then
        MsgBox "Erro ao conectar ao banco de dados: " & Err.Description, vbCritical
        Exit Sub
    End If
    On Error GoTo 0

    If conn Is Nothing Then
        MsgBox "Erro: conex�o n�o foi inicializada.", vbCritical
        Exit Sub
    End If

    ' Define a consulta SQL
    query = "SELECT tpa_descricao FROM tb_tipo_atributo WHERE tpa_codigo > 2 AND tpa_mascara IS NOT NULL;"

    ' Executa a consulta
    Set rs = conn.Execute(query)

    ' Conta quantos registros foram retornados
    qtdValores = 0
    If Not rs.EOF Then
        rs.MoveFirst
        Do While Not rs.EOF
            qtdValores = qtdValores + 1
            rs.MoveNext
        Loop
    End If

    ' Se houver valores retornados, inserir colunas
    If qtdValores > 0 Then
        colunaInicial = 25 ' Coluna Y (25� coluna)
        ultimaColuna = colunaInicial + qtdValores - 1 ' Calcula a �ltima coluna ap�s inser��o

        ' **INSERE APENAS AS NOVAS COLUNAS SEM MOVER O RESTO**
        ws.Columns(ultimaColuna + 1).Resize(1, qtdValores).Insert Shift:=xlToRight, CopyOrigin:=xlFormatFromLeftOrAbove

        ' **Volta ao primeiro registro do conjunto de dados**
        rs.MoveFirst
        
        ' Preenche as c�lulas com os valores retornados
        For i = 0 To qtdValores - 1
            If Not rs.EOF Then
                With ws.Cells(3, colunaInicial + i)
                    .Value = rs.Fields(0).Value
                    .Font.Bold = True ' Deixa em negrito
                    .Interior.Color = RGB(142, 169, 219) ' Define o fundo para #8EA9DB
                    .HorizontalAlignment = xlCenter ' Centraliza o texto
                    .VerticalAlignment = xlCenter
                End With
                
                ' Define o intervalo das tr�s linhas abaixo e adiciona o fundo cinza claro
                Set rng = ws.Range(ws.Cells(4, colunaInicial + i), ws.Cells(6, colunaInicial + i))
                rng.Interior.Color = RGB(243, 243, 243) ' Cor #F3F3F3
                
                ' Aplica bordas nas c�lulas da nova coluna (linha 3 a 6) na cor #D9D9D9
                With ws.Range(ws.Cells(3, colunaInicial + i), ws.Cells(6, colunaInicial + i)).Borders
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                    .Color = RGB(217, 217, 217) ' Cor #D9D9D9
                End With
                
                rs.MoveNext
            End If
        Next i
        
        ' Define o tamanho fixo das novas colunas como 20
        ws.Columns(colunaInicial).Resize(1, qtdValores).ColumnWidth = 20

        ' **Corrige a mesclagem sem empurrar outras c�lulas**
        With ws.Range(ws.Cells(1, 17), ws.Cells(2, ultimaColuna))
            .Merge
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .Font.Bold = True
        End With
    Else
        MsgBox "Nenhum dado encontrado na consulta.", vbInformation
    End If

    ' Fecha a conex�o
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing

End Sub

