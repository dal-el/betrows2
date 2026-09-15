@echo off
cd /d "%~dp0"
echo Ενημερωση GitHub με τα τελευταια δεδομενα (BetRows)...
echo.

copy /Y "C:\SOCCER_BETROWS\betrows-app\data.json" "data.json" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\index.html" "index.html" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\crest-map.json" "crest-map.json" >nul

git add -A
git commit -m "update data %date% %time%"
git push

echo.
echo Ετοιμο! Η online σελιδα (https://dal-el.github.io/betrows2/) θα ενημερωθει σε 1-2 λεπτα.
pause
