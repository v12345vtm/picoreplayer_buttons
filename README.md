# picoreplayer_buttons
add hardware buttons to a picoreplayer with homeassistant lms-server addon


https://forums.lyrion.org/forum/user-forums/general-discussion/1808065-sonos-out-picoreplayer-in?view=thread


om via cli en ssh alles in 1 keer te installeren doe je als volgt : 
inloggen met ssh met tc en u aangemaakte wachtwoord


1) open ssh en plak de RAW inhoud van bestand in 1 keer in de ssh en na het plakken DRUK OP ENTER  : 
https://github.com/v12345vtm/picoreplayer_buttons/blob/main/picoresonos.sh

2)maak het bestand die je net plakte uitvoerbaar met commando : chmod +x setup_buttons.sh

3)start het uitvoeren vh script met commando : ./setup_buttons.sh

Wat doet dit script precies?

    Het gebruikt tce-load -wi om de drie benodigde extensies direct uit de officiële piCorePlayer-repository te downloaden (dit simuleert de 'Extensions' pagina in de webinterface).

    Het schrijft het exacte sbpd-script.sh weg naar /home/tc/.

    Het past het configuratiebestand /usr/local/etc/pcp/pcp.cfg direct aan, wat hetzelfde effect heeft als het invullen van User command #1 op de tweaks.cgi webpagina.

    Het voert aan het einde pcp bu (piCorePlayer Backup) uit. Dit is essentieel bij piCorePlayer omdat het systeem in het RAM-geheugen draait; zonder deze backup-stap zouden de wijzigingen na een reboot weer verdwijnen.

