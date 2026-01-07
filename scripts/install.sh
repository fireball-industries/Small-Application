#!/bin/bash
#
# Installation script for OPC UA Server (standalone)
# For use on Ubuntu/Debian systems
#

set -e

echo "========================================="
echo "  OPC UA Server Installation"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${YELLOW}Warning: Running as root.  Consider running as a regular user.${NC}"
fi

# Install directory
INSTALL_DIR="${INSTALL_DIR:-/opt/opcua-server}"

echo -e "${GREEN}Installing to:  $INSTALL_DIR${NC}"
echo ""

# Check for Python 3
echo "Checking for Python 3..."
if !  command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Python 3 not found. Installing...${NC}"
    sudo apt update
    sudo apt install -y python3 python3-pip
else
    echo -e "${GREEN}Python 3 found:  $(python3 --version)${NC}"
fi

# Check for pip
echo "Checking for pip..."
if ! command -v pip3 &> /dev/null; then
    echo -e "${YELLOW}pip not found.  Installing...${NC}"
    sudo apt install -y python3-pip
else
    echo -e "${GREEN}pip found: $(pip3 --version)${NC}"
fi

# Create installation directory
echo "Creating installation directory..."
sudo mkdir -p "$INSTALL_DIR"

# Copy files
echo "Copying application files..."
sudo cp opcua_server. py "$INSTALL_DIR/"
sudo cp tags_config.json "$INSTALL_DIR/"
sudo cp requirements.txt "$INSTALL_DIR/"

# Make executable
sudo chmod +x "$INSTALL_DIR/opcua_server.py"

# Install Python dependencies
echo "Installing Python dependencies..."
sudo pip3 install -r "$INSTALL_DIR/requirements.txt"

# Install systemd service
if [ -f "systemd/opcua-server.service" ]; then
    echo "Installing systemd service..."
    sudo cp systemd/opcua-server.service /etc/systemd/system/
    sudo sed -i "s|/opt/opcua-server|$INSTALL_DIR|g" /etc/systemd/system/opcua-server.service
    sudo systemctl daemon-reload
    sudo systemctl enable opcua-server. service
    echo -e "${GREEN}Systemd service installed and enabled${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Installation directory: $INSTALL_DIR"
echo ""
echo "To start the server:"
echo "  sudo systemctl start opcua-server"
echo ""
echo "To check status:"
echo "  sudo systemctl status opcua-server"
echo ""
echo "To view logs:"
echo "  sudo journalctl -u opcua-server -f"
echo ""
echo "To edit configuration:"
echo "  sudo nano $INSTALL_DIR/tags_config.json"
echo "  sudo systemctl restart opcua-server"
echo ""