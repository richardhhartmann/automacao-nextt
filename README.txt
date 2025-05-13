Guia de Configuração e Uso: Cadastro em Lotes Automático

Este documento fornece instruções detalhadas para configurar e utilizar o sistema de cadastro em lotes automático, desenvolvido utilizando Python e VBA.

Requisitos

Antes de iniciar a utilização do sistema, verifique se os seguintes requisitos estão atendidos:

1. Python Instalado e Configurado no PATH

Certifique-se de que o Python está instalado e corretamente configurado no PATH do sistema. Para verificar, utilize o seguinte comando no terminal ou prompt de comando:

python --version

Se o comando não retornar a versão do Python, instale-o a partir do site oficial do Python e inclua-o no PATH durante a instalação.

2. Excel Configurado para Macros VBA

Para garantir o funcionamento adequado da automação com VBA, habilite macros no Excel e configure as permissões de acesso ao modelo de objeto do projeto VBA:

Abra o Excel.

Acesse Arquivo > Opções > Central de Confiabilidade.

Clique em Configurações da Central de Confiabilidade...

Selecione Configurações de Macro e habilite a opção Confiar no acesso ao modelo de objeto de projeto do VBA.

Clique em OK para salvar as alterações.

Como Utilizar

1. Ativar o Ambiente Virtual Python

Para manter as dependências isoladas e evitar conflitos com outras versões de bibliotecas Python instaladas, ative o ambiente virtual antes de executar o projeto:

.\.venv\Scripts\activate

2. Instalar as Dependências

Com o ambiente virtual ativado, instale as bibliotecas necessárias listadas no arquivo requirements.txt:

pip install -r .\requirements.txt

3. Executar o Projeto

O sistema pode ser executado utilizando o seguinte comando:

python main.py

Alternativamente, se desejar especificar o caminho completo do interpretador Python dentro do ambiente virtual:

/automacao-nextt/.venv/Scripts/python.exe /automacao-nextt/main.py

Com o ambiente corretamente configurado, o sistema estará pronto para processar cadastros em lote de forma automática e eficiente.

Para quaisquer dúvidas ou problemas durante a configuração, consulte a documentação oficial do Python e VBA ou entre em contato com o suporte técnico responsável pelo projeto.