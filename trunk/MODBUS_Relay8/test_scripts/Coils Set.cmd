@echo off
call settings.cmd
set /A mbp_coilend=%mbp_coilstart% + %mbp_coilcount% - 1
FOR /L %%a IN (%mbp_coilstart%,1,%mbp_coilend%) DO modpoll -m rtu -b %mbp_baud% -a %mbp_slaveaddr% -r %%a -t 0 %mbp_com% 1
FOR /L %%a IN (%mbp_coilstart%,1,%mbp_coilend%) DO modpoll -m rtu -b %mbp_baud% -a %mbp_slaveaddr% -r %%a -t 0 %mbp_com% 0
pause