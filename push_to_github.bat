@echo off
cd /d "%~dp0"
echo Ενημερωση GitHub με τα τελευταια δεδομενα (BetRows)...
echo.

REM ============================================================================
REM  ΑΣΦΑΛΕΙΑ ΖΩΗΣ (10/10/2026): το robocopy /MIR με ΑΔΕΙΑ πηγη ΣΒΗΝΕΙ τον
REM  προορισμο. Οταν ο fetcher δεν κατεβασε τιποτα (σφαλμα δικτυου, Cloudflare,
REM  μηδεν αγωνες στο παραθυρο) ο φακελος output εμενε αδειος, και αυτο το
REM  script μετεφερε το κενο στο betrows-app\live -> ΧΑΘΗΚΑΝ ΟΛΑ ΤΑ LINES.
REM  Απο εδω και περα: αν η πηγη δεν εχει index.json, ΔΕΝ αγγιζουμε τον
REM  προορισμο. Καλυτερα παλια δεδομενα παρα κανενα.
REM ============================================================================
set "ST_OK=0"
set "SB_OK=0"
if exist "C:\SOCCER_BETROWS\betrows-fetcher\output\index.json" set "ST_OK=1"
if exist "C:\SOCCER_BETROWS\betrows-fetcher\output-superbet\index.json" set "SB_OK=1"
if "%ST_OK%"=="0" echo ΠΡΟΣΟΧΗ: ο φακελος output (Stoiximan) ειναι αδειος - ΔΕΝ πειραζουμε το live.
if "%SB_OK%"=="0" echo ΠΡΟΣΟΧΗ: ο φακελος output-superbet ειναι αδειος - ΔΕΝ πειραζουμε το live-superbet.
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
if "%ST_OK%"=="0" goto skip_stoiximan
robocopy "C:\SOCCER_BETROWS\betrows-fetcher\output" "C:\SOCCER_BETROWS\betrows-app\live" /L /MIR /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 1 (
  if not exist "C:\SOCCER_BETROWS\betrows-app\live-prev" mkdir "C:\SOCCER_BETROWS\betrows-app\live-prev"
  robocopy "C:\SOCCER_BETROWS\betrows-app\live" "C:\SOCCER_BETROWS\betrows-app\live-prev" /MIR /NFL /NDL /NJH /NJS >nul
)

robocopy "C:\SOCCER_BETROWS\betrows-fetcher\output" "C:\SOCCER_BETROWS\betrows-app\live" /MIR /NFL /NDL /NJH /NJS >nul
:skip_stoiximan

REM 1c) ΤΟ ΙΔΙΟ ROTATION ΓΙΑ ΤΗ SUPERBET: output-superbet -> live-superbet, με
REM     αντιγραφο του προηγουμενου στο live-superbet-prev (απο εκει διαβαζει η
REM     σελιδα τη μετατοπιση γραμμης ΑΝΑ ΕΤΑΙΡΕΙΑ). Αν δεν εχει τρεξει ποτε ο
REM     fetch_superbet.py, ο φακελος δεν υπαρχει και το βημα παρακαμπτεται.
REM     ΠΡΟΣΟΧΗ: το "if errorlevel 1" μενει σε ΠΡΩΤΟ επιπεδο (οχι μεσα σε αλλη
REM     παρενθεση) — ιδιο μοτιβο με το 1b παραπανω, ωστε να διαβαζεται η τιμη
REM     ΤΗΝ ΩΡΑ που τρεχει η γραμμη και οχι οταν γινεται parse το μπλοκ.
if "%SB_OK%"=="0" goto :no_superbet
if not exist "C:\SOCCER_BETROWS\betrows-fetcher\output-superbet" goto :no_superbet
if not exist "C:\SOCCER_BETROWS\betrows-app\live-superbet" mkdir "C:\SOCCER_BETROWS\betrows-app\live-superbet"
robocopy "C:\SOCCER_BETROWS\betrows-fetcher\output-superbet" "C:\SOCCER_BETROWS\betrows-app\live-superbet" /L /MIR /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 1 (
  if not exist "C:\SOCCER_BETROWS\betrows-app\live-superbet-prev" mkdir "C:\SOCCER_BETROWS\betrows-app\live-superbet-prev"
  robocopy "C:\SOCCER_BETROWS\betrows-app\live-superbet" "C:\SOCCER_BETROWS\betrows-app\live-superbet-prev" /MIR /NFL /NDL /NJH /NJS >nul
)
robocopy "C:\SOCCER_BETROWS\betrows-fetcher\output-superbet" "C:\SOCCER_BETROWS\betrows-app\live-superbet" /MIR /NFL /NDL /NJH /NJS >nul
:no_superbet

REM 1d) ΑΥΤΟΜΑΤΗ αρχειοθετηση των betrows/lines/αποδοσεων ανα ημερα αγωνων στο
REM     betrows-app\lines-archive (μικρα JSON, ~700KB/ημερα). Απο εκει τα
REM     διαβαζει ΜΟΝΗ ΤΗΣ η results.html — δεν μετακινει ο χρηστης κανενα αρχειο.
python "C:\SOCCER_BETROWS\betrows-fetcher\archive_lines.py" --book stoiximan
python "C:\SOCCER_BETROWS\betrows-fetcher\archive_lines.py" --book superbet

REM 2) Αντιγραφη βασικων αρχειων + live φακελου + emblems (crests) μεσα στο local git repo
copy /Y "C:\SOCCER_BETROWS\betrows-app\data.json" "data.json" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\index.html" "index.html" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\crest-map.json" "crest-map.json" >nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\league-crest-map.json" "league-crest-map.json" >nul 2>nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\team-map.json" "team-map.json" >nul 2>nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\results.html" "results.html" >nul 2>nul
copy /Y "C:\SOCCER_BETROWS\betrows-app\results-archive.json" "results-archive.json" >nul 2>nul
REM Ιδιος κανονας και προς το repo: αν το live ειναι αδειο, δεν σβηνουμε ο,τι
REM ειναι ηδη ανεβασμενο στο GitHub.
if not exist "C:\SOCCER_BETROWS\betrows-app\live\index.json" goto skip_live_repo
if not exist "live" mkdir "live"
robocopy "C:\SOCCER_BETROWS\betrows-app\live" "live" /MIR /NFL /NDL /NJH /NJS >nul
:skip_live_repo
if not exist "live-prev" mkdir "live-prev"
robocopy "C:\SOCCER_BETROWS\betrows-app\live-prev" "live-prev" /MIR /NFL /NDL /NJH /NJS >nul
REM Τα feeds της Superbet — η σελιδα τα διαβαζει απο τα ιδια ονοματα φακελων.
if not exist "C:\SOCCER_BETROWS\betrows-app\live-superbet\index.json" goto skip_sb_repo
if not exist "live-superbet" mkdir "live-superbet"
robocopy "C:\SOCCER_BETROWS\betrows-app\live-superbet" "live-superbet" /MIR /NFL /NDL /NJH /NJS >nul
:skip_sb_repo
if exist "C:\SOCCER_BETROWS\betrows-app\live-superbet-prev" (
  if not exist "live-superbet-prev" mkdir "live-superbet-prev"
  robocopy "C:\SOCCER_BETROWS\betrows-app\live-superbet-prev" "live-superbet-prev" /MIR /NFL /NDL /NJH /NJS >nul
)
if not exist "lines-archive" mkdir "lines-archive"
robocopy "C:\SOCCER_BETROWS\betrows-app\lines-archive" "lines-archive" /MIR /NFL /NDL /NJH /NJS >nul
if exist "C:\SOCCER_BETROWS\betrows-app\lines-archive-superbet" (
  if not exist "lines-archive-superbet" mkdir "lines-archive-superbet"
  robocopy "C:\SOCCER_BETROWS\betrows-app\lines-archive-superbet" "lines-archive-superbet" /MIR /NFL /NDL /NJH /NJS >nul
)
if not exist "crests" mkdir "crests"
robocopy "C:\SOCCER_BETROWS\betrows-app\crests" "crests" /MIR /NFL /NDL /NJH /NJS >nul
REM Λογοτυπα εταιρειων (stoiximan.png / superbet.png) — η σελιδα τα δειχνει
REM διπλα σε καθε ονομα bookmaker, οποτε πρεπει να ανεβαινουν κι αυτα.
if not exist "bookmakers" mkdir "bookmakers"
robocopy "C:\SOCCER_BETROWS\betrows-app\bookmakers" "bookmakers" /MIR /NFL /NDL /NJH /NJS >nul

REM 3) Commit + push στο GitHub
git add -A
git commit -m "update data %date% %time%"
git push

echo.
echo Ετοιμο! Η online σελιδα (https://dal-el.github.io/betrows2/) θα ενημερωθει σε 1-2 λεπτα.
pause
