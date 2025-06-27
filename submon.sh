#!/bin/bash

banner="
   _____ _    _ ____  __  __  ___  _   _ 
  / ____| |  | |  _ \\|  \\/  |/ _ \\| \\ | |
 | (___ | |  | | |_) | \\  / | | | |  \\| |
  \\___ \\| |  | |  _ <| |\\/| | | | | .\` |
  ____) | |__| | |_) | |  | | |_| | |\\  |
 |_____/ \\____/|____/|_|  |_|\\___/|_| \\_|

              SUBMON by Marcos Suarez
"

echo "$banner"

DOMAINS_FILE="domains.txt"
OUTPUT_DIR="submon_data"
WEBHOOK="WEBHOOK URL"  # Reemplazá por tu webhook real

mkdir -p "$OUTPUT_DIR"

ALL_TMP="$OUTPUT_DIR/all.tmp.txt"
ALL_LIVE="$OUTPUT_DIR/all.live.txt"
ALL_CURRENT="$OUTPUT_DIR/all_subs.txt"
ALL_NEW="$OUTPUT_DIR/new_subs.txt"

rm -f "$ALL_TMP" "$ALL_LIVE"

# Recolectar subdominios de todos los dominios
while IFS= read -r domain || [ -n "$domain" ]; do
    [ -z "$domain" ] && continue
    echo -e "\n[+] Scanning subdomains for: $domain"

    tmpfile="$OUTPUT_DIR/$domain.temp.txt"
    s3out="$OUTPUT_DIR/sublister_$domain.txt"

    subfinder -silent -d "$domain" > "$tmpfile" 2>/dev/null
    assetfinder --subs-only "$domain" >> "$tmpfile" 2>/dev/null
    timeout 120 sublist3r -d "$domain" -o "$s3out" > /dev/null 2>&1
    cat "$s3out" >> "$tmpfile"

    sort -u "$tmpfile" >> "$ALL_TMP"

    rm -f "$tmpfile" "$s3out"
done < "$DOMAINS_FILE"

# Verificar subdominios vivos
httpx -silent -l "$ALL_TMP" -timeout 10 -threads 50 -status-code -no-color \
    | cut -d " " -f1 | sort -u > "$ALL_LIVE"

# Crear archivo principal si no existe
[ ! -f "$ALL_CURRENT" ] && touch "$ALL_CURRENT"
sort -u "$ALL_CURRENT" -o "$ALL_CURRENT"

# Detectar nuevos subdominios vivos
comm -13 "$ALL_CURRENT" "$ALL_LIVE" > "$ALL_NEW"

if [ -s "$ALL_NEW" ]; then
    echo -e "\n[+] New live subdomains found: $(wc -l < "$ALL_NEW")"

    # Enviar a Discord
    curl -s -F "file=@$ALL_NEW" \
         -F "payload_json={\"content\":\"📡 New live subdomains detected across all monitored domains.\"}" \
         "$WEBHOOK" > /dev/null

    # Actualizar archivo global
    cat "$ALL_NEW" >> "$ALL_CURRENT"
    sort -u "$ALL_CURRENT" -o "$ALL_CURRENT"
    rm -f "$ALL_NEW"
else
    echo -e "\n[-] No new live subdomains found"
    rm -f "$ALL_NEW"
fi

# Limpieza final
rm -f "$ALL_TMP" "$ALL_LIVE"
