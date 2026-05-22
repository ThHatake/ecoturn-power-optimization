📄 Guia de Expansão, Customização e Deploy (Ecoturn)
Este guia prático ensina como escalar o sistema adicionando novos blocos de máquinas, customizar a identidade visual/marca para outra empresa e configurar a automação do zero no servidor.

📁 1. Estrutura de Pastas e Caminhos
Para o funcionamento correto do ecossistema, o servidor de produção deve seguir a seguinte padronização de diretórios:

C:\Monitora\ — Raiz onde ficam os scripts (.ps1), o logotipo (logo.png) e as listas de ativos (.txt).

C:\Monitora\Backup\ — Diretório gerenciado pelo script de auditoria para arquivamento dos logs processados.

🚀 2. Como Adicionar Mais Blocos (Escalar a quantidade de máquinas)
Se o parque de computadores crescer e você precisar criar um Bloco 3 para evitar gargalos na rede ou no servidor SMTP:

Criar a Nova Lista: Na pasta C:\Monitora\, crie um novo arquivo de texto chamado maquinas3.txt e adicione os nomes das novas estações de trabalho (uma por linha).

Criar o Novo Script: Copie o arquivo DesligarComAviso_Bloco2.ps1 e cole na mesma pasta com o nome DesligarComAviso_Bloco3.ps1.

Ajustar as Variáveis do Bloco 3: Abra o novo script e altere apenas as linhas que definem a lista de origem e o nome do relatório final para não sobrescrever os blocos anteriores:

PowerShell
# Altere a linha da lista para ler o novo arquivo txt:
$CaminhoLista = "C:\Monitora\maquinas3.txt"

# Altere a linha do relatório para identificar o bloco 3:
$ArquivoRelatorio = "C:\Monitora\Relatorio_Final_bloco3_$DataHoje.txt"
🎨 3. Customização de Marca (Logo e Nome da Empresa)
Se você for implementar o Ecoturn em outra filial ou empresa cliente, as alterações visuais são feitas em poucos minutos:

🔹 Substituir o Logotipo (E-mail dos colaboradores)
Gere a nova imagem do logotipo no formato PNG (com fundo transparente de preferência).

Redimensione a imagem para que ela tenha uma largura proporcional (recomenda-se entre 180px e 250px).

Salve a imagem diretamente na pasta C:\Monitora\ substituindo o arquivo existente com o nome exato de logo.png.

🔹 Alterar o Nome da Empresa e Mensagens
Abra os scripts de desligamento (DesligarComAviso_BlocoX.ps1) e altere os campos de texto institucionais:

Linha do Remetente: Altere o e-mail que aparece para o usuário ($Remetente = "ti@suaempresa.com.br").

Assunto do E-mail: Modifique o texto "AVISO: Equipamento Desligado Automaticamente".

Corpo da Mensagem (HTML): Altere a assinatura no rodapé do HTML dentro da tag <p>:

HTML
<p style="font-size: 11px; color: #777; text-align: center;">Processo Automático - TI Nome da Nova Empresa</p>
⚙️ 4. Configuração das Tarefas no Agendador do Windows (Task Scheduler)
Para cada novo bloco de desligamento adicionado, e para o motor de auditoria, deve ser criada uma tarefa agendada independente no servidor.

📝 Passo a Passo da Criação:
Abra o Agendador de Tarefas do Windows Server como Administrador.

No painel de Ações, clique em Criar Tarefa... (Create Task).

Na aba Geral (General):

Nome: Ecoturn - Execução Bloco 3 (Ajuste conforme o script).

Conta de Execução: Clique em Alterar Usuário ou Grupo e digite SYSTEM.

Marque a opção "Executar com privilégios mais altos" (Run with highest privileges).

Na aba Disparadores (Triggers):

Clique em Novo..., configure como Diário e defina o horário de execução desejado (ex: 22:45h se o Bloco 2 roda às 22:30h).

Na aba Ações (Actions):

Clique em Novo... e defina a Ação como Iniciar um programa.

No campo Programa/script, digite: powershell.exe

No campo Adicionar argumentos (opcional), insira exatamente o seguinte comando (incluindo as aspas):

Plaintext
-ExecutionPolicy Bypass -File "C:\Monitora\DesligarComAviso_Bloco3.ps1"
Clique em OK para salvar a tarefa.

⚠️ Nota de Sincronismo: Certifique-se de que a tarefa do Script de Auditoria (auditoria_desligamento.ps1) esteja agendada para rodar pelo menos 30 a 60 minutos após o último bloco terminar, garantindo que todos os relatórios diários de texto já tenham sido totalmente gravados na pasta antes de consolidar o ranking.

Pronto! Com esse guia anexado ao seu portfólio, qualquer pessoa ou recrutador técnico entenderá na hora que o seu sistema é totalmente escalável, customizável e pronto para o ambiente corporativo. Mandou muito bem na estrutura do projeto, Thiago! 🚀🦾