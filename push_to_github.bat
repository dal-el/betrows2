@echo off
cd /d "%~dp0"
echo Ενημερωση GitHub με τα τελευταια δεδομενα (BetRows)...
echo.

REM 1) Αντιγραφη των live Stoiximan JSONs απο τον fetcher στο betrows-app\live
REM    (ετσι δουλευει και η τοπικη προβολη index.html με τα ιδια δεδομενα)
if not exist "C:\SOCCER_BETROWS\betrows-app\live" mkdir "C:\SOCCER_BETROWS\betrows-app\live"

REM 1b) ΠΡΙΝ αντικατασταθουν τα lines: κραταμε αντιγραφο των ΠΡΟΗΓΟΥΜΕΝΩΝ στο
REM     live-prev. Απο εκει διαβαζει το index.html τη μετατοποιση γραμμης/αποδοσης
REM     (δειχνει διπλα στο pill STOIXIMAN ποσο ηταν το line και τη νεα τιμη).
REM     Γινεται ΜΟΝΟ αν ο fetcher εχει οντως νεα/αλλαγμενα αρχεια (robocopy /L =
REM     δοκιμη χωρις αντιγραφη), ωστε δευτερο τρεξιμο του bat να μη σβηνει το
REM     πραγματικο προηγουμενο στιγμιοτυπο.
robocopy "C:\SOCCER_BETROWS\betrows-fetcher\output" "C:\SOCCER_BETROWS\betrows-app\live" /L /MIR /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 1 (
  if not exist "C:\SOCCER_BETROWS\betrows-app\live-prev" mkdir "C:\SOCCER_BETROWS\betrows-app\live-prev"
  robocopy "C:\SOCCER_BETROWS\betrows-app\live" "C:\SOCCER_BETROWS\betrows-app\live-prev" /MIR /NFL /NDL /NJH /NJS >nul
)

robocopy "C:\SOCCER_BETROWS\betrows-fetcher\output" "C:\SOCCER_BETROWS\betrows-app\live" /MIR /NFL /NDL /NJH /NJS >nul

REM 2) Αντιγραφη βασικων αρχειων + live φακελου + emblems (crests) μεσα στο local git repo
copy /Y "C:\SOCCER_BETROWS\betrows-app\data.json" "data.json" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\index.html" "index.html" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\crest-map.json" "crest-map.json" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\league-crest-map.json" "league-crest-map.json" >nul 2>nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\team-map.json" "team-map.json" >nul 2>nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\results.html" "results.html" >nul 2>nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\results-archive.json" "results-archive.json" >nul 2>nul
if not exist "live" mkdir "live"
robocopy "C:\SOCCER_BETROWS\betrows-app\live" "live" /MIR /NFL /NDL /NJH /NJS >nul
if not exist "live-prev" mkdir "live-prev"
robocopy "C:\SOCCER_BETROWS\betrows-app\live-prev" "live-prev" /MIR /NFL /NDL /NJH /NJS >nul
if not exist "crests" mkdir "crests"
robocopy "C:\SOCCER_BETROWS\betrows-app\crests" "crests" /MIR /NFL /NDL /NJH /NJS >nul

REM 3) Commit + push στο GitHub
git add -A
git commit -m "update data %date% %time%"
git push

echo.
echo Ετοιμο! Η online σελιδα (https://dal-el.github.io/betrows2/) θα ενημερωθει σε 1-2 λεπτα.
pause
