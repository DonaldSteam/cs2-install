#!/bin/bash
read -p "steam4" INSTALL_USER
read -p "Vampx143" USERNAME
read -p "csdm_cs2" SERVER_FOLDER_NAME
read -p "89.23.113.11" SERVER_IP
read -p "27015" SERVER_PORT
read -p "20" SLOTS

# Колдуем над пакетами
apt update && apt upgrade -y
add-apt-repository multiverse
dpkg --add-architecture i386
apt install -y wget sudo screen software-properties-common lib32gcc-s1

# Колдуем над steamcmd
cd /home && mkdir -p steamcmd && cd steamcmd
wget http://media.steampowered.com/client/steamcmd_linux.tar.gz
tar xvfz steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz
sudo -u $INSTALL_USER /home/steamcmd/steamcmd.sh +login $USERNAME +force_install_dir /home/$SERVER_FOLDER_NAME +app_update 730 +exit

# Создание папки .steam
if [ "$INSTALL_USER" = "root" ]; then
    cd /root && mkdir -p .steam
else
    cd /home/$INSTALL_USER && mkdir -p .steam
fi

# Копирование steamclient.so в папку .steam/sdk64
if [ "$INSTALL_USER" = "root" ]; then
    cd /root/.steam && mkdir -p sdk64
    cp /home/steamcmd/linux64/steamclient.so /root/.steam/sdk64
else
    cd /home/$INSTALL_USER/.steam && mkdir -p sdk64
    cp /home/steamcmd/linux64/steamclient.so /home/$INSTALL_USER/.steam/sdk64
fi

# Создание файлов запуска, выключения и перезагрузки
if [ "$INSTALL_USER" = "root" ]; then
    cd /root
else
    cd /home/$INSTALL_USER
fi

# start.sh
echo '#!/bin/bash' > start.sh
echo "screen -dmS $SERVER_FOLDER_NAME /home/$SERVER_FOLDER_NAME/game/bin/linuxsteamrt64/cs2 +ip $SERVER_IP -port $SERVER_PORT -game csgo -dedicated -console -condebug console.log -maxplayers $SLOTS +map de_dust2" >> start.sh
echo 'echo "Сервер запускается"' >> start.sh
chmod +x start.sh

# stop.sh
echo '#!/bin/bash' > stop.sh
echo "screen -X -S $SERVER_FOLDER_NAME quit" >> stop.sh
echo 'echo "Сервер выключается"' >> stop.sh
chmod +x stop.sh

# restart.sh
echo '#!/bin/bash' > restart.sh
echo "./stop.sh && sleep 5 && ./start.sh" >> restart.sh
echo 'echo "Сервер перезагружается"' >> restart.sh
chmod +x restart.sh

echo "Установка сервера завершена."
echo "Управление:"
echo "./start.sh - запустить сервер"
echo "./stop.sh - выключить сервер"
echo "./restart.sh - перезапустить сервер"
echo "screen -r - открыть консоль сервера"
