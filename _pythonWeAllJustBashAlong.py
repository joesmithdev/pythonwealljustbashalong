# =========================================================================================
#   Last update:    01_05_2021_0607
#   Description -   Python terminal menu interface for running bash scripts.
# =========================================================================================
from __future__ import print_function, unicode_literals
import time
import platform
import sys
import getopt
import os
from simple_term_menu import TerminalMenu
from pyfiglet import Figlet
from PyInquirer import style_from_dict, Token, prompt, Separator
from pprint import pprint
from termcolor import colored
from dotenv import load_dotenv
import subprocess
from os import path

# =========================================================================================
# Script config
# =========================================================================================
#start_time = time.time()
os.system('cls||clear')
sysENV = str(platform.system())

load_dotenv()
active_env = os.getenv('ACTIVE_ENV')
active_user = os.getenv('ACTIVE_USER')
active_domain = os.getenv('ACTIVE_DOMAIN')
bash_whiptail = os.getenv('BASH_WHIPTAIL')
eth_wallet = os.getenv('ETH_WALLET')
script_folder_name = "scripts"
script_dir = str(os.path.dirname(os.path.realpath(__file__)))
bash_run = "bash " + script_dir + "/" + script_folder_name + "/"

style = style_from_dict({
    Token.Separator: '#cc5454',
    Token.QuestionMark: '#e3e01e bold',
    Token.Selected: '#cc5454',
    Token.Pointer: '#e3e01e bold',
    Token.Instruction: '',
    Token.Answer: '#1442b5 bold',
    Token.Question: '',
})
# =========================================================================================

# =========================================================================================
# Script names
script_validator = "validator.sh"
script_debug = "debug.sh"
script_crypto = "crypto.sh"
script_oscp = "oscp.sh"

script_sys_server_base = "sys_server_base.sh"
script_sys_config_docker = "sys_config_docker.sh"
script_service_wireguard = "service_wireguard.sh"
# =========================================================================================


def main(argv):
    # =========================================================================================
    def infoBanner():
        global active_env
        global active_user
        global active_domain
        global bash_whiptail
        global eth_wallet

        loadEnvFile()
        os.system('cls||clear')
        f = Figlet(font='slant')
        
        print(f.renderText('Linux Admin'))
        print("")
        print(colored('---------- Settings ----------', 'blue'))
        
        #REVIEW: os.getenv() does not seem to read from the file when called again.
        #active_env = "Environment: " + active_env
        #active_user = "User: " + active_user
        #domactive_domainain = "Domain: " + active_domain
        #bash_whiptail = "Bash Whiptail: " + bash_whiptail
        #eth_wallet = os.getenv('ETH_WALLET') <<<<< REVIEW
        
        sysType = "System=" + sysENV
        print(colored(sysType, 'yellow'))
        print(colored(active_env, 'green'))
        print(colored(active_user, 'green'))
        print(colored(active_domain, 'green'))
        print(colored(bash_whiptail, 'green'))
        print(colored(eth_wallet, 'green'))
        print(colored('------------------------------', 'blue'))
    # =========================================================================================
    def loadEnvFile():
        global active_env
        global active_user
        global active_domain
        global bash_whiptail
        global eth_wallet
        
        try:
            with open ('.env', 'r') as envFile:
                for line in envFile:
                    if "ETH_WALLET" in line:
                        eth_wallet = line.strip()
                    elif "ACTIVE_ENV" in line:
                        active_env = line.strip()
                    elif "ACTIVE_USER" in line:
                        active_user = line.strip()
                    elif "ACTIVE_DOMAIN" in line:
                        active_domain = line.strip()
                    elif "BASH_WHIPTAIL" in line:
                        bash_whiptail = line.strip()
        except:
            runScript(script_validator, "")
            loadEnvFile()
            
    def runScript(scriptName, scriptArgs):
        command = bash_run + scriptName + " " + scriptArgs
        script_location = script_dir + "/" + script_folder_name + "/" + scriptName
        
        script_check = str(path.exists(script_location))
        if "True" in script_check:
            os.system(command)
        else:
            msg = "== STATUS: " + scriptName + " Script not found =="
            print(colored(msg, 'red'))
            quit() 
        
    # =========================================================================================

    def menu_MAIN():
        menuTitle = "=== Main Menu ==="
        menuOption1 = "[1] Wireguard management"
        menuOption2 = "[2] ETH-Ethereum"
        menuOption3 = "[3] Server Options"
        menuOption4 = "[4] Docker Testing"
        menuOption5 = "[5] OSCP Options"
        menuOption6 = "[6] Debug Zone"
        menuOption7 = "[7] Settings"
        menuQuit = "[q] <<-- quit"

        options = [
            menuOption1, menuOption2, menuOption3, menuOption4, menuOption5, menuOption6, menuOption7, menuQuit]
        terminalMainMenu = TerminalMenu(options, title=menuTitle)
        infoBanner()
        menu_Display = terminalMainMenu.show()
        try:
            input_optionSelected = options[menu_Display]
        except:
            input_optionSelected = ""

        if input_optionSelected == menuOption1:
            menu_wireguard()
        elif input_optionSelected == menuOption2:
            menu_ethereum()
        elif input_optionSelected == menuOption3:
            menu_server()
        elif input_optionSelected == menuOption4:
            menu_docker()
        elif input_optionSelected == menuOption5:
            menu_oscp()
        elif input_optionSelected == menuOption6:
            debugArgs = ("-a -b -c -d -e")
            runScript(script_debug, debugArgs)
        elif input_optionSelected == menuOption7:
            script_setting()
        elif input_optionSelected == menuQuit:
            os.system('cls||clear')
            print("*** Arrivederci! ***")
            quit()
        else:
            print("*WARNING* Shortcut not procesed. Please use the arrow keys.")
            time.sleep(3)
    # =========================================================================================

    def menu_wireguard():
        menuTitle = "=== Wireguard Menu ==="
        menuOption1 = "[1] Server: Install WG Server"
        menuOption2 = "[2] Server: Add user"
        menuOption3 = "[3] Server: Remove user"
        menuOption4 = "[4] Client: Install WG Client"
        menuOption5 = "[5] Client: Start WG"
        menuOption6 = "[6] Client: Stop WG"
        menuOption7 = "[7] Client: Add remote server"
        menuOption8 = "[8] Client: Remove remote server"
        menuOption9 = "[9] <-- Main menu"
        menuQuit = "[q] <<-- quit"

        options = [
            menuOption1, menuOption2, menuOption3, menuOption4, menuOption5, menuOption6, menuOption7, menuOption8, menuOption9, menuQuit]
        terminalMainMenu = TerminalMenu(options, title=menuTitle)
        infoBanner()
        menu_Display = terminalMainMenu.show()

        try:
            input_optionSelected = options[menu_Display]
        except:
            input_optionSelected = ""

        if input_optionSelected == menuOption1:
            runScript(script_service_wireguard, "1")
        elif input_optionSelected == menuOption2:
            runScript(script_service_wireguard, "2")
        elif input_optionSelected == menuOption3:
            runScript(script_service_wireguard, "3")
        elif input_optionSelected == menuOption4:
            runScript(script_service_wireguard, "4")
        elif input_optionSelected == menuOption5:
            runScript(script_service_wireguard, "5")
        elif input_optionSelected == menuOption6:
            runScript(script_service_wireguard, "6")
        elif input_optionSelected == menuOption7:
            runScript(script_service_wireguard, "7")
        elif input_optionSelected == menuOption8:
            runScript(script_service_wireguard, "8")
        elif input_optionSelected == menuOption9:
            return
        elif input_optionSelected == menuQuit:
            os.system('cls||clear')
            print("*** Arrivederci! ***")
            quit()
        else:
            print("*WARNING* Shortcut not procesed. Please use the arrow keys.")
            time.sleep(3)
    # =========================================================================================

    def menu_ethereum():
        menuTitle = "=== Ethereum Menu ==="
        menuOption1 = "[a] Install Required pkgs (Nvidia GPU)"
        menuOption2 = "[b] Install ETH Wallet (v10)"
        menuOption3 = "[c] Start mining now"
        menuOption4 = "[d] Delayed mining"
        menuOption5 = "[e] Open ETH-Wallet"
        menuOption6 = "[f] Set wallet address"
        menuOption7 = "[g] <-- Main menu"
        menuQuit = "[q] <<-- quit"

        options = [
            menuOption1, menuOption2, menuOption3, menuOption4, menuOption5, menuOption6, menuOption7, menuQuit]
        terminalMainMenu = TerminalMenu(options, title=menuTitle)
        os.system('cls||clear')
        menu_Display = terminalMainMenu.show()
        try:
            input_optionSelected = options[menu_Display]
        except:
            input_optionSelected = ""

        if input_optionSelected == menuOption1:
            runScript(script_crypto, "-i")  # Install Required
        elif input_optionSelected == menuOption2:
            runScript(script_crypto, "-w")  # Install Wallet
        elif input_optionSelected == menuOption3:
            runScript(script_crypto, "-m")  # Start mining now
        elif input_optionSelected == menuOption4:
            runScript(script_crypto, "-d")  # Delayed mining
        elif input_optionSelected == menuOption5:
            runScript(script_crypto, "-o")  # Open Eth-Wallet
        elif input_optionSelected == menuOption6:
            runScript(script_crypto, "-a")  # Set wallet address
        elif input_optionSelected == menuOption7:
            return
        elif input_optionSelected == menuQuit:
            print("*** Arrivederci! ***")
            quit()
        else:
            print("*WARNING* Shortcut not procesed. Please use the arrow keys.")
            time.sleep(3)
    # =========================================================================================

    def menu_server():
        menuTitle = "=== Server Options Menu ==="
        menuOption1 = "[1] Basic server config."
        menuOption2 = "[2] <EMPTY>"
        menuOption3 = "[3] <EMPTY>"
        menuOption4 = "[4] <-- Main menu"
        menuQuit = "[q] <<-- quit"

        options = [
            menuOption1, menuOption2, menuOption3, menuOption4, menuQuit]
        terminalMainMenu = TerminalMenu(options, title=menuTitle)
        os.system('cls||clear')
        menu_Display = terminalMainMenu.show()

        try:
            input_optionSelected = options[menu_Display]
        except:
            input_optionSelected = ""

        if input_optionSelected == menuOption1:
            runScript(script_sys_server_base, "")
        elif input_optionSelected == menuOption2:
            debugArgs = ("-a -b -c -d -e")
            runScript(script_debug, debugArgs)
        elif input_optionSelected == menuOption3:
            debugArgs = ("-a -b -c -d -e")
            runScript(script_debug, debugArgs)
        elif input_optionSelected == menuOption4:
            return
        elif input_optionSelected == menuQuit:
            print("*** Arrivederci! ***")
            quit()
        else:
            print("*WARNING* Shortcut not procesed. Please use the arrow keys.")
            time.sleep(3)
    # =========================================================================================

    def menu_docker():
        menuTitle = "=== Docker Menu ==="
        menuOption1 = "[1] INSTALL Docker"
        menuOption2 = "[2] START sample containers"
        menuOption3 = "[3] STOP sample containers"
        menuOption4 = "[4] REMOVE sample containers & volumes"
        menuOption5 = "[5] <-- Main menu"
        menuQuit = "[q] <<-- quit"

        options = [
            menuOption1, menuOption2, menuOption3, menuOption4, menuOption5, menuQuit]
        terminalMainMenu = TerminalMenu(options, title=menuTitle)
        os.system('cls||clear')
        menu_Display = terminalMainMenu.show()

        try:
            input_optionSelected = options[menu_Display]
        except:
            input_optionSelected = ""

        if input_optionSelected == menuOption1:
            runScript(script_sys_config_docker, "-i")
        elif input_optionSelected == menuOption2:
            runScript(script_sys_config_docker, "-u")
        elif input_optionSelected == menuOption3:
            runScript(script_sys_config_docker, "-d")
        elif input_optionSelected == menuOption4:
            runScript(script_sys_config_docker, "-r")
        elif input_optionSelected == menuOption5:
            return
        elif input_optionSelected == menuQuit:
            print("*** Arrivederci! ***")
            quit()
        else:
            print("*WARNING* Shortcut not procesed. Please use the arrow keys.")
            time.sleep(3)

    # =========================================================================================
    def menu_oscp():
        menuTitle = "=== Hmmmmmmmm!!!! ==="  # Yup, One Piece.
        menuOption1 = "[1] Oden Nitoryu: Tougen Shirataki"
        menuOption2 = "[2] Nitoryu: Nigiri Toro Samon"
        menuOption3 = "[3] Install tools"
        menuOption4 = "[4] <-- Main menu"
        menuQuit = "[q] <<-- quit"

        options = [
            menuOption1, menuOption2, menuOption3, menuOption4, menuQuit]
        terminalMainMenu = TerminalMenu(options, title=menuTitle)
        os.system('cls||clear')
        menu_Display = terminalMainMenu.show()

        try:
            input_optionSelected = options[menu_Display]
        except:
            input_optionSelected = ""

        if input_optionSelected == menuOption1:
            runScript(script_oscp, "1")
        elif input_optionSelected == menuOption2:
            runScript(script_oscp, "2")
        elif input_optionSelected == menuOption3:
            runScript(script_oscp, "3")
        elif input_optionSelected == menuOption4:
            return
        elif input_optionSelected == menuQuit:
            print("*** Arrivederci! ***")
            quit()
        else:
            print("*WARNING* Shortcut not procesed. Please use the arrow keys.")
            time.sleep(3)
    # =========================================================================================

    def script_setting():
        questions = [
            {
                'type': 'list',
                'message': 'Environment',
                'name': 'environment',
                'choices': [
                    Separator('= Working Environment ='),
                    {
                        'name': 'NONE'
                    },
                    {
                        'name': 'PRX-Proxmox_server_VM'
                    },
                    {
                        'name': 'LAB-Workstation_or_Proxmox_Desktop_VM'
                    },
                    {
                        'name': 'VPS-Cloud_VPS_provider_(Linode,Google)'
                    },
                    {
                        'name': 'VBOX-VirtualBox_VM'
                    },
                    {
                        'name': 'DKR-Docker_container'
                    },
                ],
            },
            {
                'type': 'list',
                'message': 'User',
                'name': 'user',
                'choices': [
                    Separator('= Script/Target User ='),
                    {
                        'name': 'NONE'
                    },
                    {
                        'name': 'ubuntu',
                    },
                    {
                        'name': 'goblinslayer',
                    },
                    {
                        'name': 'goblin'
                    },
                ],
            },
            {
                'type': 'list',
                'message': 'Domain',
                'name': 'domain',
                'choices': [
                    Separator('= Working Domain ='),
                    {
                        'name': 'NONE'
                    },
                    {
                        'name': 'example.dev'
                    },
                    {
                        'name': 'scanme.nmap.org'
                    },
                    {
                        'name': 'demo.testfire.net'
                    },
                ],
            },
            {
                'type': 'list',
                'message': 'Bash Whiptail',
                'name': 'display',
                'choices': [
                    Separator('= Bash Whiptail ='),
                    {
                        'name': 'False'
                    },
                    {
                        'name': 'True'
                    },
                ],
            }, ]

        answers = prompt(questions, style=style)
        loadEnvFile()
        envFile = open(".env", "rt")
        tmpData = envFile.read()
        
        new_env_var = "ACTIVE_ENV=" + answers["environment"]
        new_user_var = "ACTIVE_USER=" + answers["user"]
        new_domain_var = "ACTIVE_DOMAIN=" + answers["domain"]
        new_bash_var = "BASH_WHIPTAIL=" + answers["display"]
        
        tmpData = tmpData.replace(active_env, new_env_var)
        tmpData = tmpData.replace(active_user, new_user_var)
        tmpData = tmpData.replace(active_domain, new_domain_var)
        tmpData = tmpData.replace(bash_whiptail, new_bash_var)
        envFile.close()
        
        envFile = open(".env", "wt")
        envFile.write(tmpData)
        envFile.close()
        
    # =========================================================================================

    # ===================
    # Infinite loop soup
    while True:
        menu_MAIN()
    # ===================

    #print("--- %s seconds ---" % (time.time() - start_time))
# =========================================================================================
if __name__ == "__main__":
    main(sys.argv[1:])
