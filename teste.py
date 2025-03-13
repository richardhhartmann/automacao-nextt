from openpyxl import load_workbook
from openpyxl.styles import Font

# Carregar o arquivo Excel existente
caminho_arquivo = "Cadastros Auto Nextt teste.xlsx"  # Substitua pelo nome do seu arquivo
wb = load_workbook(caminho_arquivo)
ws = wb.active  # Seleciona a planilha ativa

# Definir a nova fonte (Arial, tamanho 10)
nova_fonte = Font(name="Arial", size=10)

# Percorrer todas as linhas a partir da linha 6 (linha 6 em diante)
for row in ws.iter_rows(min_row=6, max_row=ws.max_row, min_col=1, max_col=52):  # A=1, AZ=52
    for cell in row:
        cell.font = nova_fonte  # Aplicar a nova fonte

# Salvar as alterações
wb.save("planilha_estilizada.xlsx")
print("Estilização concluída! Fonte alterada para Arial 10 da linha 6 em diante.")
