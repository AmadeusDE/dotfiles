#!/bin/sh
SCREENSHOTS="$HOME/Pictures/Screenshots/"
[ ! -d "$SCREENSHOTS" ] && mkdir "$SCREENSHOTS"
rm /tmp/swappy.png
touch /tmp/swappy.png
cp /tmp/swappy.png /tmp/swappy2.png
grim -g "$(slurp)" - | swappy -f -
# cat is required because sha1sum does not have a flag to disable outputting its filename, and thus needs to be tricked into not having a file name in the output
# shellcheck disable=SC2002
if [ "$(cat /tmp/swappy.png | sha1sum)" != "$(cat /tmp/swappy2.png | sha1sum)" ]
then
    TMPNAME=$(date '+screenshot-%Y:%m:%d:%H:%M:%S')
    SAVENAME="$(zenity --title="Save Screenshot" --file-selection --save --confirm-overwrite --filename="$SCREENSHOTS"/"$TMPNAME".webp)"
    magick /tmp/swappy.png -quality 100 /tmp/swappy.webp
    cp -f /tmp/swappy.webp "$SAVENAME"
fi