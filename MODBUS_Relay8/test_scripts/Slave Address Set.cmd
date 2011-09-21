@echo off
call settings.cmd
modpoll -m rtu -b %mbp_baud% -a %mbp_defslaveaddr% -r %mbp_regslaveaddr% -t 4 -1 %mbp_com% %mbp_slaveaddr%
modpoll -m rtu -b %mbp_baud% -a %mbp_defslaveaddr% -r %mbp_regrestart% -t 4 -1 %mbp_com% 1
pause