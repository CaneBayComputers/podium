# CD
alias ~='cd ~'
alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'

# Docker
alias dockerup="docker compose up -d"
alias dockerdown="docker compose down"
alias dockerexec="docker container exec -it"
alias dockerls="docker container ls"
alias dockerrm="docker container rm"
alias dockerexec-root='dockerexec --user root $(basename $(pwd))'
alias dockerexec-developer='dockerexec --user $(id -u):$(id -g) $(basename $(pwd))'
alias check-mariadb='[ "$(docker ps -q -f name=mariadb)" ] && true || false'
alias check-phpmyadmin='[ "$(docker ps -q -f name=phpmyadmin)" ] && true || false'

# Redis
alias redis-cli="dockerexec redis redis-cli"
alias redis-flushall="redis-cli FLUSHALL"


# Color
alias echo-red='tput setaf 1 ; echo'
alias echo-green='tput setaf 2 ; echo'
alias echo-yellow='tput setaf 3 ; echo'
alias echo-blue='tput setaf 4 ; echo'
alias echo-magenta='tput setaf 5 ; echo'
alias echo-cyan='tput setaf 6 ; echo'
alias echo-white='tput setaf 7; echo'

# Artisan
alias art='php artisan'
alias art-docker='dockerexec-developer php /usr/share/nginx/html/artisan'
alias art-docker-db-refresh='art-docker migrate:fresh; art-docker db:seed'
alias art-docker-refresh='art-docker cache:clear; art-docker route:clear; art-docker config:clear; composer-docker dump-autoload'

# Git
alias gstatus='echo; echo-green $(pwd) ; echo-white ; git status ; divider'
alias gstatusall='for DIR in */; do cd $DIR; if ! git diff-index --quiet HEAD --; then gstatus; fi; cd ..; done'
alias gbranch='git branch -a -v'
alias gadd='git add -A'
alias gcommit='git commit -a -m'
alias gpush='git push -v'
alias gpushall='for DIR in */; do cd $DIR; echo; echo-green $DIR; echo-white; gpull; divider; cd ..; done'
alias gpull='git pull -v'
alias gpullall='for DIR in */; do cd $DIR; echo; echo-green $DIR; echo-white; gpull; divider; cd ..; done'
alias gquick='echo "Commit message: " && read MESSAGE && gstatus && gadd && gcommit "$MESSAGE" && gpush'

# Sudo
alias ifconfig='sudo ifconfig'
alias umount='sudo umount'
alias mount='sudo mount'
alias sshfs='sudo sshfs -o allow_other'
alias su='sudo su'
alias apt-get='sudo apt-get -y'
alias systemctl='sudo systemctl'
alias service='sudo service'
alias updatedb='sudo updatedb'
alias iptables='sudo iptables'
alias shutdown='sudo shutdown -h now'
alias lsusb='sudo lsusb'
alias lspci='sudo lspci'
alias lsblk='sudo lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL'
alias visudo='sudo visudo'
alias docker="sudo docker"
alias dd='sudo dd'

# Composer
alias composer-docker='dockerexec-developer composer -d /usr/share/nginx/html'

# WP
alias wp-docker='dockerexec-developer wp'

# Misc
alias la='ls -la'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias crontab='crontab -e'
alias bash_aliases='nano ~/.bash_aliases; source ~/.bash_aliases; echo-green "New aliases loaded!"; echo-white'
alias untar='tar -xvf'
alias hosts='sudo nano /etc/hosts'
alias mount-bucket='echo -ne "Bucket: " && read B && mkdir -p ~/s3/$B && s3fs $B ~/s3/$B -o passwd_file=~/.passwd-s3fs,use_path_request_style'
alias whatismyip='dig +short myip.opendns.com @resolver1.opendns.com'
alias divider='echo; echo-white '==============================='; echo'
alias iptablesls='iptables -L -v -n'
