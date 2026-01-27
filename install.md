# piCorePlayer Button Control Manual

This manual explains how to connect physical pushbuttons to a Raspberry Pi running **piCorePlayer (pCP)** and map them to playback and volume controls using GPIO.

---

## What You Need

## GPIO Wiring (ASCII Diagram)

Below is an ASCII diagram showing how the pushbuttons are wired. All buttons are **Normally Open (NO)** and share a common **GND** connection.

```
Raspberry Pi GPIO Header (partial)

   3V3  (1) (2) 5V
 GPIO2  (3) (4) 5V
 GPIO3  (5) (6) GND  <------------------+
 GPIO4  (7) (8) GPIO14                 |
   GND  (9) (10) GPIO15                |
GPIO17 (11) (12) GPIO18                |
GPIO27 (13) (14) GND  <----------------+---- Common GND
GPIO22 (15) (16) GPIO23 ----[ VOL- ]---+
   3V3 (17) (18) GPIO24 ----[ PLAY ]---+
GPIO10 (19) (20) GND  <----------------+
 GPIO9 (21) (22) GPIO25
GPIO11 (23) (24) GPIO8
   GND (25) (26) GPIO7
 GPIO0 (27) (28) GPIO1
 GPIO5 (29) (30) GND
 GPIO6 (31) (32) GPIO12 ----[ VOL+ ]---+
GPIO13 (33) (34) GND  <----------------+
GPIO19 (35) (36) GPIO16
GPIO26 (37) (38) GPIO20
   GND (39) (40) GPIO21
```

**Important notes:**
- One side of each button goes to its GPIO pin
- The other side of **all buttons** goes to **GND**
- Internal pull-up resistors are enabled by `sbpd`
- Logic behavior:
  - Button released → GPIO = HIGH
  - Button pressed → GPIO = LOW

---

## What You Need

### Hardware

- A Raspberry Pi running **piCorePlayer** (example IP: `http://192.168.1.182`)
- **Normally Open (NO)** pushbuttons
- Jumper wires

### Button Wiring

All buttons share **GND** as the common pin.

| GPIO Pin | Function |
|--------|----------|
| GPIO24 | Play / Pause |
| GPIO6  | Volume + |
| GPIO23 | Volume - |

> Later, we will enable the Raspberry Pi **internal pull-up resistors**, so:
> - GPIO = **HIGH** when not pressed
> - GPIO = **LOW** when button is pressed (connected to GND)

### Software

- piCorePlayer
- A **dedicated Logitech Media Server (LMS)** (example: Home Assistant add-on)
- SSH client (example: **PuTTY**)

---

## Initial piCorePlayer Setup

1. Open the piCorePlayer web interface:
   
   `http://<IP-ADDRESS>`

2. Configure:

   - **Set tc password**: `picore`
   - **Hostname**: `PicoreSonos`
   - **Optional SSH Key**: Yes
   - **NTP**: Set and enable
   - **Act as LMS server**: No
   - **Resize filesystem**: No

3. Click **Finish**

---

## Step 1 – Install Required Extensions

Source documentation:
https://docs.picoreplayer.org/projects/control-jivelite-by-rotary-encoders-and-buttons/

1. Open:

   `http://<IP-ADDRESS>/cgi-bin/extensions.cgi`

2. On the **Main Page**, scroll to **Additional Functions** → click **Extensions**
3. Wait until all green checkmarks appear
4. Resize filesystem to **500 MB** if requested

### Install Extensions

Open the **Available** tab and load:

- `nano.tcz`  
  *(Text editor for SSH environment)*
- `pcp-sbpd.tcz`
- `pigpio.tcz`

---

## Step 2 – Create the sbpd Script

### SSH Login

Use PuTTY (or similar):

- **User**: `tc`
- **Password**: `picore`
- **Host**: `tc@<IP-ADDRESS>`

Example:
```
tc@192.168.1.182
```

---

### Create Script File

```
sudo nano /home/tc/sbpd-script.sh
```

### Script Content

```sh
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
```

Save and exit:

- `CTRL + X`
- `Y`
- `ENTER`

---

### Make Script Executable

```
sudo chmod +x /home/tc/sbpd-script.sh
```

---

### Test the Script

Run:

```
sudo /home/tc/sbpd-script.sh
```

Expected output:

```
pigpiod is running
sbpd -v b,24,PLAY,2,0,PLAY,250 b,6,VOL+,2,0,VOL+,250 b,23,VOL-,2,0,VOL-,250
```

Press the buttons — playback and volume should respond immediately.

Stop with:
```
CTRL + C
```

---

## Understanding the sbpd Command (Detailed Explanation)

The heart of this setup is the following command:

```
sbpd -v \
b,24,PLAY,2,0,PLAY,250 \
b,6,VOL+,2,0,VOL+,250 \
b,23,VOL-,2,0,VOL-,250
```

Let’s break it down **piece by piece**.

---

### 1️⃣ `sbpd`

`sbpd` = **Squeezebox Button & Dial Processor Daemon**

It listens to GPIO inputs and converts them into:
- Keyboard events
- Media control commands

These commands are then sent to **Logitech Media Server (LMS)**.

---

### 2️⃣ `-v` (Verbose Mode)

```
-v
```

- Enables verbose output
- Useful for debugging
- Shows button activity and command execution in the terminal

---

### 3️⃣ Button Definition Syntax

Each button follows this structure:

```
b,<GPIO>,<NAME>,<PULL>,<EDGE>,<ACTION>,<DEBOUNCE>
```

---

### 4️⃣ Example Breakdown (PLAY Button)

```
b,24,PLAY,2,0,PLAY,250
```

| Field | Value | Meaning |
|------|------|--------|
| `b` | button | Defines a button input |
| `24` | GPIO24 | GPIO pin number |
| `PLAY` | Name | Logical name (label only) |
| `2` | Pull-up | Enable internal pull-up resistor |
| `0` | Falling edge | Trigger when GPIO goes HIGH → LOW |
| `PLAY` | Action | Send PLAY / PAUSE command |
| `250` | ms | Debounce time |

**What happens electrically:**
- Button released → GPIO24 = HIGH
- Button pressed → GPIO24 = LOW
- Falling edge detected → PLAY/PAUSE sent

---

### 5️⃣ Volume Buttons Explained

#### Volume Up
```
b,6,VOL+,2,0,VOL+,250
```

- GPIO6
- Pull-up enabled
- Trigger on press
- Increases volume

#### Volume Down
```
b,23,VOL-,2,0,VOL-,250
```

- GPIO23
- Pull-up enabled
- Trigger on press
- Decreases volume

---

### 6️⃣ Pull-Up & Edge Settings (Why These Values?)

| Value | Meaning |
|-----|--------|
| `2` | Internal pull-up enabled |
| `0` | Falling edge detection |

This combination is perfect for:
- Normally Open buttons
- Simple wiring to GND
- Noise-resistant input

---

### 7️⃣ Debounce (`250 ms`)

Mechanical buttons bounce when pressed.

```
250
```

- Prevents multiple triggers
- 200–300 ms is ideal for human interaction

---

### 8️⃣ Full Command Behavior

When the script runs:

1. `pigpiod` starts GPIO monitoring
2. `sbpd` registers all buttons
3. Each button press generates **one clean media command**
4. Commands are sent to LMS instantly

---

## Step 3 – Add Script as User Command

1. Open:

   `http://<IP-ADDRESS>/cgi-bin/tweaks.cgi`

2. Scroll to **User Commands**
3. In **User command #1**, enter:

```
/home/tc/sbpd-script.sh
```

4. Click **Save**

---

## Final Checks

### Verify LMS Connection

```
sbpd -v
```

This confirms the Logitech Media Server is reachable.

---

## Reboot

```
sudo reboot
```

After reboot, the buttons will automatically work.

---

## Done 🎉

Your piCorePlayer is now controlled using physical GPIO buttons.

