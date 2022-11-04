#!/bin/bash

###################### Global Vars ######################
file_ext=( "mp3" "mp4" "mov" "jpg" "bmp" )
SCRIPT_DIR="/home/script"
editor="gedit"


###################### Work Horse Functions ######################
function select_editor()
{
    editor=vim
    echo "Please select an editor:"
    echo "1. Vim (default)"
    echo "2. Nano"
    echo "3. Gedit"
    read ed_option

    case $ed_option in 
        1) editor=vim;;
        2) editor=nano;;
        3) editor=gedit;;
        *) editor=vim; echo "ERR: Invalid Input! Default editor is VIM.";;
    esac

}

function user_cont()
{
	echo $1
    echo "Press any key to continue..."
    read
}

function YN_prompt()
{
    #First argument is message, Second argument is the function to run
    echo "Do $1? [Y/n]"
    read input
    if [ $input == "Y" ] || [ $input == "y" ];then
        $($2)
    else
        echo "Not doing $1."
        user_cont
    fi
}

function setup()
{
    if [ -f "$SCRIPT_DIR/setup_done" ];then
        user_cont "Setup has already been run! Returning to main menu."
        return
    else
        user_cont "This option should be run once. Installing tree and vim. 'Apt update' will be run in the process."
        apt update
        apt install tree -y
        apt install vim -y
		mkdir $SCRIPT_DIR 
		touch "$SCRIPT_DIR/setup_done"
        clear
        user_cont "Everything has completed successfully!"
    fi
}



function antivirus_scan()
{
    echo "installing clamAV..."
    apt install clamav -y || error_handler
    echo "Installed clamAV. Enter in absoulte path of directory to scan:"
    read dir_to_scan
    clamscan -r $dir_to_scan
}

function change_passwords()
{

    YN_prompt "Chagne user passwords? [y/n] " actually_change_passwords 
}

function actually_change_passwords()
{
	awk -F":" '{ if ($3>1000) print $1":0ld$cona1"}' /etc/passwd > "$SCRIPT_DIR/changing_pass.txt"
	user_cont 'Opening file for confirmation of password changes'
	gedit "$SCRIPT_DIR/changing_pass.txt"
	chpasswd < "$SCRIPT_DIR/changing_pass.txt"
	user_cont "User passwords changed"
}

function check_users()
{
    #YN_prompt "Do you want to select "select_editor
    #user_cont "Enter in the users from the cyberpatriots README into this file."
    #$editor $SCRIPT_DIR/authorized_user_list.txt

	echo "" > "$SCRIPT_DIR/bad_users.txt"
    echo "Enter in the users from the cybepatiot README:"
    a_users=`cat`

    echo "Unauthorized users found:" > "$SCRIPT_DIR/bad_users.txt"
    #Get users from /etc/passwd
    sys_users=$(awk -F":" '{ if ($3>=1000) print $1}' /etc/passwd)
	echo "System Users"
	echo "$sys_users"
    for s in "${sys_users[@]}"; do
        match=false
        for u in "${a_users[@]}"; do
            if [ "$s" == "$u" ];then
                match=true
            fi
        done
        if [ $match = false ];then
            echo "$s" >> "$SCRIPT_DIR/bad_users.txt"
        fi
    done
    cat "$SCRIPT_DIR/bad_users.txt"
    user_cont "Check these users."
}

function get_bad_files()
{
    echo "Bad files will be found using the locate command. Output will later be put into a file for further exmination."    
    user_cont
    for i in "${file_ext[@]}"; do
        locate "*.$i" | tee "$SCRIPT_DIR/$i-files.txt"
        echo "Take note for any suspicous files and delete them later after invetigating!"
        user_cont
    done
    echo "Done searching for bad files."
    user_cont
}

function menu()
{
    echo "Menu:"
    echo "1. Setup <-- Run once"
    echo "2. Find bad files"
    echo "3. Antivirus scan"
    echo "4. Find unauthorized users"
    echo "5. Change user passwords"
    echo "Enter in the option you want"
    read menu_option

    case $menu_option in

        1) setup;;
        2) get_bad_files;;
        3) antivirus_scan;;
        4) check_users;;
        5) change_passwords;;
        *) user_cont "ERR: Invlalid input.";;
	esac
}

echo "Welcome to Rohan Bhargava's Ubuntu Cyberpatiot Script! This is for Team Zeus use only! Best of luck for the competition!"
echo "Make sure to run the setup function once!"
while true;do
	menu	
done
