#!/bin/sh
# filepath: merge_wireless.sh

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <folder>"
  exit 1
fi

FOLDER="$1"
MAIN="$FOLDER/wireless.main"
KEY="$FOLDER/wireless.key"
OUT="$FOLDER/wireless"

if [ ! -f "$MAIN" ]; then
  echo "Missing $MAIN"
  exit 3
fi
if [ ! -f "$KEY" ]; then
  echo "Missing $KEY"
  exit 4
fi

cp "$MAIN" "$OUT"

# Read each line from wireless.key and perform substitution
while IFS= read -r line; do
  # Skip empty lines and comments
  [ -z "$line" ] && continue
  echo "$line" | grep -q '^#' && continue

  # Extract placeholder and value
  placeholder=$(echo "$line" | cut -d'=' -f1)
  value=$(echo "$line" | cut -d"'" -f2)

  # Replace both KEY_xxx and __KEY_xxx__ in OUT with actual value
  sed -i '' "s|$placeholder|$value|g" "$OUT"
  sed -i '' "s|__${placeholder}__|$value|g" "$OUT"
done < "$KEY"

echo "Merged $MAIN and $KEY into $OUT"