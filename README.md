# Ecoturn - Ferramenta de Desligamento e Otimização de Energia (V3)

## 📌 Sobre o Projeto
O **Ecoturn** é um ecossistema de automação híbrida desenvolvido para otimizar a eficiência operacional, garantir conformidade de segurança e reduzir o desperdício de energia elétrica em um parque tecnológico corporativo com mais de **280 estações de trabalho**.

O sistema realiza a varredura programada das subredes, identifica usuários ativos via chamadas de infraestrutura, interage diretamente com o Active Directory (AD) para envio de alertas preventivos e força o desligamento seguro dos equipamentos. Posteriormente, um motor de auditoria consolida os dados e gera inteligência de negócios para a equipe de TI através de relatórios visuais de reincidência.

---

## 🛠️ Arquitetura e Engenharia da Solução

O sistema foi desenhado de forma assíncrona e distribuída em três blocos principais para mitigar latências de rede e respeitar as janelas de manutenção e cotas de servidores SMTP em nuvem.
[Agendador de Tarefas]
│
├──► 22:00h: Bloco 1 (Faturamento/Op) ──► [Lê maquinas.txt]  ──► [Log Temporal Bloco 1]
├──► 22:30h: Bloco 2 (Engenharia/Adm) ──► [Lê maquinas2.txt] ──► [Log Temporal Bloco 2]
│
└──► 23:30h: Motor de Auditoria       ──► [Data Parsing/Regex] ──► [E-mail com Ranking HTML]
### 🔹 Diferenciais Técnicos Implementados

* **Processamento em Blocos (Paralelismo Logístico):** O parque foi segmentado em listas dinâmicas (`maquinas.txt` e `maquinas2.txt`), reduzindo a janela de varredura no servidor em 50%.
* **Tiro Direto (Sem Ping):** Otimização de I/O de rede removendo testes de ICMP redundantes, partindo direto para a query RPC/WMI contra a camada de hardware local (`Win32_ComputerSystem`).
* **Filtro de Exclusão Dinâmico (Layer 0):** O interpretador ignora linhas comentadas com `#` ou `REM`, permitindo que a equipe de infraestrutura binde estações de trabalho críticas ou servidores sem necessidade de alteração no código-fonte.
* **Data Parsing com Regex Seguro:** O motor de auditoria utiliza expressões regulares robustas para extrair strings complexas dos logs salvos, tratando espaçamentos, delimitadores pipes (`|`) e isolando usuários reais de marcações genéricas do sistema.

---

## 🔒 Pilares de Segurança e Compliance

* **Princípio do Menor Privilégio (PoLP):** A conta de serviço configurada para envio de e-mails opera de forma fria e isolada, sem privilégios de escrita no domínio ou em pastas de rede confidenciais.
* **Tokens de Aplicação (App Passwords):** Credenciais estáticas do servidor foram eliminadas. O sistema consome chaves de aplicação restritas estritamente ao protocolo de relay SMTP.
* **Criptografia em Memória:** Processamento seguro de credenciais em tempo de runtime utilizando conversão para objetos instanciados `SecureString` na memória RAM do servidor.

---

## 📊 Impacto e Resultados de Negócio

* **Eficiência de Tempo:** Substituição de um processo manual suscetível a erros humanos por uma rotina automatizada e centralizada.
* **Sustentabilidade e ROI:** Redução direta da pegada de carbono e dos custos de energia elétrica da companhia, garantindo que o parque tecnológico permaneça offline durante períodos ociosos.
* **Gestão Proativa:** Geração automática de relatórios visuais em HTML para a gerência de TI, destacando em vermelho (`#ffcccc`) colaboradores com 3 ou mais reincidências no esquecimento das estações.

---

## ⚙️ Como Executar o Projeto

No Agendador de Tarefas do Windows (Task Scheduler), configure a execução sob privilégios do usuário `SYSTEM` (ou conta de serviço administrativa) com os seguintes parâmetros:

* **Programa/Script:** `powershell.exe`
* **Argumentos:** `-ExecutionPolicy Bypass -File "C:\SeuDiretorio\NOME_DO_SCRIPT.ps1"`

---
**Desenvolvido por Thiago Silva (T. Hatake) | Analista de TI e Infraestrutura**