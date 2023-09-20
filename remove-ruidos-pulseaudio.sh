#!/bin/bash
# 
# Autor: Fernando Souza
#        Sidnei Serra
#
# Data: 18/09/2023 | 20/09/2023
# Nome: remove-ruidos-pulseaudio.sh
# Homepage: 
# Licença: GPL
# Sistema ultilizado: Debian 12
# 
# Cancelador de ruídos do PulseAudio
#
# 
# Como ativar o cancelador de ruído do Pulse Audio quando ele não funciona como deveria?
#
# Como ativar o Pulse Audio no lugar do Pipewire e ativar "alternativamente" o cancelador 
# de ruídos do Pulse.
#
# Como melhorar a qualidade de captação de áudio no Linux ativando o cancelamento de eco 
# e ruído, e também desativando o auto-ajuste dos níveis de volume.
#
#
# Obs: 
# 
# Testar o funcionamento do script primeiro em ambiente de teste só depois de tudo OK
# testar na máquina de produção.
#
#
# Problema relatado no Debian 12 mas no Debian 11 funcionava normalmente.
# 
# 
# Instale o script:
# 
# sudo mv -i remove-ruidos-pulseaudio.sh /usr/local/bin
# 
#
# Dê permissões de executável:
# 
# chmod +x /usr/local/bin/remove-ruidos-pulseaudio.sh
#
#
#
# https://www.youtube.com/watch?v=jwOvy-Tw2rg
# https://twitter.com/velox256
# https://www.youtube.com/@SidneiSerra-hq1zk
# https://www.vivaolinux.com.br/~velox256
# https://br.linkedin.com/in/sidnei-serra-3a99492b
# https://plus.diolinux.com.br/t/ative-o-cancelamento-de-eco-e-ruido-do-microfone-no-linux/20146
# https://askubuntu.com/questions/279407/how-to-disable-microphone-from-auto-adjusting-its-input-volume/829996#829996
# https://plus.diolinux.com.br/t/ative-o-cancelamento-de-eco-e-ruido-do-microfone-no-linux/20146
# https://diolinux.com.br/tutoriais/cancelamento-de-eco-e-ruido-no-linux.html
# https://plus.diolinux.com.br/t/reducao-de-ruidos-de-microfone-em-reunioes-ao-vivo/41909/6
# https://plus.diolinux.com.br/t/cancelamento-do-ruido-no-microfone-fedora-36/45797
#
#
# Prova do problema
#
# https://plus.diolinux.com.br/t/microfone-com-ruido-forte-e-retorno-no-manjaro-gnome/43100
# https://youtu.be/a5bM03BMkqM


# https://forum.snapcraft.io/t/archived-winesnap-creating-snaps-for-windows-applications/6392
# https://doc.ubuntu-fr.org/yad_yet_another_dialog




which pactl       || exit 
# pactl info      || exit 
which pavucontrol || exit 
which nano        || exit 








sem_ruidos(){

# Verificar se o arquivo existe

if [ -e "/etc/pulse/default.pa" ] ; then

clear

echo "O arquivo /etc/pulse/default.pa existe."


echo ""


pactl unload-module module-echo-cancel
pactl load-module module-echo-cancel aec_method=webrtc source_name=echocancel
pactl set-default-source echocancel
pactl set-default-sink `pactl info | grep -i "Destino padrão:" | cut -d":" -f2`


 
 
# su -c 'nano /etc/pulse/default.pa'




else

clear

echo "O arquivo /etc/pulse/default.pa não existe."

exit

fi


}



instalar(){



# Opções de como iniciar esse script.


opcao=$(yad \
--center \
--title="Metodo para iniciar esse script" \
--width 800 --height 200 \
--text-align="center" \
--list --radiolist \
--column="Selecionado" --column="Opções"  --column="Informação" \
False "atalho"      "Manual via arquivo .desktop"  \
False "autostart"   "Iniciar junto com o Gnome, KDE via autostart"  \
False "sistema"     "Iniciar com o sistema via arquivo /etc/rc.local" \
False "systemd"     "Iniciar com o sistema opção voltada para o Systemd" \
2> /dev/null )


opcao=$(echo "$opcao" | cut -d'|' -f2)



if [[ "$opcao" = "atalho" ]]
then



# ----------------------------------------------------------------------------------------

# Metodo manual

# Verificar se o arquivo existe

if [ -e "$HOME/.local/share/applications/echocancel.desktop" ] ; then

clear

echo "O arquivo $HOME/.local/share/applications/echocancel.desktop existe."



else

clear

echo "O arquivo $HOME/.local/share/applications/echocancel.desktop não existe."


# yad \
# --center \
# --title='Aviso' \
# --text='\n\nNão foi possível acessar $HOME/.local/share/applications/echocancel.desktop arquivo inexistente!' 
# --timeout=10 
# --no-buttons 2>/dev/null



# Crie o arquivo para o menu de aplicativos:

echo "[Desktop Entry]
Version=1.0
Name=Cancelador de ruídos do PulseAudio
Comment=Carregar o módulo echo cancel do PulseAudio.
Exec=/usr/local/bin/remove-ruidos-pulseaudio.sh --sem_ruidos
Icon=multimedia-volume-control
Type=Application
Categories=AudioVideo;Audio;"
> $HOME/.local/share/applications/echocancel.desktop


fi



# ----------------------------------------------------------------------------------------



elif  [[ "$opcao" = "autostart" ]]
then


# ----------------------------------------------------------------------------------------

# Metodo automatico


# Para ativação quando precisar, basta clicar no ícone na sua listagem de programas. para 
# ativá-lo sempre que ligara  máquina, coloque o arquivo na inicialização do sistema.
#
#
# Opção 1
#
# Gnome, KDE:
#
#
# $HOME/.config/autostart/
#
# ou
#
# /etc/xdg/autostart


echo "[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Cancelador de ruídos do PulseAudio
Comment=Carregar o módulo echo cancel do PulseAudio.
Exec=/usr/local/bin/remove-ruidos-pulseaudio.sh --sem_ruidos
Icon=multimedia-volume-control
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
" > $HOME/.config/autostart/echocancel.desktop


# ----------------------------------------------------------------------------------------


elif  [[ "$opcao" = "sistema" ]]
then


# ----------------------------------------------------------------------------------------

# Metodo automatico


# Opção 2
#
# /etc/rc.local
#


# Verificar se o arquivo existe

if [ -e "/etc/rc.local" ] ; then

clear

echo "
O arquivo /etc/rc.local existe.
"

su -c 'echo "# Cancelador de ruídos do PulseAudio

/usr/local/bin/remove-ruidos-pulseaudio.sh --sem_ruidos &

" >> /etc/rc.local'


else

clear

echo "
O arquivo /etc/rc.local não existe.
"

fi



# ----------------------------------------------------------------------------------------


elif  [[ "$opcao" = "systemd" ]]
then


# ----------------------------------------------------------------------------------------


# Verificar se o diretório /etc/systemd/system/ existe
#
# -d nos ajuda a saber se o diretório existe, se mudarmos -d para -f é para verificar a existência de arquivos.


if [ -d /etc/systemd/system/ ]; then

clear


# Criando um arquivo Unit para a inicialização do script.

su -c 'echo "[Unit]
Description=Cancelador de ruídos do PulseAudio
[Service]
Type=simple
RemainAfterExit=yes
ExecStart=/usr/local/bin/remove-ruidos-pulseaudio.sh --sem_ruidos
# ExecStop=
# ExecReload=
[Install]
#
# multi-user.target => Ponto em que o sistema já permite multi-usuários (non-graphical) no sistema.
#
WantedBy=multi-user.target" > /etc/systemd/system/cancelamento_de_ruido.service'



# Para atualizar/carregar o arquivo que voce criou

echo "
Recarregue a nova definição do serviço...
"

su -c 'systemctl daemon-reload'



# Para habilitar o script na inicialização do sistema.

echo "
Ativando o serviço...
"
su -c 'systemctl enable cancelamento_de_ruido.service'



# Seu script esta habilitado para iniciar e também os seguintes atributos:

# Inicia o serviço.

su -c 'systemctl start   cancelamento_de_ruido.service'


# Mostra detalhes sobre o serviço, como log, se está em execução e etc.

systemctl status  cancelamento_de_ruido.service


# systemctl stop    cancelamento_de_ruido.service
# systemctl restart cancelamento_de_ruido.service



yad \
--center \
--title="Cancelador de ruídos do PulseAudio" \
--width=700 --height=100 \
--text='
# Reinicie o sistema agora.

Apos o reinicio execute "systemctl status cancelamento_de_ruido.service" para ver se esta 
OK o serviço.

' \
--on-top \
--image=gtk-dialog-question \
--window-icon=yad \
2> /dev/null



else

clear

echo "
A pasta /etc/systemd/system/ não existe.
"

fi


# ----------------------------------------------------------------------------------------


# https://plus.diolinux.com.br/t/executar-um-script-na-inicializacao-do-debian-12/56881
# https://blog.remontti.com.br/2478
# https://embarcados.com.br/systemd-adicionando-scripts-na-inicializacao-do-linux/





fi
 

}





remover(){

clear

rm -Rf $HOME/.local/share/applications/echocancel.desktop
rm -Rf $HOME/.config/autostart/echocancel.desktop
su -c 'rm -Rf /etc/systemd/system/cancelamento_de_ruido.service'


# nano /etc/rc.local

# nano /etc/pulse/default.pa


# su -c 'rm -Rf /usr/local/bin/remove-ruidos-pulseaudio.sh'


# Resetar o pulseaudio: 

# pulseaudio -k


}



# Central de Ajuda

ajuda(){

clear

echo "

Para quem usa o PipeWire / PulseAudio



# Programas necessários para família Debian:
#
# gstreamer1.0-pulseaudio
# pulseaudio
# pulseaudio-utils

Adaptar os nomes dos pacotes acima para outras distribuições Linux que não seja de origem Debian.


Kernel: `uname -r`

Placa de áudio: 

`lspci | grep -i audio`



`pactl info`


O script $(basename $0) pode ser usado com as seguintes opções:


--sr ou --sem_ruidos => Remove ruídos do PulseAudio;
--i                  => Realiza a instalação do script no sistema (adiciona o filtro no PipeWire);
--r                  => Remove o script e suas configurações do sistema;
--h                  => Mostra essa mensagem de ajuda.

"

}


# ====================================================

case "$1" in

    --sr | --sem_ruidos)
    
        sem_ruidos

        ;;
    --i)
        instalar

        ;;

    --r)
        remover

        ;;

    --h)
        ajuda

        ;;
                
    * )
    
        clear
        
        echo "
        Opção inválida, use $(basename $0) --sr ou --sem_ruidos | --i | --r | --h 
        
        
        Para ajuda:
        
        $(basename $0) --h
        "
                
        ;;
esac


exit 0

