#!/bin/bash

# ==================================================
# SCRIPT DE PROVISIONAMENTO DE SERVIDOR WEB APACHE
# ==================================================
# Autor: [Seu Nome]
# Data: $(date +%Y-%m-%d)
# Versão: 2.0
# ==================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis de configuração
SITE_NAME="meusite.com"
WEB_ROOT="/var/www/html"
BACKUP_DIR="/backups/web"
LOG_DIR="/var/log/apache-custom"
SITE_ADMIN="webadmin"
EMAIL_ADMIN="admin@${SITE_NAME}"

# Função para log
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Função para verificar se é root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Este script deve ser executado como root!"
        exit 1
    fi
    log "Privilégios de root verificados"
}

# Função para detectar a distribuição
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        error "Não foi possível detectar a distribuição"
        exit 1
    fi
    
    info "Distribuição detectada: $OS $VER"
}

# Função para atualizar o sistema
update_system() {
    log "Atualizando o sistema..."
    
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        apt-get update && apt-get upgrade -y
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        yum update -y
    elif command -v dnf &> /dev/null; then
        # Fedora
        dnf update -y
    else
        error "Gerenciador de pacotes não suportado"
        exit 1
    fi
    
    log "Sistema atualizado com sucesso"
}

# Função para instalar o Apache
install_apache() {
    log "Instalando Apache Web Server..."
    
    if command -v apt-get &> /dev/null; then
        apt-get install -y apache2 apache2-utils
        systemctl enable apache2
        systemctl start apache2
    elif command -v yum &> /dev/null; then
        yum install -y httpd httpd-tools
        systemctl enable httpd
        systemctl start httpd
    else
        error "Não foi possível instalar o Apache"
        exit 1
    fi
    
    log "Apache instalado e iniciado com sucesso"
}

# Função para configurar firewall
configure_firewall() {
    log "Configurando firewall..."
    
    if command -v ufw &> /dev/null; then
        ufw allow 'Apache Full'
        ufw --force enable
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --reload
    elif command -v iptables &> /dev/null; then
        iptables -A INPUT -p tcp --dport 80 -j ACCEPT
        iptables -A INPUT -p tcp --dport 443 -j ACCEPT
        iptables-save > /etc/iptables/rules.v4
    fi
    
    log "Firewall configurado para HTTP(80) e HTTPS(443)"
}

# Função para criar estrutura de diretórios
create_directories() {
    log "Criando estrutura de diretórios..."
    
    mkdir -p $WEB_ROOT
    mkdir -p $BACKUP_DIR
    mkdir -p $LOG_DIR
    mkdir -p $WEB_ROOT/$SITE_NAME/{public,private,logs,backups}
    mkdir -p $WEB_ROOT/$SITE_NAME/public/{css,js,images,uploads}
    
    log "Estrutura de diretórios criada em $WEB_ROOT/$SITE_NAME"
}

# Função para criar usuário de administração
create_admin_user() {
    log "Criando usuário de administração..."
    
    if ! id "$SITE_ADMIN" &>/dev/null; then
        useradd -m -s /bin/bash -G www-data $SITE_ADMIN
        echo "$SITE_ADMIN:SenhaSegura123!" | chpasswd
        log "Usuário $SITE_ADMIN criado com sucesso"
    else
        warn "Usuário $SITE_ADMIN já existe"
    fi
}

# Função para criar página HTML de exemplo
create_sample_website() {
    log "Criando site de exemplo..."
    
    cat > $WEB_ROOT/$SITE_NAME/public/index.html << EOF
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${SITE_NAME} - Site em Funcionamento</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Arial', sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            padding: 3rem;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 600px;
            margin: 2rem;
        }
        h1 {
            color: #4a5568;
            margin-bottom: 1rem;
            font-size: 2.5rem;
        }
        .status {
            background: #48bb78;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            display: inline-block;
            margin: 1rem 0;
            font-weight: bold;
        }
        .info-box {
            background: #f7fafc;
            border-left: 4px solid #4299e1;
            padding: 1rem;
            margin: 1.5rem 0;
            text-align: left;
            border-radius: 0 8px 8px 0;
        }
        .server-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: 1.5rem;
        }
        .info-item {
            background: #edf2f7;
            padding: 0.75rem;
            border-radius: 8px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Servidor Web Apache</h1>
        <div class="status">ONLINE E FUNCIONANDO</div>
        
        <div class="info-box">
            <strong>Parabéns!</strong> Seu servidor web foi provisionado com sucesso 
            através de Infrastructure as Code (IaC).
        </div>

        <div class="server-info">
            <div class="info-item">
                <strong>Site:</strong><br>${SITE_NAME}
            </div>
            <div class="info-item">
                <strong>Servidor:</strong><br>Apache $(apache2 -v 2>/dev/null | head -n1 | cut -d' ' -f3)
            </div>
            <div class="info-item">
                <strong>Data:</strong><br>$(date +"%d/%m/%Y")
            </div>
            <div class="info-item">
                <strong>Hora:</strong><br>$(date +"%H:%M:%S")
            </div>
        </div>

        <div style="margin-top: 2rem; padding-top: 1rem; border-top: 1px solid #e2e8f0;">
            <small>
                Provisionado automaticamente por Script IaC<br>
                Última atualização: $(date)
            </small>
        </div>
    </div>
</body>
</html>
EOF

    log "Site de exemplo criado em $WEB_ROOT/$SITE_NAME/public/index.html"
}

# Função para criar virtual host
create_virtual_host() {
    log "Criando virtual host..."
    
    if command -v apache2 &> /dev/null; then
        # Debian/Ubuntu
        VHOST_FILE="/etc/apache2/sites-available/${SITE_NAME}.conf"
    else
        # CentOS/RHEL
        VHOST_FILE="/etc/httpd/conf.d/${SITE_NAME}.conf"
    fi
    
    cat > $VHOST_FILE << EOF
<VirtualHost *:80>
    ServerName ${SITE_NAME}
    ServerAlias www.${SITE_NAME}
    ServerAdmin ${EMAIL_ADMIN}
    
    DocumentRoot ${WEB_ROOT}/${SITE_NAME}/public
    
    # Logs
    ErrorLog ${LOG_DIR}/${SITE_NAME}-error.log
    CustomLog ${LOG_DIR}/${SITE_NAME}-access.log combined
    
    # Segurança
    <Directory ${WEB_ROOT}/${SITE_NAME}/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Headers de segurança
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
    </Directory>
    
    # Otimizações de performance
    EnableSendfile on
    Timeout 300
    
    # Configurações de cache
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType image/jpg "access plus 1 month"
        ExpiresByType image/jpeg "access plus 1 month"
        ExpiresByType image/gif "access plus 1 month"
        ExpiresByType image/png "access plus 1 month"
        ExpiresByType text/css "access plus 1 month"
        ExpiresByType application/pdf "access plus 1 month"
        ExpiresByType text/javascript "access plus 1 month"
        ExpiresByType text/html "access plus 1 day"
    </IfModule>
</VirtualHost>
EOF

    # Habilitar site no Apache (Debian/Ubuntu)
    if command -v a2ensite &> /dev/null; then
        a2ensite ${SITE_NAME}.conf
        a2dissite 000-default.conf
    fi
    
    log "Virtual host criado: $VHOST_FILE"
}

# Função para configurar SSL (opcional)
setup_ssl() {
    log "Configurando SSL/TLS..."
    
    if command -v apt-get &> /dev/null; then
        apt-get install -y certbot python3-certbot-apache
        
        # Gerar certificado SSL (comentado para não executar automaticamente)
        warn "Para gerar certificado SSL real, execute:"
        echo "certbot --apache -d ${SITE_NAME} -d www.${SITE_NAME}"
    else
        warn "Instale certbot manualmente para configuração SSL"
    fi
}

# Função para criar script de monitoramento
create_monitoring_script() {
    log "Criando script de monitoramento..."
    
    cat > /usr/local/bin/monitor-apache.sh << 'EOF'
#!/bin/bash

# Script de monitoramento do Apache
LOG_FILE="/var/log/apache-monitor.log"
EMAIL_ADMIN="admin@meusite.com"

# Funções de log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

check_apache() {
    if systemctl is-active --quiet apache2 || systemctl is-active --quiet httpd; then
        echo "active"
    else
        echo "inactive"
    fi
}

# Verificar status do Apache
STATUS=$(check_apache)

if [ "$STATUS" == "active" ]; then
    log "Apache está rodando normalmente"
else
    log "CRÍTICO: Apache está parado. Reiniciando..."
    
    # Tentar reiniciar
    if command -v apache2 &> /dev/null; then
        systemctl restart apache2
    else
        systemctl restart httpd
    fi
    
    # Verificar se reiniciou com sucesso
    sleep 5
    if [ "$(check_apache)" == "active" ]; then
        log "Apache reiniciado com sucesso"
    else
        log "FALHA: Não foi possível reiniciar o Apache"
        # Aqui poderia enviar um email de alerta
    fi
fi

# Verificar uso de recursos
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)

log "Uso de CPU: $CPU_USAGE% | Uso de Memória: $MEMORY_USAGE"

# Log rotation se o arquivo ficar muito grande
if [ $(wc -l < $LOG_FILE) -gt 1000 ]; then
    tail -500 $LOG_FILE > $LOG_FILE.tmp
    mv $LOG_FILE.tmp $LOG_FILE
    log "Log file rotated"
fi
EOF

    chmod +x /usr/local/bin/monitor-apache.sh
    
    # Adicionar ao crontab para executar a cada 5 minutos
    (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/monitor-apache.sh") | crontab -
    
    log "Script de monitoramento criado e agendado"
}

# Função para criar script de backup
create_backup_script() {
    log "Criando script de backup..."
    
    cat > /usr/local/bin/backup-website.sh << EOF
#!/bin/bash

# Script de backup do website
BACKUP_DIR="$BACKUP_DIR"
SITE_DIR="$WEB_ROOT/$SITE_NAME"
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_\${SITE_NAME}_\$DATE.tar.gz"

log() {
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] \$1" >> /var/log/backup-website.log
}

log "Iniciando backup do website"

# Criar backup
tar -czf "\$BACKUP_DIR/\$BACKUP_FILE" "\$SITE_DIR" 2>/dev/null

if [ \$? -eq 0 ]; then
    log "Backup criado com sucesso: \$BACKUP_FILE"
    
    # Manter apenas últimos 7 backups
    find "\$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
    log "Backups antigos removidos"
else
    log "ERRO: Falha ao criar backup"
    exit 1
fi

log "Backup finalizado"
EOF

    chmod +x /usr/local/bin/backup-website.sh
    
    # Agendar backup diário às 2h
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-website.sh") | crontab -
    
    log "Script de backup criado e agendado"
}

# Função para configurar otimizações
configure_optimizations() {
    log "Aplicando otimizações..."
    
    if command -v apache2 &> /dev/null; then
        # Habilitar módulos úteis
        a2enmod rewrite
        a2enmod expires
        a2enmod headers
    fi
    
    # Configurações de performance
    if [ -f /etc/apache2/apache2.conf ]; then
        sed -i 's/MaxKeepAliveRequests 100/MaxKeepAliveRequests 1000/' /etc/apache2/apache2.conf
        sed -i 's/KeepAliveTimeout 5/KeepAliveTimeout 2/' /etc/apache2/apache2.conf
    fi
    
    log "Otimizações aplicadas"
}

# Função para testar a instalação
test_installation() {
    log "Realizando testes finais..."
    
    # Testar se Apache está rodando
    if systemctl is-active --quiet apache2 || systemctl is-active --quiet httpd; then
        log "✅ Apache está rodando"
    else
        error "❌ Apache não está rodando"
        return 1
    fi
    
    # Testar se porta 80 está aberta
    if netstat -tuln | grep ':80 ' > /dev/null; then
        log "✅ Porta 80 está ouvindo"
    else
        error "❌ Porta 80 não está ouvindo"
        return 1
    fi
    
    # Testar se página web está acessível
    if curl -s -I http://localhost | grep "200 OK" > /dev/null; then
        log "✅ Página web está respondendo"
    else
        error "❌ Página web não está respondendo"
        return 1
    fi
    
    log "✅ Todos os testes passaram com sucesso!"
}

# Função para gerar relatório
generate_report() {
    log "Gerando relatório final..."
    
    REPORT_FILE="/tmp/provisionamento_relatorio_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > $REPORT_FILE << EOF
RELATÓRIO DE PROVISIONAMENTO - SERVIDOR WEB APACHE
==================================================
Data: $(date)
Script: $0

SERVIÇOS INSTALADOS:
- Apache Web Server: $(apache2 -v 2>/dev/null | head -n1 || httpd -v 2>/dev/null | head -n1)

CONFIGURAÇÕES:
- Site: $SITE_NAME
- Web Root: $WEB_ROOT/$SITE_NAME
- Backup Dir: $BACKUP_DIR
- Log Dir: $LOG_DIR
- Admin User: $SITE_ADMIN

ESTRUTURA CRIADA:
$(tree $WEB_ROOT/$SITE_NAME 2>/dev/null || find $WEB_ROOT/$SITE_NAME -type f | head -20)

SERVIÇOS ATIVOS:
$(systemctl status apache2 2>/dev/null || systemctl status httpd 2>/dev/null)

PORTAS ABERTAS:
$(netstat -tuln | grep ':80\|:443')

SCRIPTS AUXILIARES:
- Monitoramento: /usr/local/bin/monitor-apache.sh
- Backup: /usr/local/bin/backup-website.sh

PRÓXIMOS PASSOS:
1. Configure o DNS para apontar para este servidor
2. Execute: certbot --apache -d $SITE_NAME (para SSL)
3. Acesse: http://$(hostname -I 2>/dev/null | awk '{print $1}')

PROVISIONAMENTO CONCLUÍDO COM SUCESSO!
EOF

    echo
    info "RELATÓRIO SALVO EM: $REPORT_FILE"
    echo
    cat $REPORT_FILE
}

# Função principal
main() {
    echo
    log "INICIANDO PROVISIONAMENTO DO SERVIDOR WEB APACHE"
    log "================================================"
    echo
    
    # Executar funções na ordem
    check_root
    detect_os
    update_system
    install_apache
    configure_firewall
    create_directories
    create_admin_user
    create_sample_website
    create_virtual_host
    configure_optimizations
    setup_ssl
    create_monitoring_script
    create_backup_script
    test_installation
    generate_report
    
    echo
    log "================================================"
    log "PROVISIONAMENTO CONCLUÍDO COM SUCESSO!"
    log "================================================"
    echo
    info "Acesse seu site em: http://$(hostname -I 2>/dev/null | awk '{print $1}')"
    info "Ou edite /etc/hosts e adicione: $(hostname -I 2>/dev/null | awk '{print $1}') $SITE_NAME"
    info "Script de monitoramento: /usr/local/bin/monitor-apache.sh"
    info "Script de backup: /usr/local/bin/backup-website.sh"
    echo
}

# Manipular sinal de interrupção
trap 'error "Script interrompido pelo usuário"; exit 1' INT TERM

# Executar função principal
main "$@"