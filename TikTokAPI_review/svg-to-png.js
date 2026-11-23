// Script pour convertir le logo SVG en PNG (512x512)
// Nécessite : npm install sharp (ou utiliser un outil en ligne)

// Usage: node svg-to-png.js

import { readFileSync, writeFileSync } from 'fs';
import sharp from 'sharp';

const svgBuffer = readFileSync('./logo.svg');

sharp(svgBuffer, { density: 300 })
  .resize(512, 512, { fit: 'fill', background: { r: 0, g: 0, b: 0, alpha: 0 } })
  .png({ compressionLevel: 9 })
  .toFile('./logo.png')
  .then(info => {
    console.log('✅ logo.png généré :', info);
    console.log('   Taille:', info.size, 'bytes');
    console.log('   Dimensions:', info.width, 'x', info.height);
    console.log('   Format:', info.format);
  })
  .catch(err => {
    console.error('❌ Erreur:', err.message);
    console.log('\n💡 Alternatives pour générer le PNG :');
    console.log('1. En ligne : https://svgtopng.com / https://convertio.co/svg-png/');
    console.log('2. Ligne de commande (si Inkscape installé) :');
    console.log('   inkscape logo.svg --export-type=png --export-filename=logo.png --export-width=512 --export-height=512');
    console.log('3. Avec ImageMagick :');
    console.log('   magick -density 300 -background none logo.svg -resize 512x512 logo.png');
    console.log('4. Navigateur : Ouvrir logo.svg → Clic droit → "Enregistrer l\'image" → Choisir PNG');
  });