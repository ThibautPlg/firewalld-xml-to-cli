# Firewalld xml converter

Quick and simple bash script to convert back firewalld xml files to firewall-cmd commands.
Rare usecase, I know, but I couldn't find an existing script that does that and based on [this github issue](https://github.com/firewalld/firewalld/issues/283), I'm not alone!

/!\ Warning: it's really bare-bones and covers a small portion of what is possible to make with firewalld. See "What it does not" section.

## Requirements
- [xq](https://github.com/sibprogrammer/xq) which is used to parse the xml files.

## Usage
```
sudo ./firewall-cmd-dump.sh
```
Or by using stdout

```
sudo ./firewall-cmd-dump.sh > /tmp/firewall-cmd-MyServer.sh
```
### What it does
- Parse `zone.xml` files from `/etc/firewalld/zones/`
- Create cli commands to
  - Create new zones
  - Open Ports
  - Add Sources
### What it does not
- Remove things (for example if you removed `ssh` from the `work` zone, it will not create the `--remove-service` command)
- Other operations than the ones related to `port`, `sources` and `zones` (no `services`, no `ipsets`...)

## Output example
`cat /tmp/firewall-cmd-MyServer.sh`
```
#Create an executable file by using stdout. "sudo ./firewall-cmd-dump.sh > /tmp/firewall-cmd-MyServer.sh"

#__________ zone internal-ssh __________#
sudo firewall-cmd --permanent --new-zone="internal-bastion"
sudo firewall-cmd --permanent --zone="internal-bastion" --add-port="22/tcp"
sudo firewall-cmd --permanent --zone="internal-bastion" --add-source="10.0.0.210"
sudo firewall-cmd --permanent --zone="internal-bastion" --add-source="10.0.0.211"
#__________ zone public __________#
sudo firewall-cmd --permanent --zone="public" --add-port="80/tcp"
sudo firewall-cmd --permanent --zone="public" --add-port="443/tcp"
#__________ zone zabbix __________#
sudo firewall-cmd --permanent --new-zone="zabbix"
sudo firewall-cmd --permanent --zone="zabbix" --add-port="10050/tcp"
sudo firewall-cmd --permanent --zone="zabbix" --add-source="10.0.0.10"
sudo firewall-cmd --permanent --reload
```

## get-zones-from-servers-ansible.yml

A bonus ansible playbook to get automatically the xml files from all your servers and put them in a local directory.
Uncomment the second `ZONES_DIR` in the `CONFIG` section of the script to use what has been fetched with Ansible.

## Contributions
Are welcome of course. This minimal proof of concept covers my immediate usecase and is yet to be improved.
