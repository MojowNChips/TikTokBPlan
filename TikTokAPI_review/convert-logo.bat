@echo off
REM ============================================
REM Convertir logo.svg en logo.png (512x512)
REM ============================================
REM Options disponibles selon vos outils installés :

echo.
echo 🎨 Conversion logo.svg → logo.png (512x512, fond transparent)
echo.

REM --- Option 1: Inkscape (recommandé si installé) ---
where inkscape >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Inkscape détecté → conversion en cours...
    inkscape logo.svg --export-type=png --export-filename=logo.png --export-width=512 --export-height=512
    if exist logo.png (
        echo ✅ logo.png généré avec succès !
        goto :verify
    )
)

REM --- Option 2: ImageMagick (magick ou convert) ---
where magick >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ ImageMagick (magick) détecté → conversion en cours...
    magick -density 300 -background none logo.svg -resize 512x512 logo.png
    if exist logo.png (
        echo ✅ logo.png généré avec succès !
        goto :verify
    )
)

where convert >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ ImageMagick (convert) détecté → conversion en cours...
    convert -density 300 -background none logo.svg -resize 512x512 logo.png
    if exist logo.png (
        echo ✅ logo.png généré avec succès !
        goto :verify
    )
)

REM --- Option 3: Node.js + sharp ---
where node >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Node.js détecté → vérification sharp...
    npm list sharp >nul 2>nul
    if %errorlevel% equ 0 (
        echo ✅ sharp installé → conversion en cours...
        node svg-to-png.js
        if exist logo.png (
            echo ✅ logo.png généré avec succès !
            goto :verify
        )
    ) else (
        echo ⚠️ sharp non installé. Installation...
        npm install sharp
        if %errorlevel% equ 0 (
            node svg-to-png.js
            if exist logo.png (
                echo ✅ logo.png généré avec succès !
                goto :verify
            )
        )
    )
)

REM --- Aucune option trouvée ---
echo.
echo ❌ Aucun outil de conversion trouvé automatiquement.
echo.
echo 📋 Solutions manuelles :
echo.
echo 1. ONLINE (le plus simple) :
echo    → https://svgtopng.com  ou  https://convertio.co/svg-png/
echo    → Uploader logo.svg → Télécharger logo.png (512x512)
echo.
echo 2. INKSCAPE (gratuit, open-source) :
echo    → Installer : https://inkscape.org/release/
echo    → Puis relancer ce script
echo.
echo 3. IMAGEMAGICK :
echo    → Installer : https://imagemagick.org/script/download.php
echo    → Puis relancer ce script
echo.
echo 4. NAVIGATEUR :
echo    → Ouvrir logo.svg dans Chrome/Edge/Firefox
echo    → Clic droit → "Enregistrer l'image sous..." → PNG
echo    → Redimensionner à 512x512 si nécessaire (Paint, Preview, etc.)
echo.
pause
exit /b

:verify
echo.
echo 🔍 Vérification du fichier généré :
dir logo.png
echo.
echo ✅ Prêt pour soumission TikTok ! (512x512 PNG, fond transparent)
pause