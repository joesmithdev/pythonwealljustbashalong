# =========================================================================================
#   Last update: 03_27_2021_2036
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

# =========================================================================================
# Script config
# =========================================================================================
#start_time = time.time()
os.system('cls||clear')
sysENV = str(platform.system())

targetUser = ""
targetEnvironment = ""
targetDomain = ""
bash_gui = ""

script_dir = str(os.path.dirname(os.path.realpath(__file__)))
bash_run = "bash " + script_dir + "/" + "scripts" + "/"

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
        os.system('cls||clear')
        f = Figlet(font='slant')
        print(f.renderText('Linux Admin'))
        print("")
        print(colored('---------- Settings ----------', 'blue'))
        env = "Environment: " + targetEnvironment
        user = "User: " + targetUser
        domain = "Domain: " + targetDomain
        gui = "Bash Whiptail: " + bash_gui
        sysType = "System: " + sysENV
        print(colored(env, 'green'))
        print(colored(user, 'green'))
        print(colored(domain, 'green'))
        print(colored(gui, 'green'))
        print(colored(sysType, 'green'))
        print(colored('------------------------------', 'blue'))
    # =========================================================================================

    def runScript(scriptName, scriptArgs):
        if targetEnvironment == "PRX - Proxmox server VM":
            wrk_env = "PRX"
        elif targetEnvironment == "LAB - Workstation or a Proxmox Desktop VM":
            wrk_env = "LAB"
        elif targetEnvironment == "VPS - Cloud VPS provider (Linode,Google)":
            wrk_env = "VPS"
        elif targetEnvironment == "AWS - Amazon Web Services (user: ubuntu)":
            wrk_env = "AWS"
        elif targetEnvironment == "VBOX - VirtualBox VM":
            wrk_env = "VBOX"
        elif targetEnvironment == "DKR - Docker container":
            wrk_env = "DKR"
        else:
            wrk_env = ""
        # scriptArgs = ("-a -b -c -d")
        command = bash_run + scriptName + " " + bash_gui + \
            " " + wrk_env + " " + targetUser + " " + targetDomain + " " + scriptArgs
        os.system(command)
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
        menuOption6 = "[f] <-- Main menu"
        menuQuit = "[q] <<-- quit"

        options = [
            menuOption1, menuOption2, menuOption3, menuOption4, menuOption5, menuOption6, menuQuit]
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
        global targetUser
        global targetEnvironment
        global targetDomain
        global bash_gui

        questions = [
            {
                'type': 'list',
                'message': 'Environment',
                'name': 'environment',
                'choices': [
                    Separator('= Working Environment ='),
                    {
                        'name': 'PRX - Proxmox server VM'
                    },
                    {
                        'name': 'LAB - Workstation or a Proxmox Desktop VM'
                    },
                    {
                        'name': 'VPS - Cloud VPS provider (Linode,Google)'
                    },
                    {
                        'name': 'VBOX - VirtualBox VM'
                    },
                    {
                        'name': 'DKR - Docker container'
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
                        'name': 'goblinslayer',
                        'checked': True
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
        targetUser = answers["user"]
        targetEnvironment = answers["environment"]
        targetDomain = answers["domain"]
        bash_gui = answers["display"]

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
