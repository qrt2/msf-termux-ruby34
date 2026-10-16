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
    echo -e "${am} Removendo instalações anteriores para evitar conflitos...${reset}"; sleep 0.5
    rm -rf $PREFIX/opt/metasploit-framework $PREFIX/var/lib/postgresql ~/.msf4 2>/dev/null
    rm -f $PREFIX/bin/msfconsole $PREFIX/bin/msfvenom 2>/dev/null
}

dep() {
    echo -e "${az} Atualizando repositórios e instalando dependências...${reset}"
    pkg update -y
    pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    
    pkg install clang make pkg-config ruby git wget curl nodejs python ncurses-utils openssl libffi libiconv libxml2 libxslt sqlite libsqlite postgresql build-essential binutils readline libpcap -y
}

patch() {
    echo -e "${az} Aplicando patch de compilação no Ruby...${reset}"; sleep 0.5
    find $PREFIX/include -name rbasic.h -exec sed -i 's/const VALUE klass;/VALUE klass;/g' {} + 2>/dev/null
}

down_meta() {
    echo -e "${am} Clonando Metasploit Framework (versão estável)...${reset}"
    git clone https://github.com/rapid7/metasploit-framework $PREFIX/opt/metasploit-framework --depth=1
    
    # Validação para impedir que o script continue se o Git falhar
    if [ ! -d "$PREFIX/opt/metasploit-framework" ]; then
        echo -e "${vm} Erro crítico: O download do Metasploit falhou. Verifique sua conexão e tente novamente.${reset}"
        exit 1
    fi
}

install_gems() {
    echo -e "${az} Configurando ambiente Ruby e Gems...${reset}"
    cd "$PREFIX/opt/metasploit-framework" || exit 1
    
    gem install bundler mini_portile2
    
    #Estrutura pra criar a Gem Dummy sqlite3
    mkdir -p dummy_sqlite3/lib/sqlite3

    cat << 'EOF' > dummy_sqlite3/sqlite3.gemspec
Gem::Specification.new do |s|
  s.name        = 'sqlite3'
  s.version     = '2.10.0'
  s.summary     = 'Dummy sqlite3 for Termux'
  s.authors     = ['Termux User']
  s.license     = 'MIT'
  s.files       = ["lib/sqlite3.rb", "lib/sqlite3/version.rb"]
end
EOF

    echo "module SQLite3; VERSION = '2.10.0'; end" > dummy_sqlite3/lib/sqlite3/version.rb

    cat << 'EOF' > dummy_sqlite3/lib/sqlite3.rb
module SQLite3
  class Database
    def initialize(*args); end
    def execute(*args); []; end
  end
end
EOF

    #Compilação segura entrando e saindo do diretório dummy
    (
        cd dummy_sqlite3 || exit 1
        gem build sqlite3.gemspec
        gem install sqlite3-2.10.0.gem --local
    )

    #Configuração do Bundler aplicada de volta na raiz do Metasploit
    bundle config set build.nokogiri --use-system-libraries
    
    echo -e "${am} Instalando Gems (Este processo pode demorar, aguarde)...${reset}"
    rm -f Gemfile.lock
    sed -i "s/'date', '3.4.1'/'date', '3.5.1'/g" metasploit-framework.gemspec
    sed -i 's/date (3.4.1)/date (3.5.1)/g' metasploit-framework.gemspec 2>/dev/null  
    bundle install
}

fix_bin() {
    echo -e "${az} Ajustando permissões e criando links simbólicos...${reset}"; sleep 0.5
    chmod +x "$PREFIX/opt/metasploit-framework/msfconsole"
    chmod +x "$PREFIX/opt/metasploit-framework/msfvenom"
    
    ln -sf "$PREFIX/opt/metasploit-framework/msfconsole" "$PREFIX/bin/msfconsole"
    ln -sf "$PREFIX/opt/metasploit-framework/msfvenom" "$PREFIX/bin/msfvenom"
}

db_meta() {
    echo -e "${am} Inicializando Banco de Dados...${reset}"; sleep 0.5
    rm -rf $PREFIX/var/lib/postgresql > /dev/null 2>&1

    initdb $PREFIX/var/lib/postgresql > /dev/null 2>&1
    pg_ctl -D $PREFIX/var/lib/postgresql start > /dev/null 2>&1

    sleep 2
    createdb msf_db > /dev/null 2>&1

    echo -e "${az} Configurando conexão automática do banco...${reset}"; sleep 0.5
    mkdir -p "$PREFIX/opt/metasploit-framework/config" > /dev/null 2>&1

    cat <<EOF > "$PREFIX/opt/metasploit-framework/config/database.yml"
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

#Execução das funções em ordem lógica e segura
limpeza
dep
patch
down_meta
install_gems
fix_bin
db_meta
