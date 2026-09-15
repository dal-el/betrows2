@echo off
cd /d "%~dp0"
echo Ενημερωση GitHub με τα τελευταια δεδομενα (BetRows)...
echo.

REM 1) Αντιγραφη των live Stoiximan JSONs απο τον fetcher στο betrows-app\live
REM    (ετσι δουλευει και η τοπικη προβολη index.html με τα ιδια δεδομενα)
if not exist "C:\SOCCER_BETROWS\betrows-app\live" mkdir "C:\SOCCER_BETROWS\betrows-app\live"
robocopy "C:\SOCCER_BETROWS\betrows-fetcher\output" "C:\SOCCER_BETROWS\betrows-app\live" /MIR /NFL /NDL /NJH /NJS >nul

REM 2) Αντιγραφη βασικων αρχειων + live φακελου + emblems (crests) μεσα στο local git repo
copy /Y "C:\SOCCER_BETROWS\betrows-app\data.json" "data.json" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\index.html" "index.html" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\crest-map.json" "crest-map.json" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\league-crest-map.json" "league-crest-map.json" >nul 2>nul
if not exist "live" mkdir "live"
robocopy "C:\SOCCER_BETROWS\betrows-app\live" "live" /MIR /NFL /NDL /NJH /NJS >nul
if not exist "crests" mkdir "crests"
robocopy "C:\SOCCER_BETROWS\betrows-app\crests" "crests" /MIR /NFL /NDL /NJH /NJS >nul

REM 3) Commit + push στο GitHub
git add -A
git commit -m "update data %date% %time%"
git push

echo.
echo Ετοιμο! Η online σελιδα (https://dal-el.github.io/betrows2/) θα ενημερωθει σε 1-2 λεπτα.
pause
