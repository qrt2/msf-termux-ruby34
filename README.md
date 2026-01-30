# 🛡️ Metasploit Framework Installer for Termux (Ruby 3.4.0 Fix)

![Termux](https://img.shields.io/badge/Termux-OS-black?style=for-the-badge&logo=termux)
![Ruby](https://img.shields.io/badge/Ruby-3.4.0-red?style=for-the-badge&logo=ruby)
![Status](https://img.shields.io/badge/Status-Stable-green?style=for-the-badge)

Este script automatiza a instalação completa do **Metasploit Framework** no Termux. O diferencial deste instalador é a correção do erro crítico de compilação da Gem **Nokogiri** e outras extensões nativas que surgiram com a atualização do **Ruby 3.4.0**.

## 🛠️ O que este script resolve?
Recentemente, a atualização do Ruby para a versão 3.4.0 quebrou a instalação de várias extensões em C (como o Nokogiri). Este script aplica um **patch direto nos headers do Ruby** (`rbasic.h`), removendo a restrição de `const` que impede a compilação correta no ambiente Android/Termux.

## ✨ Funcionalidades
* 🟢 **Instalação Limpa:** Remove versões antigas ou quebradas antes de começar.
* 💉 **Nokogiri Patch:** Aplica a correção de compilação para Ruby 3.4.0.
* 📊 **Auto-Database:** Configura e inicializa o banco de dados PostgreSQL (`msf_db`) automaticamente.
* 🚀 **Performance:** Utiliza clones rasos (`--depth=1`) para um download muito mais rápido.
* 🎨 **Interface Cyber:** Banner centralizado dinamicamente para qualquer tamanho de tela de celular.

## 📥 Como Instalar

Copie e cole o comando abaixo no seu Termux:

```bash
pkg install wget -y && wget [https://raw.githubusercontent.com/qrt2/msf-termux-ruby34/main/instalar_msf.sh](https://raw.githubusercontent.com/qrt2/msf-termux-ruby34/main/instalar_msf.sh) && chmod +x instalar_msf.sh && ./instalar_msf.sh


🖥️ Requisitos
​Termux (Atualizado via pkg update)
​Aproximadamente 1.5GB de espaço livre
​Conexão estável com a internet
​🤝 Créditos
​Desenvolvido por Cyber. t.me/cybe4
Focado em resolver problemas de compatibilidade da comunidade Termux-Hacking.
