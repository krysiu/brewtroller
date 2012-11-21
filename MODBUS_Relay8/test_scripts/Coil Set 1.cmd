@echo off
call settings.cmd
modpoll -m rtu -b %mbp_baud% -p %mbp_parity% -a %mbp_slaveaddr% -r 1001 -t 0 %mbp_com% 1
pause