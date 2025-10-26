#!/bin/sh
#-------------------------------------------------------------------------------
# VimPuginThingy - Installs plugins from urls provided in $VIMPLUGINSLIST
#
#Uses $EDITOR variable so make sure it is set
#Required fzy or fzf and git
#
# You can disable/enable plugins in $VIMPLUGINLIST and then running un/install

VIMPLUGINSDIR="$HOME/.vim/pack/plugins/start"
VIMPLUGINSLIST="$HOME/.vim/plugins"

mkdir -p "$VIMPLUGINSDIR"

while :; do
main_choice=$(printf "Add\nInstall All\nUninstall\nQuit" | fzf)

case "$main_choice" in
    "Add")
        "$EDITOR" "$VIMPLUGINSLIST" ;;

    "Install All")
        awk 'NF && $0 !~ /^#/' "$VIMPLUGINSLIST" | while IFS= read -r repo; do
            name=$(basename "$repo" .git)
            dest="$VIMPLUGINSDIR/$name"
            if [ -d "$dest" ]; then
                echo "Skipped $name (already installed)"
            else
                echo "Clone $repo"
                git clone "$repo" "$dest"
            fi
        done ;;
    "Uninstall")
            while :; do
                installed=$(ls "$VIMPLUGINSDIR")
                if [ -z "$installed" ]; then
                    echo "No plugins installed"
                    break
                fi

                plugin=$(printf "%s\n" $installed | fzf )

                [ -z "$plugin" ] && break
        
                rm -rf "$VIMPLUGINSDIR/$plugin"
                echo "Removed $plugin"

                if [ -f "$VIMPLUGINSLIST" ]; then
                    if grep -q "^[^#].*$plugin" "$VIMPLUGINSLIST"; then
                        sed "/^[^#].*$plugin/d" "$VIMPLUGINSLIST" > "$VIMPLUGINSLIST.tmp" && mv "$VIMPLUGINSLIST.tmp" "$VIMPLUGINSLIST"
                    fi
                fi
            done ;;

    *) echo "Exit" && break ;;
esac
done
