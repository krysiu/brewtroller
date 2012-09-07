@echo off
call settings.cmd
modpoll -m rtu -b %mbp_baud% -p %mbp_parity% -a %mbp_slaveaddr% -r %mbp_regidmode% -t 4 -1 %mbp_com% 1
pause