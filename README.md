# wp-remote-maintenance

Useful script to maintain remote wordpress.

## Requiremenmt

wp-cli ("wp" in remote $PATH): https://make.wordpress.org/cli/ 

## Getting started

1. Install wp-cli into remote.
2. Create temporary directory in remote. (/remote-path/to/tmp)
3. Get wp-remote-maintenance.sh from GitHub
    * wget https://raw.githubusercontent.com/knaou/wp-remote-maintenance/master/wp-remote-maintenance.sh
4. Create backup directory (/path/to/)
5. Execute update and backup

    ./wp-remote-maintenance.sh -n Backup-name -b /path/to/ -t /remote-path/to/tmp/ -d /remote-path/to/wp-dir/ -H user@remote-host -P 22

