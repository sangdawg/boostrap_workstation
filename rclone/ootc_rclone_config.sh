#!/bin/bash

# sets up rclone to sync from remote bidirectionally

# --- CONFIGURATION ---
REMOTE_NAME="onedrive_remote"
LOCAL_DIR="$HOME/onedrive_hotty"
CONFIG_DIR="$HOME/.config/rclone"
SYSTEMD_DIR="$HOME/.config/systemd/user"

echo "Starting Hassle-Free Rclone Bisync Setup..."

# 1. Create necessary directories
mkdir -p "$LOCAL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$SYSTEMD_DIR"

# 2. Create the Filter File
echo "📝 Creating filter file..."
cat <<EOF > "$CONFIG_DIR/filters.txt"
Personal Vault/**
Apps/**
.cache/**
*.tmp
.DS_Store
EOF

# 3. Create the Systemd Service
echo "⚙️ Creating systemd service..."
cat <<EOF > "$SYSTEMD_DIR/rclone-sync.service"
[Unit]
Description=RClone OneDrive Bisync (Offline Ready)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone bisync ${REMOTE_NAME}: %h/$(basename "$LOCAL_DIR") \\
  --filter-from %h/.config/rclone/filters.txt \\
  --conflict-resolve newer \\
  --verbose

[Install]
WantedBy=default.target
EOF

# 4. Create the Systemd Timer
echo "⏰ Creating systemd timer..."
cat <<EOF > "$SYSTEMD_DIR/rclone-sync.timer"
[Unit]
Description=Run Rclone Bisync every 5 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# 5. Reload and Enable
echo "🔄 Reloading systemd and enabling persistence..."
systemctl --user daemon-reload
systemctl --user enable rclone-sync.timer
loginctl enable-linger $USER

# 6. Initial Sync (The "Truth" Run)
echo "⚠️  Performing initial resync (Cloud -> Local)..."
echo "This might take a while depending on your library size."
rclone bisync ${REMOTE_NAME}: "$LOCAL_DIR" --resync --filter-from "$CONFIG_DIR/filters.txt" --verbose

# 7. Start the timer
systemctl --user start rclone-sync.timer

echo "✅ Setup Complete!"
echo "Your files are at: $LOCAL_DIR"
echo "Sync interval: 5 minutes"
echo "Check logs with: journalctl --user -u rclone-sync.service -f"
