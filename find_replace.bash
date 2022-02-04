#!/bin/bash
#JJones 2022

function to_upper()
{
    local capitalised=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    echo $capitalised
}

function confirm_replacement() 
{
    local yval="Y"
    local nval="N"

    if [[ $1 = "Y" ]]
    then
        echo $yval
    elif [[ $1 = "N" ]]
    then
        echo $nval
    else
        read -p "Unrecognised input please retry with y or n: " retry_response
        retry_response=$(to_upper $retry_response)
        confirm_replacement $retry_response
    fi
}

function replace_text()
{
    read -p "Would you like to replace the match? [y/n]: " do_replace
    answer=$(to_upper $do_replace)
    
    if [[ $answer = "Y" ]]
    then
        read -p "Enter replacement text: " replacement_text
        read -p "You entered $replacement_text , is that correct? [y/n] " confirm_replace
        confirm_replace=$(to_upper $confirm_replace)
        y_or_n=$(confirm_replacement $confirm_replace)

        if [[ $y_or_n = "Y" ]]
        then
            echo $2
            sed -i "s/$1/$replacement_text/" $2
            echo "Replaced. Continuing."
        fi

    elif [[ $answer = "N" ]]
    then
         echo "Continuing...."
    else
        echo "Unrecognised input - retrying..\n"
        replace_text $1
    fi
}

function find_text() 
{
    arr=("$@")
    for file in "${arr[@]}";
    do
        #Comment out if you want to use a static word
        read -p "Enter text to find: " txt_to_find
        
        if (grep -Fq "$txt_to_find" $file)
        then
            match="$(grep -Fo "$txt_to_find" $file)"
            echo "Found : $match"
            replace_text $match $file
        fi
    done
}

function find_files() {
    read -p "Enter filename keyword: " filename
    readarray -d '' arr_files < <(find . -name "${filename}" -print0)
    echo "Number of files found: ${#arr_files[@]}"
    find_text ${arr_files[@]}
}

find_files