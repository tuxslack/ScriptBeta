#!/bin/bash
#
# AUTOR: Fernando Souza - https://www.youtube.com/@fernandosuporte
# Versão 0.1: 26/09/2023 as 03:04
#
# Um pacote XBPS é apenas um tarball compactado com alguns arquivos informativos na raiz.
#
# man xbps-create
#
#
#
# https://git.disroot.org/tuxliban/tutoriales_void
# https://www.reddit.com/r/voidlinux/comments/hqm7z2/xdeb_a_simple_utility_to_convert_debian_packages/
# https://www.vivaolinux.com.br/dica/Convertendo-pacotes-deb-Debian-para-xbps-Void-Linux/
# https://www.vivaolinux.com.br/artigos/impressora.php?codigo=12713
# http://smokey01.com/yad/
# https://pkgs.alpinelinux.org/contents?branch=edge&name=xbps&arch=x86_64&repo=community
# https://cjungmann.github.io/yaddemo/docs/yadbuttons.html
# https://www.cyberciti.biz/faq/bash-while-loop/



clear


which yad              || exit


titulo="Gerador de pacote xbps"


# pacote_xbps="$2"
# pasta="$2"




##### FUNCOES ######


extrair(){


which 7z      || exit
which zstdcat || exit



pacote_xbps=$(yad --center --title="$titulo" --file --file-filter "*.xbps" --width=600 --height=400 2>/dev/null)




     

# Como extrair o arquivo .xbps (tar/unzip/7z)?

# Quero apenas extrair um arquivo xbps criado usando xbps-create sem usar xbps(-install) no sistema.


# Lista os arquivos do pacote .xbps

zstdcat "$pacote_xbps" 2> /tmp/pacote_xbps.log | 7z l -ttar -si  

# echo $?

# zstd: can't stat  : No such file or directory -- ignored

if [ "" == "$(cat /tmp/pacote_xbps.log)" ];
then 

      echo -e "\n\n"


# Extrair os arquivos do pacote .xbps

zstdcat "$pacote_xbps" | 7z x -y -ttar -si

echo $?

# https://www.reddit.com/r/voidlinux/comments/x77gq3/how_to_extract_xbps_file_tarunzip7z/


else 

     yad --center --title='Aviso' --text='\n\nOcorreu um erro inesperado ao executar o comando zstdcat...\n\n' --timeout=10 --no-buttons 2>/dev/null

     exit
     
fi



}




gerar(){


# Pastas vazias é ignorada na hora da geração do pacote .xbps.


clear


which xbps-create      || exit
which xbps-rindex      || exit
which xbps-install     || exit



pasta=$(yad --center --title="$titulo" --file --directory --width=600 --height=400 2>/dev/null)



# Como construir um pacote com xbps-create?
#
# Construir um pacote sem xbps-src ou xdeb?

echo "
Construir um pacote a partir do código-fonte.
"

# A arquitetura do pacote.

arquitetura=$(uname -m)
# x86_64




# ----------------------------------------------------------------------------------------


# Nome do pacote

# nome/versão do pacote, por exemplo: 'foo-1.0_1'.


nome_do_pacote=$( yad \
        --center \
        --entry \
        --title="$titulo" \
        --entry-label="Qual o nome do pacote?" \
        --entry-text="unrar" \
        --completion \
        --editable \
        --width="700" \
        2> /dev/null
) 



# Para verificar se a variavel é nula

if [ -z "$nome_do_pacote" ];then

yad \
--center \
--title='Aviso' \
--text='\n\nVocê precisa informar o nome do pacote...\n\n' \
--timeout=10 \
--no-buttons 2>/dev/null

clear

exit 1

fi


# ----------------------------------------------------------------------------------------


# Versão do pacote

# nome/versão do pacote, por exemplo: 'foo-1.0_1'.


versao_do_pacote=$( yad \
        --center \
        --entry \
        --title="$titulo" \
        --entry-label="Qual a versão do pacote $nome_do_pacote?" \
        --entry-text="6.2.10_1" \
        --completion \
        --editable \
        --width="700" \
        2> /dev/null
) 



# Para verificar se a variavel é nula

if [ -z "$versao_do_pacote" ];then

yad \
--center \
--title='Aviso' \
--text='\n\nVocê precisa informar versão do pacote '$nome_do_pacote'...\n\n' \
--timeout=10 \
--no-buttons 2>/dev/null

clear

exit 1

fi


# ----------------------------------------------------------------------------------------

# A licença do pacote.


# licenca=$(yad --center --title="$titulo" --image=info --text="Qual a licença do pacote?" --entry --entry-text="GPL3.0" 2> /dev/null)

licenca=$(yad \
--center \
--radiolist \
--list \
--column=Marque --column=Licença --column=Descrição \
true "GPL3.0" "" \
false "" "" \
--width 600 --height 300 \
2> /dev/null)



licenca=$(echo "$licenca" | cut -d'|' -f2)



# Para verificar se a variavel é nula

if [ -z "$licenca" ];then

yad \
--center \
--title='Aviso' \
--text='\n\nVocê precisa informar a licença do pacote '$nome_do_pacote-$versao_do_pacote'...\n\n' \
--timeout=10 \
--no-buttons 2>/dev/null

clear

exit 1

fi


# https://diolinux.com.br/tecnologia/licencas-para-softwares.html
# https://tecnologia.uol.com.br/ultimas-noticias/redacao/2007/12/20/software-livre-freeware-shareware-copyleft-entenda-as-licencas-de-software.jhtm
# https://www.debian.org/legal/licenses/index.pt.html


# ----------------------------------------------------------------------------------------


# O nome do mantenedor do pacote e/ou contato de e-mail.


mantenedor=$( yad \
        --center \
        --entry \
        --title="$titulo" \
        --entry-label="Qual o nome do mantenedor do pacote $nome_do_pacote-$versao_do_pacote?" \
        --entry-text="$USER - $USER@localhost" \
        --completion \
        --editable \
        --width="700" \
        2> /dev/null
) 



# Para verificar se a variavel é nula

if [ -z "$mantenedor" ];then

yad \
--center \
--title='Aviso' \
--text='\n\nVocê precisa informar o nome do mantenedor do pacote '$nome_do_pacote-$versao_do_pacote'...\n\n' \
--timeout=10 \
--no-buttons 2>/dev/null

clear

exit 1

fi


# ----------------------------------------------------------------------------------------


# Uma breve descrição deste pacote, uma linha com menos de 80 caracteres.


descricao=$( yad \
        --center \
        --entry \
        --title="$titulo" \
        --entry-label="Qual a descrição do pacote $nome_do_pacote-$versao_do_pacote?
        
A descrição deve ter menos de 80 caracteres." \
        --entry-text="Pacote unrar para o Void Linux" \
        --completion \
        --editable \
        --width="700" \
        2> /dev/null
) 



# Para verificar se a variavel é nula

if [ -z "$descricao" ];then

yad \
--center \
--title='Aviso' \
--text='\n\nVocê precisa informar uma descrição para o pacote '$nome_do_pacote-$versao_do_pacote'...\n\n' \
--timeout=10 \
--no-buttons 2>/dev/null

clear

exit 1

fi



# Verificar se a descrição do pacote, tem menos de 80 caracteres.


# Calcula o comprimento da variável.

COMPRIMENTO=${#descricao}

# Verifica se o comprimento da variável é menor que 80.

if [ "$COMPRIMENTO" -lt "80" ]; then
    echo "A descrição do pacote possui menos de 80 caracteres"
else
    echo "A descrição do pacote possui 80 caracteres ou mais"
    
    exit 
fi
 
 
 
# ----------------------------------------------------------------------------------------


# Uma longa descrição para este pacote.


descricao_longa=$( yad \
        --center \
        --entry \
        --title="$titulo" \
        --entry-label="Informe uma descrição longa para o pacote $nome_do_pacote-$versao_do_pacote?" \
        --entry-text="Pacote unrar para o Void Linux" \
        --completion \
        --editable \
        --width="700" \
        2> /dev/null
) 



# Para verificar se a variavel é nula

if [ -z "$descricao_longa" ];then

yad \
--center \
--title='Aviso' \
--text='\n\nVocê precisa informar uma descrição longa para o pacote '$nome_do_pacote-$versao_do_pacote'...\n\n' \
--timeout=10 \
--no-buttons 2>/dev/null

clear

exit 1

fi


# ----------------------------------------------------------------------------------------


# Lista de dependências
#
# Uma lista de padrões de pacotes dos quais este pacote depende, separados por espaços em branco. Exemplo: 'foo>=1.0 blá-1.0_1'.



dependencias=$( yad \
        --center \
        --entry \
        --title="$titulo" \
        --entry-label="Informe se o pacote '$nome_do_pacote-$versao_do_pacote' possui dependências?" \
        --entry-text="rar" \
        --completion \
        --editable \
        --width="700" \
        2> /dev/null
) 




# Para verificar se a variavel é nula

# if [ -z "$dependencias" ];then

# yad \
# --center \
# --title='Aviso' \
# --text='\n\nVocê precisa informar as dependências do pacote '$nome_do_pacote-$versao_do_pacote'...\n\n' \
# --timeout=10 \
# --no-buttons 2>/dev/null

# clear

# exit 1

# fi


# ----------------------------------------------------------------------------------------




# Para criar o pacote .xbps:


xbps-create -q -A "$arquitetura" -l "$licenca" -m "$mantenedor" -n "$nome_do_pacote-$versao_do_pacote" -s "$descricao" -S "$descricao_longa" -D "$dependencias" "$pasta"



# xbps-rindex -Ca ~/diretorio-onde-eu-construo-o-pacote/"$nome_do_pacote-$versao_do_pacote"."$arquitetura".xbps






# xbps-rindex -a "${out}.${archs}.xbps"

# log_success "Done. Install using \`xbps-install -R ${short_binpkgs} ${out}\`"



# Se você usar xbps-create diretamente, deverá ter cuidado. Eu provavelmente sugeriria que você usasse xbps-src porque ele vem com muitas coisas que evitam problemas como esse.

# Existe xbps-pkgdb -a para encontrar coisas que seu pacote pode ter quebrado.






# xbps-install --repository=~/kitty-0.16_0.x86_64.xbps kitty


}





MENSAGEM_USO="
Uso: $(basename "$0") [-h | -V]

Com esse script você pode extrair e gerar um pacote .xbps no Void Linux.



Faça bom uso do programa!

-h, --help	Mostra essa tela de ajuda
-V, --version	Mostra a versão do programa

-e, --extrair   Extrai um pacote .xbps

Ex: $(basename "$0") -e pacote.xbps


-g, --gerar     Gera  um pacote .xbps

Ex: $(basename "$0") -g pasta


-gtk            Interface grafica para o $(basename "$0")

Ex: $(basename "$0") -gtk

"




listar(){


# Pastas vazias é ignorada na visualização do pacote .xbps.

which 7z      || exit
which zstdcat || exit



pacote_xbps=$(yad --center --title="$titulo" --file --file-filter "*.xbps" --width=600 --height=400 2>/dev/null)


# Lista os arquivos do pacote .xbps

zstdcat "$pacote_xbps" 2> /tmp/pacote_xbps.log | 7z l -ttar -si  | yad --center --title="$titulo" --text-info --fontname "mono 10" --width 800 --height 700 2> /dev/null

cat /tmp/pacote_xbps.log


}




    

case "$1" in

-gtk)


# Inicio do laço de repetição - While

while :
do

# yad --center  --button=gtk-floppy:0 --button=gtk-preferences:0 --button=gtk-info:0 

yad --center  --title="$titulo" --borders=20 \
    --button="Extrair":0 \
    --button="Listar":3 \
    --button="Gerar":2 \
    --button="Ajuda":1 \
    --button="Exit":4 2> /dev/null

case $? in
   0) $(basename "$0") -e ;;
   1) $(basename "$0") -h ;;
   2) $(basename "$0") -g ;;
   3) $(basename "$0") -l ;;
   4) break ;;  
esac
  
  
done


# Fim do laço de repetição - While
  

;;



-l | --listar)

listar

;;



-e | --extrair)

extrair "$2"

;;


-g | --gerar | --empacotar)

gerar

;;


-h | --help)


echo "$MENSAGEM_USO" | yad --center --title="$titulo" --text-info --fontname "mono 10" --width 700 --height 600 2> /dev/null

exit

;;


-V | --version)
	
	echo -n "$(basename "$0") =>"
	
	# Extrai a versão diretamente dos cabeçalhos do programa
	
	grep '^# Versão ' "$0" | tail -1 | cut -d: -f1 | tr -d \#

	
	exit 
;;


*)



	if test -n "$1"

	then

		

yad \
--center \
--title="$titulo" \
--text="

Opção Inválida: $(basename "$0") $1


Use para ajuda:

$(basename "$0") -h | --help  


" \
--dnd \
--width 300 --height 300 \
--button="OK" \
2> /dev/null


# --button=gtk-ok:"bash -c on_click" --button=gtk-help:"bash -c help" --button=gtk-quit:0


	fi
	
	

	exit 



;;

esac


exit 0


