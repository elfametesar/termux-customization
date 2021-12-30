#!/bin/bash
set -e
restore(){
  echo -e "\e[37mReversing changes...\n\e[0m"
   echo "$bashrcbk" > $PREFIX/etc/bash.bashrc
   [ ! -z "$subk" ] && echo "$subk" > $PREFIX/bin/su || echo -e "\e[1;31mSu binary is missing or corrupted therefore irreversible\n\e[0m"
   PS1="$ps1bk"
   echo -e "\e[1;31mBecause of the errors that happened during runtime, I reversed all possible changes\e[0m"
   exit
}
trap restore ERR

[ $UID -eq 0 ] && echo "You cannot run this as root!" && exit 1

#BACKUPS
bashrcbk=$(< $PREFIX/etc/bash.bashrc)
[ -f "$PREFIX/bin/su" ] && [ ! -z "$(cat $PREFIX/bin/su)" ] && subk=$(< $PREFIX/bin/su) || restore
ps1bk=$PS1


[ ! -d "$PREFIX/bin/root" ] && mkdir $PREFIX/bin/root
PATHX="$""PREFIX/bin/root:$""PATH"
SYMBOL="`[ "$UID" == "0" ] && echo "#" || echo '➜'`"
PS1='$(V="\$?" ;if [ $V == 0 ]; then echo \[\e[1\;32m\]; else echo \[\e[1\;31m\]; fi)$SYMBOL \[\e[1;36m\]$(pwd | xargs basename)\[\e[m\] '
echo -e "\e[37mInstalling unzip\e[0m"
pkg install unzip -y &> /dev/null

bash_rc(){
    echo "PATH=$PATHX" >> $PREFIX/etc/bash.bashrc
    echo "SYMBOL='$SYMBOL'" >> $PREFIX/etc/bash.bashrc
    echo "PS1='$PS1'" >> $PREFIX/etc/bash.bashrc
    echo 'HOME=$PREFIX/../home' >> $PREFIX/etc/bash.bashrc
    echo "" > $PREFIX/etc/motd
}

modify_su(){
    i=1
    start=$(grep -n '\-x \$p' ../usr/bin/su | cut -d: -f1)
    end=$(grep -n 'fi$' ../usr/bin/su | cut -d: -f1)
    let "start++"; let "end--"
    while IFS= read line; do
        if((i==start)); then
            echo -e '\t\tPATH=/sbin:/sbin/su:/su/bin:/su/xbin:/system/bin:/system/xbin:$PREFIX/bin'
        elif((i==start+1)); then
            echo -e "\t\techo \$@ | grep -q '\-.'"
        elif((i==start+2)); then
            echo -e '\t\t[ "$?" = "0" ] && exec $p "$@" || exec $p -c bash --rcfile ./bashrcsu\n\tfi'
        fi
        [ $i -lt $start ] || [ $i -gt $end ] && echo -e "$line"
        ((i++))
    done < $PREFIX/bin/su > $PREFIX/bin/root/su
    rm $PREFIX/bin/su
}

unpack_binary(){
    echo -e "\e[37mDownloading binaries\e[0m"
    wget https://github.com/erenmete/termux-customization/blob/main/termux.zip?raw=true &> /dev/null && mv "termux.zip?raw=true" termux.zip && unzip -o -qq termux.zip &> /dev/null
    cp -rf root $PREFIX/bin/ && rm -rf root
    chmod +x $PREFIX/bin/root/*
    rm termux.zip
}

bash_rc
modify_su
unpack_binary
echo -e "\e[1;32mYou can restart termux now to see the changes.\e[0m"
/system/bin/killall -9 "$SHELL"
/system/bin/app_process / com.termux.termuxam.Am stopservice com.termux/.app.TermuxService
