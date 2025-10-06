# Provisionamento Automático de Servidor Web Apache

Script de Infrastructure as Code (IaC) para provisionamento automático de servidor web Apache com configurações de produção.

## 🚀 Visão Geral

Este projeto automatiza a instalação e configuração completa de um servidor web Apache incluindo:

- ✅ Instalação automática do Apache
- ✅ Configuração de firewall
- ✅ Criação de estrutura de diretórios
- ✅ Virtual Hosts
- ✅ Scripts de monitoramento
- ✅ Sistema de backup automático
- ✅ Otimizações de performance
- ✅ Página de exemplo
- ✅ Relatório de provisionamento

## 📋 Pré-requisitos

- Sistema Linux (Ubuntu, CentOS, Debian)
- Acesso root
- Conexão com internet

## 🛠️ Instalação e Uso

### 1. Clonar o repositório
```bash
git clone https://github.com/seu-usuario/provisionamento-apache-iac.git
cd provisionamento-apache-iac

🎯 Funcionalidades
Instalação Automática
Detecta automaticamente a distribuição Linux

Instala Apache e dependências

Configura regras de firewall

Configuração de Produção
Virtual Hosts otimizados

Configurações de segurança

Headers de proteção

Otimizações de cache

Monitoramento
Script de monitoramento automático

Verificação de serviços

Log de recursos (CPU, Memória)

Agendamento via cron

Backup
Backup diário automático

Rotação de backups (7 dias)

Compressão e armazenamento

📁 Estrutura Criada
text
/var/www/html/meusite.com/
├── public/                 # Document root
│   ├── css/
│   ├── js/
│   ├── images/
│   ├── uploads/
│   └── index.html         # Página de exemplo
├── private/               # Arquivos privados
├── logs/                  # Logs específicos do site
└── backups/               # Backups locais

/backups/web/              # Backups automáticos
/var/log/apache-custom/    # Logs do Apache
⚙️ Personalização
Edite as variáveis no início do script:

bash
# Variáveis de configuração
SITE_NAME="meusite.com"
WEB_ROOT="/var/www/html"
BACKUP_DIR="/backups/web"
LOG_DIR="/var/log/apache-custom"
SITE_ADMIN="webadmin"
EMAIL_ADMIN="admin@${SITE_NAME}"
🔧 Comandos Úteis
Gerenciamento do Apache
bash
# Ubuntu/Debian
sudo systemctl status apache2
sudo systemctl restart apache2

# CentOS/RHEL
sudo systemctl status httpd
sudo systemctl restart httpd
Verificar logs
bash
sudo tail -f /var/log/apache-custom/meusite.com-error.log
sudo tail -f /var/log/apache-custom/meusite.com-access.log
Backup manual
bash
sudo /usr/local/bin/backup-website.sh
Monitoramento manual
bash
sudo /usr/local/bin/monitor-apache.sh
📊 Scripts Auxiliares
monitor-apache.sh
Verifica status do Apache a cada 5 minutos

Reinicia serviço se necessário

Monitora uso de CPU e memória

Log rotation automático

backup-website.sh
Backup diário às 2h

Compressão em tar.gz

Rotação de 7 dias

Log de atividades

🛡️ Segurança
O script inclui:

Headers de segurança (XSS, Clickjacking)

Configurações seguras de diretórios

Firewall configurado

Permissões adequadas

🐛 Solução de Problemas
Apache não inicia
bash
sudo systemctl status apache2
sudo journalctl -xe
Porta 80 bloqueada
bash
sudo ufw status
sudo netstat -tuln | grep :80
Erro de permissões
bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/