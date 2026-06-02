cat << 'EOF' > setup_buttons.sh
#!/bin/sh

echo "=================================================="
echo " Starting piCorePlayer Button Control Installation"
echo "=================================================="

# 1. Extensies downloaden en installeren via tce-load
echo "--> Extensies installeren (nano, pcp-sbpd, pigpio)..."
tce-load -wi nano.tcz
tce-load -wi pcp-sbpd.tcz
tce-load -wi pigpio.tcz

# 2. Het sbpd-script aanmaken
echo "--> Het sbpd-script aanmaken in /home/tc/sbpd-script.sh..."
cat << 'INNER_EOF' > /home/tc/sbpd-script.sh
#!/bin/sh

# Start pigpiod daemon
pigpiod -t 0 -f -l -s 10

# Wait for pigpiod to initialize
count=10
while ! pigs t >/dev/null 2>&1; do
    if [ $((count--)) -le 0 ]; then
        printf "\npigpiod failed to initialize within time limit\n"
        exit 1
    fi
    sleep 1
done
printf "\npigpiod is running\n"

# Load uinput module
sudo modprobe uinput
sudo chmod g+w /dev/uinput

# GPIO assignments
SW3=24   # Play / Pause
SW1=6    # Volume Up
SW2=23   # Volume Down

# Build and run sbpd command
CMD="sbpd -v \
b,$SW3,PLAY,2,0,PLAY,250 \
b,$SW1,VOL+,2,0,VOL+,250 \
b,$SW2,VOL-,2,0,VOL-,250"

echo $CMD
$CMD > /dev/null 2>&1 &
INNER_EOF

# 3. Rechten uitvoerbaar maken
echo "--> Script uitvoerbaar maken..."
chmod +x /home/tc/sbpd-script.sh

# 4. Toevoegen aan User Commands in pcp.cfg (Tweaks pagina via CLI)
echo "--> Script toevoegen aan piCorePlayer User Commands..."
if [ -f /usr/local/etc/pcp/pcp.cfg ]; then
    # Zorg dat de regel USER_COMMAND_1 gevuld wordt
    sed -i 's|^USER_COMMAND_1=.*|USER_COMMAND_1="/home/tc/sbpd-script.sh"|' /usr/local/etc/pcp/pcp.cfg
    echo "--> Succesvol toegevoegd aan User Command #1."
else
    echo "⚠️ Waarschuwing: pcp.cfg niet gevonden. Voeg '/home/tc/sbpd-script.sh' handmatig toe via de Tweaks webpagina."
fi

# 5. Wijzigingen permanent opslaan in het piCorePlayer backup-systeem
echo "--> Wijzigingen opslaan in piCorePlayer backup (pcp bu)..."
pcp bu

echo "=================================================="
echo " Installatie voltooid! 🎉"
echo " Start nu het script handmatig om te testen via:"
echo " sudo /home/tc/sbpd-script.sh"
echo " Of herstart je Pi om de boot-activatie te testen via:"
echo " sudo reboot"
echo "=================================================="
EOF
