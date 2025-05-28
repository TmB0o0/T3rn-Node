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

NODE_DIR="$HOME/t3rn"

function install_node() {
  echo -e "${CYAN}Updating and upgrading system...${RESET}"
  sudo apt update && sudo apt upgrade -y

  echo -e "${CYAN}Creating t3rn directory...${RESET}"
  mkdir -p "$NODE_DIR"
  cd "$NODE_DIR" || exit

  echo -e "${CYAN}Downloading latest t3rn executor release...${RESET}"
  LATEST_TAG=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
  wget "https://github.com/t3rn/executor-release/releases/download/${LATEST_TAG}/executor-linux-${LATEST_TAG}.tar.gz"

  echo -e "${CYAN}Extracting archive...${RESET}"
  tar -xzf executor-linux-*.tar.gz

  echo -e "${CYAN}Setting environment variables...${RESET}"
  cd executor/executor/bin || exit

  read -rsp "Enter your wallet PRIVATE KEY: " PRIVATE_KEY
  echo

  export ENVIRONMENT=testnet
  export LOG_LEVEL=debug
  export LOG_PRETTY=false
  export EXECUTOR_PROCESS_BIDS_ENABLED=true
  export EXECUTOR_PROCESS_ORDERS_ENABLED=true
  export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
  export EXECUTOR_PROCESS_ORDERS=true
  export EXECUTOR_PROCESS_CLAIMS=true
  export EXECUTOR_MAX_L3_GAS_PRICE=100
  export PRIVATE_KEY_LOCAL="$PRIVATE_KEY"
  export EXECUTOR_ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn'
  export EXECUTOR_ENABLED_ASSETS="eth,t3eth,t3mon,t3sei,mon,sei"
  export RPC_ENDPOINTS='{
    "l2rn": ["https://t3rn-b2n.blockpi.network/v1/rpc/public", "https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "blst": ["https://sepolia.blast.io", "https://blast-sepolia.drpc.org"],
    "mont": ["https://testnet-rpc.monad.xyz"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"]
  }'

  echo -e "${CYAN}Installing screen...${RESET}"
  sudo apt-get install -y screen

  echo -e "${GREEN}Installation complete.${RESET}"
  echo "To start the node, use the menu option 'Start Node'."
}

function start_node() {
  cd "$NODE_DIR/executor/executor/bin" || { echo -e "${RED}Node directory not found. Please install first.${RESET}"; return; }
  screen -dmS t3rn ./executor
  echo -e "${GREEN}Node started inside screen session named 't3rn'.${RESET}"
}

function view_logs() {
  screen -r t3rn || echo -e "${YELLOW}No screen session named 't3rn' found.${RESET}"
}

function remove_node() {
  echo -e "${YELLOW}Stopping node if running...${RESET}"
  screen -S t3rn -X quit 2>/dev/null
  echo -e "${YELLOW}Removing t3rn directory...${RESET}"
  rm -rf "$NODE_DIR"
  echo -e "${GREEN}Node removed.${RESET}"
}

while true; do
    echo -e "\n${WHITE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${WHITE}║            PIPE MANAGEMENT MENU            ║${RESET}"
    echo -e "${WHITE}╚════════════════════════════════════════════╝${RESET}"
    echo -e "1) Install Node"
    echo -e "2) Start Node"
    echo -e "3) View Logs"
    echo -e "4) Remove Node"
    echo -e "5) Exit"
    read -rp "Choose an option [1-5]: " choice
    case $choice in
        1) install_node ;;
        2) start_node ;;
        3) view_logs ;;
        4) remove_node ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option.${RESET}"; sleep 1 ;;
    esac
    echo -e "\nPress Enter to return to menu..."
    read -r
done

