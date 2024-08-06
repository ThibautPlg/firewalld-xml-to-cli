#! /bin/bash
############## CONFIG ##############
ZONES_DIR="/etc/firewalld/zones/"

# Uncomment if zones were fetched with Ansible
# ZONES_DIR="./zones/"

SHIPPED_ZONES=(block dmz drop external home internal public trusted work)
FIREWALLD_BIN="sudo firewall-cmd --permanent "
FIREWALLD_RELOAD=$FIREWALLD_BIN" --reload"

############## END CONFIG ##############


dump()
{
	echo -e '#\e[96mCreate an executable file by using stdout. "\e[4msudo ./firewall-cmd-dump.sh > /tmp/firewall-cmd-'$(hostname)'.sh\e[24m\e[39m"'
	echo ""
	############## MAIN ##############
	find $ZONES_DIR -name "*.xml" -type f -print0 |
	while IFS= read -r -d '' entry; do

		filename=$(basename -- "$entry")
		zone="${filename%.*}"
		FIREWALLD_ZONE='--zone="'$zone'" '
		echo "#__________ zone $zone __________ on $(basename $(dirname "$entry")) #"

		############## Zones ##############
		if [[ ! $(echo "${SHIPPED_ZONES[@]}" | fgrep -w "$zone") ]]; then
			echo $FIREWALLD_BIN'--new-zone="'$zone'"'
		fi

		############## Ports ##############
		for port in $(xq $entry -x '/zone/port/@port')
		do
			INDEX=1 #Index is required when having multiple ports so we can have the matching protocol
			echo $FIREWALLD_BIN $FIREWALLD_ZONE'--add-port="'$port'/'$(xq $entry -x '/zone/port['$INDEX']/@protocol')'"'
			((INDEX++))
		done

		############## Sources ##############
		for address in $(xq $entry -x '/zone/source/@address')
		do
			echo $FIREWALLD_BIN $FIREWALLD_ZONE'--add-source="'$address'"'
		done

	done

	echo $FIREWALLD_RELOAD
}

checkDependencies(){
	if ! command -v xq &> /dev/null
	then
		echo -e "\e[91mxq was not found. Please install it".
		echo -e "see author's github: \e[4mhttps://github.com/sibprogrammer/xq\e[24m"
		echo -e '"\e[4mapt-get install xq\e[24m" or "\e[4mdnf install xq\e[24m" will probably do it \e[39m'
		exit 1
	fi
}

checkDependencies
dump