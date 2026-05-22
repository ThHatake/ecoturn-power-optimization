# ==============================================================================
# SISTEMA DE DESLIGAMENTO AUTOMÁTICO - VERSÃO FINAL - BLOCO 1
# DESENVOLVIDO POR T. HATAKE | VERSÃO SANITIZADA PARA PORTFÓLIO
# ==============================================================================
Import-Module ActiveDirectory

# --- CONFIGURAÇÕES ---
$SmtpServer = "smtp.gmail.com" 
$SmtpPort = 587
$UsuarioEnvio = "seu.usuario.notificacao@gmail.com" 
$SenhaDeApp = "SUA_CHAVE_DE_APP_AQUI" 
$Remetente = "ti@suaempresa.com.br"
$CaminhoLogo = "C:\Monitora\logo.png"
$CaminhoLista = "C:\Monitora\maquinas.txt"

$DataHoje = Get-Date -Format "dd-MM-yyyy_HHmm"
$ArquivoRelatorio = "C:\Monitora\Relatorio_Final_bloco1_$DataHoje.txt"

$SenhaSegura = ConvertTo-SecureString $SenhaDeApp -AsPlainText -Force
$Credencial = New-Object System.Management.Automation.PSCredential($UsuarioEnvio, $SenhaSegura)

# --- PROCESSAMENTO ---
$ListaMaquinas = Get-Content $CaminhoLista | Where-Object { $_ -and $_ -notmatch '^\s*#' }

foreach ($PC in $ListaMaquinas) {
    $PC = $PC.Trim()
    
    $NomeUser = "Colaborador"
    $UserEmail = ""
    $StatusEmail = "Nao Enviado"
    $StatusDeslig = "MAQUINA JA DESLIGADA OU INACESSIVEL"

    # 1. IDENTIFICAÇÃO DO USUÁRIO NO AD (TENTATIVA DIRETA)
    try {
        $CSD = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PC -ErrorAction Stop
        if ($CSD.UserName) {
            $Username = $CSD.UserName.Split("\")[1]
            $ADUser = Get-ADUser -Identity $Username -Properties EmailAddress, DisplayName
            $NomeUser = $ADUser.DisplayName
            $UserEmail = $ADUser.EmailAddress
        }

        # 2. ENVIO DO E-MAIL FORMATADO
        if ($UserEmail) {
            try {
                $Mail = New-Object System.Net.Mail.MailMessage($Remetente, $UserEmail)
                $Mail.Subject = "AVISO: Equipamento Desligado Automaticamente - $PC"
                $Mail.IsBodyHtml = $true
                
                if (Test-Path $CaminhoLogo) {
                    $Attachment = New-Object System.Net.Mail.Attachment($CaminhoLogo)
                    $Attachment.ContentId = "logo_empresa"
                    $Attachment.ContentDisposition.Inline = $true
                    $Mail.Attachments.Add($Attachment)
                    $ImgTag = "<div style='text-align: center; margin-bottom: 20px;'><img src='cid:logo_empresa' width='180'></div>"
                } else { $ImgTag = "" }

                $Mail.Body = @"
<html>
<body style="font-family: 'Segoe UI', Arial, sans-serif; color: #333;">
    <div style="max-width: 550px; border: 1px solid #004a8d; padding: 20px; border-radius: 10px; margin: auto;">
        $ImgTag
        <h2 style="color: #004a8d; border-bottom: 2px solid #004a8d; padding-bottom: 10px;">Olá, $NomeUser</h2>
        <p>Identificamos que a estação de trabalho <b>$PC</b> permaneceu ligada após o expediente.</p>
        <div style="background-color: #fff3f3; border-left: 5px solid #d9534f; padding: 15px; margin: 20px 0;">
            <p style="margin: 0; color: #a94442;"><b>Ação:</b> O equipamento foi desligado remotamente para economia de energia e preservação do hardware.</p>
        </div>
        <p>Por favor, lembre-se de encerrar suas atividades e desligar o computador ao sair.</p>
        <hr style="border: 0; border-top: 1px solid #eee;">
        <p style="font-size: 11px; color: #777; text-align: center;">Processo Automático - TI Corporativa</p>
    </div>
</body>
</html>
"@
                $Smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
                $Smtp.EnableSsl = $true
                $Smtp.Credentials = $Credencial
                $Smtp.Send($Mail)
                $Mail.Dispose()
                $StatusEmail = "Enviado"
            } catch { $StatusEmail = "Erro SMTP: $($_.Exception.Message)" }
        }

        # 3. DESLIGAMENTO REAL
        Stop-Computer -ComputerName $PC -Force -ErrorAction Stop
        $StatusDeslig = "SUCESSO"

    } catch {
        $StatusDeslig = "MAQUINA JA DESLIGADA OU INACESSIVEL"
    }

    # 4. LOG FINAL PADRONIZADO
    "[PC: $PC] | [USER: $NomeUser] | [STATUS: $StatusDeslig] | [E-MAIL: $StatusEmail]" | Out-File $ArquivoRelatorio -Append
    Write-Host "Concluido: $PC" -ForegroundColor Green
}