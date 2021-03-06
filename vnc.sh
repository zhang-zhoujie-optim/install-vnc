#!/bin/bash

echo "Installing vnc..."
sudo apt update
sudo apt install -y xfce4 xfce4-goodies
sudo apt install -y tightvncserver

vncserver

vncserver -kill :1
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak

mkdir -p ~/.vnc/
touch ~/.vnc/xstartup

cat <<EOT >> ~/.vnc/xstartup
#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &
EOT

chmod +x ~/.vnc/xstartup

touch vncserver@.service

cat <<EOT >> ./vncserver@.service
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=$USER
Group=$USER
WorkingDirectory=$HOME

PIDFile=$HOME/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOT

sudo mv ./vncserver@.service /etc/systemd/system/vncserver@.service

sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1
