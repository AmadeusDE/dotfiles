#!/bin/sh
SCREENSHOTS="$HOME/Pictures/Screenshots/"
[ ! -d "$SCREENSHOTS" ] && mkdir -p "$SCREENSHOTS"
rm /tmp/swappy.png
touch /tmp/swappy.png
cp /tmp/swappy.png /tmp/swappy2.png
ACTIVEWINDOW=$(hyprctl activewindow)
START=$(echo "$ACTIVEWINDOW" | grep at: | cut -c 6-)
SIZE=$(echo "$ACTIVEWINDOW" | grep size: | cut -c 8- | tr ',' 'x')
TITLE=$(echo "$ACTIVEWINDOW" | grep title: | cut -c 9- | sed -e 's/[^A-Za-z0-9._ -]/_/g')
grim -g "$START $SIZE" - | swappy -f -
# cat is required because sha1sum does not have a flag to disable outputting its filename, and thus needs to be tricked into not having a file name in the output
# shellcheck disable=SC2002
if [ "$(cat /tmp/swappy.png | sha1sum)" != "$(cat /tmp/swappy2.png | sha1sum)" ]
then
    mkdir -p "$SCREENSHOTS"/"$TITLE"
    TMPNAME=$(date '+%Y:%m:%d:%H:%M:%S')
    SAVENAME="$(zenity --title="Save Screenshot" --file-selection --save --confirm-overwrite --filename="$SCREENSHOTS"/"$TITLE"/"$TMPNAME".webp)"
    magick /tmp/swappy.png -quality 100 /tmp/swappy.webp
    cp -f /tmp/swappy.webp "$SAVENAME"
fi