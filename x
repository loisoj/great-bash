#!/usr/bin/env bash

# имя функции для запуска
FUNCTION=
if [ ! -z $1 ]; then
    FUNCTION="$1"
fi

showHelp(){
  echo -e "Не забываем sudo ./x для норм. работы: "
  echo -e "givemesoft - для новой ОС"
  echo -e "dockerinst/dockerdel - установка/удаление docker"
  echo -e "dockerapp - развертывание докер среды разработки"
  echo -e "torbuild/torstart/torstop - установка/включение/выключение TOR"
  echo -e "filekiller - найти и удалить файл/файлы по маске"
  echo -e "prockiller - убить процесс по имени"
  echo -e "zipkey - создать зашифрованный архив и удалить исходник"
  echo -e "cod - проверка статуса ответа сайта из консоли"
  echo -e ""
}

filekiller(){
  echo -e "Enter file name(file.txt or *.txt): "
read filetokill
echo -e "Enter dir path(from ~ to dir './Documents/dir'): "
read dptofile
echo -e "1-Find and dell files only in dir;
2-Find and dell files in dir recursively(-r)"
read killmodx

if [ $killmodx -eq 1 ]; then
cd ~
find $dptofile -type f -eame "$filetokill" -delete
fi

if [ $killmodx -eq 2 ]; then
cd ~
find $dptofile -eame $filetokill | xargs rm -rf
fi
}

cod(){
echo -e "Wait the URL: "
read urltotestcod
echo -e ""
curl -Is $urltotestcod | head -n 1
}

prockiller(){
  echo -e "Enter proc name: "
read dirx
kill `ps aux|grep $dirx|sed "s/root *\([0-9]*\) .*/\1/"`. 2>/dev/null
echo "Die".$dirx
}

zipkey(){
  echo -e "Enter Dir or Zip(без .zip) name: "
read dirx
if [ -d ./$dirx/ ]; then
echo -e "New Pass: "
read spx

zip --password $spx -r $dirx.zip $dirx
rm -rf $dirx/
else
unzip $dirx.zip
rm -rf $dirx.zip
fi
}

givemesoft(){
sudo apt-get install git -y
sudo apt-get install curl -y
sudo add-apt-repository ppa:webupd8team/atom -y
sudo apt-get update -y
sudo apt-get install atom -y
sudo apt-get install gimp -y
sudo apt-get install terminator -y
wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
sudo dpkg -i gitkraken-amd64.deb -y
sudo add-apt-repository ppa:atareao/telegram -y
sudo apt-get update -y
sudo apt-get install telegram -y
sudo apt-get install php
}

dockerinst(){
  sudo apt-get install curl
  sudo apt-get update
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt-get update
  apt-cache policy docker-engine
  sudo apt-get install -y docker-engine
  sudo usermod -aG docker $(whoami)
  sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker -v
  docker-compose -v
}

dockerdel(){
  sudo apt purge *docker*
sudo apt autoremove -y --purge *docker*
sudo autoclean
sudo groupdel docker
}

dockerapp(){
  cd ~
  echo "Starting full install..."
  sudo apt-get install git
  echo "Git installed +"
  git clone https://github.com/loisoj/yupe-docker.git
  echo "git clone end +"
  chmod +x ./yupe-docker/yupe
  cd yupe-docker
  ./yupe set-env dev
  ./yupe alive
  echo "yupe docker installed +"
  echo "Base Started! +"
  echo " "
  echo "Starting installing Monitor System..."
  git clone https://github.com/loisoj/dockermonitoring
  cd dockermonitoring
  docker-compose up -d
  docker ps
  echo " "
  echo "Done!"
}

torbuild(){
sudo apt-get install tor
sudo sh -c "echo 'VirtualAddrNetworkIPv4 10.192.0.0/10' >> /etc/tor/torrc"
sudo sh -c "echo 'AutomapHostsOnResolve 1' >> /etc/tor/torrc"
sudo sh -c "echo 'TransPort 9040' >> /etc/tor/torrc"
sudo sh -c "echo 'DNSPort 53' >> /etc/tor/torrc"
sudo sh -c "echo 'ExcludeExitNodes {RU},{UA},{BY}' >> /etc/tor/torrc"
}

torstart() {

pickTheVers=`grep tor /etc/passwd`
fly=${pickTheVers:13:3}

sudo rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf

_non_tor="192.168.1.0/24 192.168.0.0/24"

_tor_uid="$fly"

_trans_port="9040"

iptables -F
iptables -t nat -F

iptables -t nat -A OUTPUT -m owner --uid-owner $_tor_uid -j RETURN
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53

for _clearnet in $_non_tor 127.0.0.0/9 127.128.0.0/10; do
   iptables -t nat -A OUTPUT -d $_clearnet -j RETURN
done

iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $_trans_port

iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

for _clearnet in $_non_tor 127.0.0.0/8; do
   iptables -A OUTPUT -d $_clearnet -j ACCEPT
done

iptables -A OUTPUT -m owner --uid-owner $_tor_uid -j ACCEPT
iptables -A OUTPUT -j REJECT

}

torstop() {
echo "Stopping firewall and allowing everyone..."
sudo chattr -i /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
}

   if [ ! -z $(type -t $FUNCTION | grep function) ]; then
        init-xdebug
        check-env
        $1
    else
        showHelp
fi
