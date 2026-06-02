# piCorePlayer Hardware Buttons for Home Assistant LMS Add-on

This guide installs hardware button support on a piCorePlayer system that uses the Home Assistant LMS Server add-on.

Related forum discussion:

https://forums.lyrion.org/forum/user-forums/general-discussion/1808065-sonos-out-picoreplayer-in?view=thread

---

## Installation via SSH

Log in to your piCorePlayer using SSH:

- Username: `tc`
- Password: your configured password

### Step 1 - Download the installation script

Open the following file and copy the **RAW** contents:

https://github.com/v12345vtm/picoreplayer_buttons/blob/main/picoresonos.sh

Paste the entire RAW contents into the SSH terminal and press **ENTER**.

This will create:

```bash
setup_buttons.sh
```

---

### Step 2 - Make the script executable

```bash
chmod +x setup_buttons.sh
```

---

### Step 3 - Run the installer

```bash
./setup_buttons.sh
```

---

# What does this script do?

The script performs the complete installation automatically from the command line.

### 1. Installs required piCorePlayer extensions

The script uses:

```bash
tce-load -wi
```

to download and install the required extensions directly from the official piCorePlayer repository.

This is equivalent to installing them manually through the **Extensions** page in the piCorePlayer web interface.

---

### 2. Creates the button control script

The installer writes the required:

```text
sbpd-script.sh
```

file to:

```text
/home/tc/
```

---

### 3. Configures automatic startup

The script modifies:

```text
/usr/local/etc/pcp/pcp.cfg
```

so the button service starts automatically.

This has the same effect as configuring **User command #1** on the piCorePlayer **Tweaks** page (`tweaks.cgi`).

---

### 4. Saves everything permanently

At the end, the installer executes:

```bash
pcp bu
```

This step is essential.

piCorePlayer runs primarily from RAM, which means configuration changes are not automatically retained after a reboot.

Running:

```bash
pcp bu
```

creates a piCorePlayer backup so all installed files and configuration changes survive future reboots.

---

# Summary

After running the installer:

- Required extensions are installed.
- `sbpd-script.sh` is created automatically.
- Startup configuration is updated.
- Changes are backed up permanently using `pcp bu`.

No manual configuration through the piCorePlayer web interface is required.
