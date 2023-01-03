#!/bin/bash

#===============================================================>
#=====>		NAME:		auto_install_routinator.sh
#=====>		VERSION:	1.0
#=====>		DESCRIPTION:	Auto Instalação Routinator
#=====>		CREATE DATE:	28/12/2022
#=====>		WRITTEN BY:	Ivan da Silva Bispo Junior
#=====>		E-MAIL:		contato@ivanjr.eti.br
#=====>		DISTRO:		Debian GNU/Linux 11 (Bullseye)
#===============================================================>

apt update && apt upgrade -y

apt isntall sudo -y

sudo apt install wget gnupg2 apt-transport-https software-properties-common net-tools nftables -y

echo 'deb [arch=amd64] https://packages.nlnetlabs.nl/linux/debian/ bullseye main' >  /etc/apt/sources.list.d/nlnetlabs.list

wget -qO- https://packages.nlnetlabs.nl/aptkey.asc | apt-key add -

apt update

apt install routinator -y

systemctl enable routinator

routinator-init --accept-arin-rpa

sudo sed -i "s/#rtr-listen = ["127.0.0.1:3323"]/rtr-listen = [ "[::]:3323" ]/" /etc/routinator/routinator.conf
sudo sed -i "s/#http-listen = ["127.0.0.1:8323"]/http-listen = [ "[::]:8323" ]/" /etc/routinator/routinator.conf

systemctl start routinator

clear

systemctl enable nftables

cp /etc/nftables.conf /etc/nftables.conf.bkp

rm -R /etc/nftables.conf

cat << EOF >> /etc/nftables.conf
#!/usr/sbin/nft -f
  
flush ruleset
 
table inet filter {
 
    # IPs que serão permitidos ter acesso ao routinator
    set acesso-routinator-v4 {
        type ipv4_addr
        flags interval
        elements = { 127.0.0.1, 192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8, 100.64.0.0/10, 200.200.200.0/22 }
    }
    set acesso-routinator-v6 {
        type ipv6_addr
        flags interval
        elements = { ::1,  2804:bebe:bebe::/48 }
    }
  
    chain input {
        type filter hook input priority 0;
 
        # RTR
        ip saddr  @acesso-routinator-v4 udp dport 3323 counter accept
        ip6 saddr @acesso-routinator-v6 udp dport 3323 counter accept
        udp dport 3323 counter drop
        
        # HTTP
        ip saddr  @acesso-routinator-v4 udp dport 8323 counter accept
        ip6 saddr @acesso-routinator-v6 udp dport 8323 counter accept
        udp dport 8323 counter drop
 
        type filter hook input priority 0;
    }
    chain forward {
        type filter hook forward priority 0;
    }
    chain output {
        type filter hook output priority 0;
    }
}
EOF

systemctl restart nftables

clear

sudo apt install bash-completion fzf grc -y

clear

=========
echo '' >> /etc/bash.bashrc
echo '# Autocompletar extra' >> /etc/bash.bashrc
echo 'if ! shopt -oq posix; then' >> /etc/bash.bashrc
echo '  if [ -f /usr/share/bash-completion/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
echo '  elif [ -f /etc/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /etc/bash_completion' >> /etc/bash.bashrc
echo '  fi' >> /etc/bash.bashrc
echo 'fi' >> /etc/bash.bashrc
sed -i 's/"syntax on/syntax on/' /etc/vim/vimrc
sed -i 's/"set background=dark/set background=dark/' /etc/vim/vimrc
cat <<EOF >/root/.vimrc
set showmatch " Mostrar colchetes correspondentes
set ts=4 " Ajuste tab
set sts=4 " Ajuste tab
set sw=4 " Ajuste tab
set autoindent " Ajuste tab
set smartindent " Ajuste tab
set smarttab " Ajuste tab
set expandtab " Ajuste tab
"set number " Mostra numero da linhas
EOF
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# alias ls='ls \$LS_OPTIONS'/alias ls='ls \$LS_OPTIONS'/" /root/.bashrc
sed -i "s/# alias ll='ls \$LS_OPTIONS -l'/alias ll='ls \$LS_OPTIONS -l'/" /root/.bashrc
sed -i "s/# alias l='ls \$LS_OPTIONS -lA'/alias l='ls \$LS_OPTIONS -lha'/" /root/.bashrc
echo '# Para usar o fzf use: CTRL+R' >> ~/.bashrc
echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc
echo "alias grep='grep --color'" >> /root/.bashrc
echo "alias egrep='egrep --color'" >> /root/.bashrc
echo "alias ip='ip -c'" >> /root/.bashrc
echo "alias diff='diff --color'" >> /root/.bashrc
echo "alias tail='grc tail'" >> /root/.bashrc
echo "alias ping='grc ping'" >> /root/.bashrc
echo "alias ps='grc ps'" >> /root/.bashrc
echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;31m\]\u\[\033[01;34m\]@\[\033[01;33m\]\h\[\033[01;34m\][\[\033[00m\]\[\033[01;37m\]\w\[\033[01;34m\]]\[\033[01;31m\]\\$\[\033[00m\] '" >> /root/.bashrc
echo "echo;echo 'SXZhbiBKciAtIENvbnN1bHRvcmlhIGVtIFRJQy4NCg0KV2Vic2l0ZSAuLi4uLi4uLi4uLjogaXZhbmpyLmV0aS5icg0KQ29udGF0byAuLi4uLi4uLi4uLi46IGNvbnRhdG9AaXZhbmpyLmV0aS5icg=='|base64 --decode; echo;" >> /root/.bashrc
=========
cat << EOF > /etc/issue
- Hostname do sistema ............: \n
- Data do sistema ................: \d
- Hora do sistema ................: \t
- IPv4 address ...................: \4
- Acess Web ......................: http://\4:8323
- Contato ........................: contato@ivanjr.eti.br
- Ivan Jr - Consultoria em TIC.

EOF
clear

IPVAR=`ip addr show | grep global | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | sed -n '1p'
`
echo http://$IPVAR:8323