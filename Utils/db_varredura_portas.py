import socket
import csv

SUBNET = "172.22.2."

PORTAS_SERVICOS = {
    1: ("RDP", 3389),
    2: ("HTTP", 80),
    3: ("HTTPS", 443),
    4: ("SMB", 445),
    5: ("SSH", 22),
    6: ("MySQL", 3306),
    7: ("SQL Server", 1433)
}

def verificar_porta(ip, porta, timeout=0.5):
    try:
        with socket.create_connection((ip, porta), timeout=timeout):
            return True
    except:
        return False

def salvar_resultado(ips, nome_servico, porta):
    arquivo_csv = f"ips_com_porta_{porta}_{nome_servico}.csv"
    with open(arquivo_csv, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["IP", "Serviço", "Porta"])
        for ip in ips:
            writer.writerow([ip, nome_servico, porta])

def iniciar_varredura(servico_id):
    nome_servico, porta = PORTAS_SERVICOS[servico_id]
    print(f"Varredura por {nome_servico} (porta {porta}) iniciada...")

    ips_ativos = []

    for i in range(1, 255):
        ip = SUBNET + str(i)
        if verificar_porta(ip, porta):
            print(f"{ip} - ATIVO")
            ips_ativos.append(ip)

    if ips_ativos:
        salvar_resultado(ips_ativos, nome_servico, porta)
        print(f"\nResultado salvo em 'ips_com_porta_{porta}_{nome_servico}.csv'")
    else:
        print(f"\nNenhum IP com a porta {porta} ({nome_servico}) aberta.")

def main():
    print("Escolha o tipo de varredura:")
    for key, value in PORTAS_SERVICOS.items():
        print(f"{key} - {value[0]} (porta {value[1]})")

    try:
        opcao = int(input("Digite o número correspondente à varredura desejada: "))
        if opcao not in PORTAS_SERVICOS:
            print("Opção inválida. Tente novamente.")
            return
    except ValueError:
        print("Opção inválida. Tente novamente.")
        return

    iniciar_varredura(opcao)

if __name__ == "__main__":
    main()
