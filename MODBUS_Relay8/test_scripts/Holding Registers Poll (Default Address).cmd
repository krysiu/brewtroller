@echo off
call settings.cmd
modpoll -m rtu -b %mbp_baud% -a %mbp_defslaveaddr% -r %mbp_regstart% -c %mbp_regcount% -t 4 %mbp_com%