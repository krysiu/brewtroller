@echo off
call settings.cmd
modpoll -m rtu -b %mbp_baud% -a %mbp_slaveaddr% -r %mbp_regstart% -c %mbp_regcount% -t 4 -l %mbp_pollrate% %mbp_com%
pause