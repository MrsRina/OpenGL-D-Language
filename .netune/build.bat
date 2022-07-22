@echo off
cd C:\Users\Diyng\Desktop\oi
title %title% 
echo [Netune] %description% 
echo ---------------------------------------------------
title You should edit this at the Settings button. or File > Runtime Settings
dub build
pause > nul
title You should edit this at the Settings button. or File > Runtime Settings
dub run
pause > nul

echo ----------------------------------------------------
echo [Netune] Closing this CMD Window in 45 seconds.
ping localhost -n 45 > nul
exit