function_name switch_screen_layout() {
config_file=$HOME"/.current_screenlayout"
num_of_monitors=$(xrandr -q| grep "\sconnected\s" | wc -l)
echo $num_of_monitors
if [[ -e "$config_file" ]] then
    current_screenlayout=$(cat $config_file)
    for folder in ~/.screenlayout/*/; do
        if [[ $folder =~ ".screenlayout/$num_of_monitors" ]] then
            has_match=false
            changed=false
            for file in "$folder"*; do
                if [[ "$has_match" == true ]] then
                    echo "$file" > $config_file
                    bash "$file"
                    echo "swich to profile $file"
                    changed=true
                    return 1
                fi
                if [[ "$current_screenlayout" == "$file" ]] then
                    has_match=true
                fi
            done
            files=( $(ls "$folder"*) )
            first_file=${files[1]}
            echo "$first_file" > $config_file
            bash "$first_file"
            return 1
        fi
    done
fi
}

switch_screen_layout
