@echo off
call settings.cmd
modpoll -m rtu -b %mbp_baud% -p %mbp_parity% -a %mbp_slaveaddr% -r %mbp_coilstart% -c %mbp_coilcount% -t 0 -l %mbp_pollrate% %mbp_com%
pause