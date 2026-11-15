# EVILSAAD HVM Panel Installer

A menu-based installer for the HVM Panel.

## Requirements

- A Debian/Ubuntu-based VPS or server with `apt`
- Root access (or a user with `sudo` privileges; the script itself runs system commands directly)
- Internet access
- GitHub access to `https://github.com/evilsaad0-hash/hvm.git`
- The HVM Panel archive (`Hvm-v5.zip` or `Hvm-v5`)

## Installation

### 1. Download the installer

Place `install.sh` on your VPS. If you have uploaded it already, move to the next step.

### 2. Install Zip, python

apt update && apt upgrade -y
apt install python3 python3-pip python3-venv unzip -y

### 3. Cloneing 

`` git clone https://github.com/evilsaad0-hash/hvm.git

cd hvm ``

### 3. Run the installer

```bash
bash hvm-installer.sh
```

### 4. Select an option

The installer displays this menu:

```text
1) HVM PANEL INSTALL
2) Exit
```

- Enter `1` to start installation.
- Enter `2` to exit.
- Any other input displays the menu again.

## What option 1 does

The installer performs these steps:

1. Updates the APT package lists and upgrades installed packages.
2. Installs Python 3, pip, venv, unzip, Git, Snap, and LXD-related utilities.
3. Clones `https://github.com/evilsaad0-hash/hvm.git` into a directory named `hvm` (or uses an existing Git checkout).
4. Installs LXD and adds the current user to the `lxd` group.
5. Runs `lxd init --auto`.
6. Looks for `Hvm-v5.zip` or `Hvm-v5` in the cloned repository directory and extracts it.
7. Enters the extracted `HVM` directory (or `hvm` directory).
8. Creates and activates a Python virtual environment.
9. Upgrades pip and installs packages from `requirements.txt`.
10. Checks for `hvm.py` and starts it with `python hvm.py`.

## Important: Hvm-v5 archive location

Before installation, make sure the panel archive is available in the root of the cloned repository at:

```text
hvm/Hvm-v5.zip
```

Alternatively, the installer accepts a file named `Hvm-v5` in that same location.

The script clones the repository and then searches inside the cloned `hvm` directory. If the archive is not present there, installation stops with an archive-not-found message. If the archive is not already included in the GitHub repository, place it in that directory before running the extraction steps, or update the installer to obtain the archive.

The extracted archive must contain an `HVM` or `hvm` directory. That directory must contain:

- `requirements.txt`
- `hvm.py`

If these files or folders are named differently or are in another location, the current installer will stop rather than launch the panel.

## Run again

From the directory containing the script:

```bash
bash install.sh
```

If the `hvm` folder already exists and is a Git repository, the installer reuses it. If a non-Git file or directory named `hvm` already exists, rename or remove it before retrying.

## Troubleshooting

### `Hvm-v5 archive not found`

Make sure `Hvm-v5.zip` (or `Hvm-v5`) exists in the cloned repository root:

```bash
ls -la hvm/
```

### `HVM directory was not found`

Check the extracted folder names:

```bash
find hvm -maxdepth 3 -type d
```

### `requirements.txt not found` or `hvm.py not found`

Check the contents of the extracted panel directory:

```bash
find hvm -maxdepth 4 -type f
```

The current installer expects both files inside the extracted `HVM` or `hvm` directory.

### LXD commands fail

The installer requires a system that supports Snap and LXD. Check the error printed by `snap install lxd` or `lxd init --auto`; the current script does not automatically recover from every LXD setup failure.

## Notes

- The installer runs system-level package and virtualization setup. Review the script before running it on a production server.
- `lxd init --auto` applies automatic LXD initialization.
- The script starts the panel in the foreground with `python hvm.py`. Keep the terminal/session open unless you configure a separate service manager.
