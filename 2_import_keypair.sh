
#!/bin/bash

# 1. Setup directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. Define filenames (change these if using rsa)
PRIVATE_KEY="$HOME/.ssh/id_ed25519"
PUBLIC_KEY="$HOME/.ssh/id_ed25519.pub"

# 3. Create empty files
touch "$PRIVATE_KEY" "$PUBLIC_KEY"

# 4. Set strict permissions immediately
chmod 600 "$PRIVATE_KEY"
chmod 644 "$PUBLIC_KEY"

# 5. Fix SELinux contexts (Essential for Fedora)
restorecon -Rv ~/.ssh

echo "Stubs created with correct permissions."
echo "------------------------------------------------"
read -p "Press Enter to open the PRIVATE key file. Paste your data, Save (Ctrl+O), and Exit (Ctrl+X)."
nano "$PRIVATE_KEY"

echo "------------------------------------------------"
read -p "Press Enter to open the PUBLIC key file. Paste your data, Save (Ctrl+O), and Exit (Ctrl+X)."
nano "$PUBLIC_KEY"

echo "------------------------------------------------"
echo "Done! You can verify with: ssh-keygen -l -f $PRIVATE_KEY"


