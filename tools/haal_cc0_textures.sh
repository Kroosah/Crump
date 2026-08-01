#!/usr/bin/env bash
# Haalt CC0-texturesets op van ambientCG (D-031: alleen ambientCG en Poly
# Haven) en zet ze in assets/textures/<map>/ met onze vaste namen
# <map>_color.jpg / _normal.jpg / _rough.jpg (1K JPG).
#
# Reproduceerbaarheid: dit script documenteert exact welke bron-asset bij
# welke map hoort; assets/textures/LICENSE.md houdt dezelfde tabel bij.
# Draaien vanuit de projectroot:  bash tools/haal_cc0_textures.sh
set -euo pipefail
UIT="assets/textures"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# map|bron-asset  (fase G tier F2; tier F1 haalde de eerste 13 sets)
SETS=(
	"tegel_klein_wit|Tiles036"
	"plafondverf|Plaster001"
	"granito|Terrazzo004"
	"coating_glad|Concrete016"
	"rubber|Rubber004"
)

for regel in "${SETS[@]}"; do
	map="${regel%%|*}"
	asset="${regel##*|}"
	if [[ -f "$UIT/$map/${map}_color.jpg" ]]; then
		echo "· $map staat er al — overgeslagen"
		continue
	fi
	echo "· $map ← $asset"
	curl -sSL -o "$TMP/$asset.zip" \
		"https://ambientcg.com/get?file=${asset}_1K-JPG.zip"
	rm -rf "$TMP/$asset" && mkdir -p "$TMP/$asset"
	unzip -qo "$TMP/$asset.zip" -d "$TMP/$asset"
	mkdir -p "$UIT/$map"
	cp "$TMP/$asset/${asset}_1K-JPG_Color.jpg"     "$UIT/$map/${map}_color.jpg"
	cp "$TMP/$asset/${asset}_1K-JPG_NormalGL.jpg"  "$UIT/$map/${map}_normal.jpg"
	cp "$TMP/$asset/${asset}_1K-JPG_Roughness.jpg" "$UIT/$map/${map}_rough.jpg"
done

echo "Klaar. Vergeet assets/textures/LICENSE.md niet bij te werken."
