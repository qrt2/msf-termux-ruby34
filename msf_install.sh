#!/data/data/com.termux/files/usr/bin/bash

# Cores (Variáveis personalizadas)
vd='\033[0;32m'
az='\033[0;34m'
am='\033[1;33m'
vm='\033[0;31m'
reset='\033[0m'

# Função para centralizar texto
print_center() {
    local text="$1"
    local color="$2"
    local width=$(tput cols)
    local len=${#text}
    local padding=$(( (width - len) / 2 ))
    
    if [ $padding -lt 0 ]; then padding=0; fi
    
    printf "%${padding}s" ""
    echo -e "${color}${text}${reset}"
}

clear

# Banner Centralizado
echo -e "${az}"
print_center "███╗   ███╗███████╗███████╗" "${az}"
print_center "████╗ ████║██╔════╝██╔════╝" "${az}"
print_center "██╔████╔██║███████╗█████╗  " "${az}"
print_center "██║╚██╔╝██║╚════██║██╔══╝  " "${az}"
print_center "██║ ╚═╝ ██║███████║██║     " "${az}"
print_center "╚═╝     ╚═╝╚══════╝╚═╝     " "${az}"
echo ""
print_center "INSTALL METASPLOIT FRAMEWORK BY CYBER" "${vd}"
print_center "==============================================" "${az}"
echo ""

limpeza() {
    echo -e "${am} Removendo instalações anteriores..";sleep 0.5
    rm -rf $PREFIX/opt/metasploit-framework $PREFIX/var/lib/postgresql ~/.msf4 2>/dev/null
    rm -f $PREFIX/bin/msfconsole $PREFIX/bin/msfvenom 2>/dev/null
}

dep() {
    echo -e "${az} Instalando dependências..."
    pkg update -y && pkg upgrade -y && pkg install ruby git wget curl nodejs python ncurses-utils openssl libffi libiconv libxml2 libxslt libsqlite postgresql build-essential binutils readline libpcap -y 2>/dev/null
}

patch() {
    echo -e "${az} Aplicando patch de compilação no ${vd} Ruby => 3.4.0...";sleep 0.5
    find $PREFIX/include -name rbasic.h -exec sed -i 's/const VALUE klass;/VALUE klass;/g' {} +
}

down_meta() {
    echo -e "${am} Clonando Metasploit Framework ${vd} (versão estável)...${reset}"
    git clone https://github.com/rapid7/metasploit-framework $PREFIX/opt/metasploit-framework --depth=1
}

install_gems() {
    echo -e "${az} Instalando Gems ${am} (Processo um pouco demora aguarde )...${reset}"
    cd $PREFIX/opt/metasploit-framework
    gem install bundler
    bundle config set --local system 'true'
    bundle install
}

fix_bin() {
    echo -e "${az} Criando links simbólicos no sistema...";sleep 0.5
    ln -sf $PREFIX/opt/metasploit-framework/msfconsole $PREFIX/bin/msfconsole
    ln -sf $PREFIX/opt/metasploit-framework/msfvenom $PREFIX/bin/msfvenom
}

db_meta() {
    echo -e "${am} Inicializando Banco de Dados...";sleep 0.5
    initdb $PREFIX/var/lib/postgresql 2>/dev/null
    pg_ctl -D $PREFIX/var/lib/postgresql start 2>/dev/null
    createdb msf_db 2>/dev/null
    echo -e "\n ${az} Configurando conexão automática do banco...${reset}";sleep 0.5
    mkdir -p $PREFIX/opt/metasploit-framework/config
    cat <<EOF > $PREFIX/opt/metasploit-framework/config/database.yml
production:
  adapter: postgresql
  database: msf_db
  username: $(whoami)
  host: localhost
  port: 5432
  pool: 5
  timeout: 5
EOF
    echo -e "${az}"
    print_center "-------------------------------------------------------" "${az}"
    print_center " INSTALAÇÃO CONCLUÍDA COM SUCESSO!" "${vd}"
    print_center "       Para abrir, digite: msfconsole " "${am}"
    print_center "-------------------------------------------------------" "${az}"
    echo -e "${reset}"
}

# Execução das funções
limpeza
dep
patch
down_meta
install_gems
fix_bin
db_meta
