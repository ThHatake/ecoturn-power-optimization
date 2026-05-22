# ==============================================================================
# SISTEMA DE AUDITORIA - RANKING E ENVIO AUTOMÁTICO
# DESENVOLVIDO POR T. HATAKE | VERSÃO SANITIZADA PARA PORTFÓLIO
# ==============================================================================

# --- CONFIGURAÇÕES DE ENVIO ---
$SmtpServer = "smtp.gmail.com"
$SmtpPort = 587
$UsuarioEnvio = "seu.usuario.notificacao@gmail.com" # Alterado para o portfólio
$SenhaDeApp = "SUA_CHAVE_DE_APP_AQUI"               # Alterado para o portfólio
$Remetente = "ti@suaempresa.com.br"                 # Alterado para o portfólio
$Destinatario = "ti@suaempresa.com.br"               # Alterado para o portfólio

$CaminhoLogs = "C:\Monitora"
$CaminhoBackup = "C:\Monitora\Backup"
if (!(Test-Path $CaminhoBackup)) { New-Item -ItemType Directory -Path $CaminhoBackup }

$DataHoje = Get-Date -Format "dd-MM-yyyy"
$ArquivoRanking = "$CaminhoLogs\Ranking_Final_$DataHoje.txt"

# 1. COLETA E PROCESSAMENTO
$Arquivos = Get-ChildItem -Path $CaminhoLogs -Filter "Relatorio_Final*.txt"

if (-not $Arquivos) {
    Write-Host "Nenhum log novo para processar." -ForegroundColor Yellow
    exit
}

# Filtra as linhas contendo sucesso no desligamento
$DadosBrutos = foreach ($Arq in $Arquivos) {
    Get-Content $Arq.FullName | Where-Object { $_ -match "STATUS: SUCESSO" }
}

# PARSING COMPLEXO: Captura tudo entre "USER: " e o colchete ou pipe seguinte
$Ranking = $DadosBrutos | ForEach-Object {
    if ($_ -match "USER:\s*([^\]|]+)") { 
        $UsuarioEncontrado = $Matches[1].Trim()
        if ($UsuarioEncontrado -ne "Colaborador" -and $UsuarioEncontrado -ne "") {
            $UsuarioEncontrado
        }
    }
} | Group-Object | Select-Object Name, Count | Sort-Object Count -Descending

# 2. MONTAGEM DO CORPO DO E-MAIL (HTML)
$CorpoEmail = @"
<html>
<body style='font-family: Calibri, Arial;'>
    <h2 style='color: #004a8d;'>Relatório de Reincidência de Desligamento</h2>
    <p>Seguem os dados consolidados das máquinas que ficaram ligadas fora do expediente:</p>
    <table border='1' style='border-collapse: collapse; width: 100%; max-width: 500px;'>
        <tr style='background-color: #004a8d; color: white;'>
            <th style='padding: 8px;'>Colaborador</th>
            <th style='padding: 8px;'>Vezes Esquecido</th>
        </tr>
"@

if ($Ranking) {
    foreach ($Item in $Ranking) {
        $Cor = if ($Item.Count -ge 3) { "#ffcccc" } else { "white" } # Destaca reincidentes crônicos
        $CorpoEmail += "<tr style='background-color: $Cor;'><td style='padding: 8px;'>$($Item.Name)</td><td style='padding: 8px; text-align: center;'>$($Item.Count)</td></tr>"
    }
} else {
    $CorpoEmail += "<tr><td colspan='2' style='padding: 8px; text-align: center; color: gray;'>Nenhum colaborador com reincidência detectado nestes relatórios.</td></tr>"
}

$CorpoEmail += "</table><p style='font-size: 11px; color: gray;'>Este é um processo automático gerado pelo Sistema de Auditoria TI.</p></body></html>"

# 3. ENVIO DO E-MAIL
try {
    $SenhaSegura = ConvertTo-SecureString $SenhaDeApp -AsPlainText -Force
    $Credencial = New-Object System.Management.Automation.PSCredential($UsuarioEnvio, $SenhaSegura)
    
    $Mail = New-Object System.Net.Mail.MailMessage($Remetente, $Destinatario)
    $Mail.Subject = "Ranking de Reincidência - Desligamento Automático ($DataHoje)"
    $Mail.IsBodyHtml = $true
    $Mail.Body = $CorpoEmail
    
    $Smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
    $Smtp.EnableSsl = $true
    $Smtp.Credentials = $Credencial
    $Smtp.Send($Mail)
    $Mail.Dispose()
    Write-Host "E-mail enviado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao enviar e-mail: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. MOVIMENTAÇÃO PARA BACKUP
foreach ($Arq in $Arquivos) {
    Move-Item -Path $Arq.FullName -Destination "$CaminhoBackup\$($Arq.Name)" -Force
}

Write-Host "Processo Concluído." -ForegroundColor Cyan