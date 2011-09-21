@echo off
call settings.cmd
modpoll -m rtu -b %mbp_baud% -a %mbp_slaveaddr% -r %mbp_regidmode% -t 4 -1 %mbp_com% 0
pause