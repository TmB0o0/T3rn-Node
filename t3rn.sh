#!/bin/bash

# Clear the screen
clear

# Colors
WHITE='\033[1;37m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Logo and links
lines=(
  "\e[1;36m+-----------------------------------------------------------------------------------------------------------+\e[0m"
  "\e[1;36m|\e[0m  \e[1;33m##  ###  #######  ######   #######  #######  #######  ######   #######  ##  ##   #######  ######         \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  \e[1;33m### ###  ##   ##  ##  ##   ##       ##         ###    ##  ##     ###    ##  ##   ##       ##  ##         \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  \e[1;33m#######  ##   ##  ##  ##   ##       #######    ###    ##  ##     ###    ## ##    ##       ##  ##         \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  \e[1;33m## ####  ##  ###  ### ###  #######       ##    ###    #######    ###    #######  #######  #######        \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  \e[1;33m##  ###  ##  ###  ### ###  ###      ###  ##    ###    ### ###    ###    ##  ###  ###      ### ###        \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  \e[1;33m##  ###  ##  ###  ### ###  # #      ###  ##    ###    ### ###    ###    ##  ###  # #      ### ###        \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  \e[1;33m##  ###  #######  #######  #######  #######    ###    ### ###  #######  ##  ###  #######  ### ###        \e[1;36m|\e[0m"
  "\e[1;36m+-----------------------------------------------------------------------------------------------------------+\e[0m"
  "\e[1;36m|\e[0m                                                                                                           \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  🔗 \e[1;32mFollow us on Twitter:\e[0m \e[4;34mhttps://x.com/TmBO0o\e[0m 🐦                                                    \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  💻 \e[1;32mGitHub Repository:\e[0m \e[4;34mhttps://github.com/TmB0o0\e[0m 📁                                                  \e[1;36m|\e[0m"
  "\e[1;36m|\e[0m  📖 \e[1;32mGitBook Guide:\e[0m \e[4;34mhttps://tmb.gitbook.io/nodeguidebook/\e[0m 📚                                          \e[1;36m|\e[0m"
  "\e[1;36m+-----------------------------------------------------------------------------------------------------------+\e[0m"
)

for line in "${lines[@]}"; do
  echo -e "$line"
  sleep 0.05
done

# Main menu
while true; do
    echo -e "\n${WHITE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${WHITE}║            PIPE MANAGEMENT MENU            ║${RESET}"
    echo -e "${WHITE}╚════════════════════════════════════════════╝${RESET}"

    if [ -f ~/pipe/pop ]; then
        pop_version=$(~/pipe/pop --version 2>/dev/null)
        echo -e "${GREEN}Current pop version:${RESET} $pop_version"
    else
        echo -e "${RED}pop not installed.${RESET}"
    fi

    echo -e "\n${CYAN}1.${RESET} 🛠️  Install Node"
    echo -e "${CYAN}2.${RESET} 🔗 Check Status"
    echo -e "${CYAN}3.${RESET} ⏫ Update Node"
    echo -e "${CYAN}4.${RESET} 🧹 Remove Node"
    echo -e "${CYAN}5.${RESET} 📜 View Logs (screen attach)"
    echo -e "${CYAN}6.${RESET} ❌ Exit"
    echo -ne "\n${YELLOW}Choose an option:${RESET} "
    read choice

    case $choice in
        1)
            echo -e "${YELLOW}--- Installing packages ---${RESET}"
            sudo apt update
            sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
            
            echo -e "${YELLOW}--- Checking for screen ---${RESET}"
            if ! dpkg -s screen >/dev/null 2>&1; then
                sudo apt install screen -y
            else
                echo -e "${GREEN}Screen already installed, skipping.${RESET}"
            fi

            echo -e "${YELLOW}--- Downloading pop ---${RESET}"
            mkdir -p ~/pipe
            cd ~/pipe
            if ! wget https://dl.pipecdn.app/v0.2.8/pop -O pop; then
                echo -e "${RED}Failed to download pop file. Exiting.${RESET}"
                exit 1
            fi

            echo -e "${YELLOW}--- Making pop executable ---${RESET}"
            chmod +x pop

            echo -e "${YELLOW}--- Creating cache directory ---${RESET}"
            mkdir -p ~/pipe/download_cache

            echo -e "${YELLOW}--- Enter your Solana public key ---${RESET}"
            read -p "Enter your SOLANA_PUBLIC_KEY: " solana_key

            echo -e "${YELLOW}--- Launching in screen (pipe) with logging ---${RESET}"
            screen -dmS pipe bash -c "cd ~/pipe && ./pop --ram 8 --max-disk 150 --cache-dir ~/pipe/download_cache --pubKey $solana_key | tee ~/pipe/pipe.log"

            echo -e "${GREEN}Installation and launch completed.${RESET}"
            ;;

        2)
            echo -e "${YELLOW}--- Checking status ---${RESET}"
            if [ -f ~/pipe/pop ]; then
                cd ~/pipe
                ./pop --status
            else
                echo -e "${RED}pop file not found. Please run installation first.${RESET}"
            fi
            ;;

        3)
            echo -e "${YELLOW}--- Updating node ---${RESET}"
            read -rp "🔗 Insert a link to the new version of the pop: " DOWNLOAD_URL
            if [ -z "$DOWNLOAD_URL" ]; then
              echo -e "${RED}❌ No link provided. Exiting...${RESET}"
              continue
            fi
            POP_BIN_DIR="/opt/pop"
            WORK_DIR="/var/lib/pop"
            POP_BIN="$POP_BIN_DIR/pop"

            echo "📦 Downloading pop from $DOWNLOAD_URL..."
            curl -L -o pop "$DOWNLOAD_URL" || { echo -e "${RED}❌ Error downloading${RESET}"; continue; }

            echo "🔧 Making pop executable..."
            chmod +x ./pop

            echo "📁 Moving pop to $POP_BIN_DIR..."
            sudo mkdir -p "$POP_BIN_DIR"
            sudo mv ./pop "$POP_BIN"

            echo "🔐 Setting capability for ports 80/443..."
            sudo setcap 'cap_net_bind_service=+ep' "$POP_BIN"

            echo "📂 Checking working directory: $WORK_DIR"
            sudo mkdir -p "$WORK_DIR"
            cd "$WORK_DIR" || { echo "❌ Unable to change directory"; continue; }

            echo "🔄 Running pop --refresh..."
            "$POP_BIN" --refresh

            echo -e "${GREEN}✅ Done! Update completed.${RESET}"
            ;;

        4)
            echo -e "${YELLOW}--- Removing node folders ---${RESET}"
            rm -rf ~/pipe
            echo -e "${GREEN}~/pipe folder removed.${RESET}"
            ;;

        5)
            echo -e "${YELLOW}--- Attaching to screen 'pipe' ---${RESET}"
            if screen -list | grep -q "pipe"; then
                echo -e "${GREEN}Press Ctrl+A, then D to detach and return here.${RESET}"
                sleep 2
                screen -r pipe
            else
                echo -e "${RED}Screen session 'pipe' not found. Make sure the node is running.${RESET}"
            fi
            ;;

        6)
            echo -e "${GREEN}Exiting script. Goodbye!${RESET}"
            break
            ;;

        *)
            echo -e "${RED}Invalid choice. Please select 1-6.${RESET}"
            ;;
    esac

    echo ""
    read -p "Press Enter to return to menu..."
    clear

    for line in "${lines[@]}"; do
      echo -e "$line"
    done
done
