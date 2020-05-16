#!/bin/sh
#
# Systemback Debian packages installer script.
#
# Compatible with Debian 10.0 Buster
#                 Ubuntu 18.04 (Bionic Beaver)
#                 Ubuntu 20.04 (Focal Fossa))
#
# This script can be used and modified freely, without any restrictions.
#
# Original Author Krisztián Kende <nemh@freemail.hu>
# Last modification and others bug fix 2018.04.21. by Franco Conidi aka edmond http://francoconidi.it edmondweblog@gmail.com


[ $(id -ur) = 0 ] || {
  tput bold
  tput setaf 1

  cat << EOF

 Root privileges are required for running Systemback installer!

EOF

  tput sgr0
  exit 1
}

case "$(lsb_release -cs)" in
    Buster)
    release=Debian_Buster
    ;;
    artful)
    release=Ubuntu_Focal
    ;;
    bionic)
    release=Ubuntu_Bionic
    ;;
  *)
    tput bold
    tput setaf 1

    cat << EOF

EOF

    tput sgr0
    tput bold

    cat << EOF
 Press 'A' to abort the installation, or select one of the following releases:

  1 ─ Debian 10.0 (Buster)
  2 ─ Ubuntu 20.04 (Focal Fossa)
  3 ─ Ubuntu 18.04 (Bionic Beaver)
EOF

    tput civis
    tput invis
    [ ! "$release" ] || release=""

    until [ "$release" ]
    do
      read -n 1 input 2>/dev/null || input=$(bash -c 'read -n 1 i ; printf $i')

      case $input in
        [aA])
          break
          ;;
        1)
          release=Debian_Buster
          ;;
        2)
          release=Ubuntu_Focal
          ;;
        3)
          release=Ubuntu_Bionic
      esac
    done

    tput cnorm
    tput sgr0
    echo
    [ "$release" ] || exit
esac

parch=$(getconf LONG_BIT)
dpath="$(printf "$0" | head -c -10)"packages/

if [ $(expr length "$dpath") -le 11 ]
then ver=$(pwd | tail -c 8)
else ver=$(printf "$dpath" | tail -c 17 | head -c 7)
fi

[ "$1" = -d ] || (dpkg -l | grep -E "^ii +l?i?b?systemback" | grep "\-dbg" >/dev/null && apt-get remove --purge -y --force-yes systemback-dbg* systemback-cli-dbg systemback-scheduler-dbg)

if [ $parch = 64 ]
then
  pkgs="'$dpath'"*.deb

  for a in "$dpath"$release/*amd64.deb
  do printf "$a" | grep "\-dbg" >/dev/null || pkgs="$pkgs '$a'"
  done
else
  pkgs="'$dpath'"*locales*.deb

  for a in "$dpath"$release/*i386.deb
  do printf "$a" | grep "\-dbg" >/dev/null || pkgs="$pkgs '$a'"
  done
fi

sh -c "dpkg -i $pkgs"
[ $? = 0 ] || apt-get install -fym --force-yes

[ $? = 0 ] && {
  if [ "$1" = -d ]
  then
    if [ $parch = 64 ]
    then
      cnt=10
      dpkg -i "$dpath"$release/*dbg*amd64.deb
    else
      cnt=9
      dpkg -i "$dpath"$release/*dbg*i386.deb
    fi
  elif [ $parch = 64 ]
  then cnt=6
  else cnt=5
  fi
}

if [ $? = 0 ] && [ $(dpkg -l | grep -E "^ii +l?i?b?systemback" | grep -c " $ver ") = $cnt ]
then
  tput bold

  cat << EOF

 Systemback installation is successful.


EOF

  tput sgr0
  exit 2
fi
