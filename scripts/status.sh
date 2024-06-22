

alias listcbc='CUR_PWD=$(pwd); cbc-development; if [ -f startup.log ]; then cat startup.log; else echo-red "CBC not started!"; echo-white "Run ./startup.sh"; fi; cd $CUR_PWD'