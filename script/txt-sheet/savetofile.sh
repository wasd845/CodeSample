title_check_flag=""
cat p2.html | while read line
do
    line_tmp=$(echo $line)
    line_tmp2=$(echo $line)
    
    link_url=$(echo $line | sed -nE "s/^<a href=\"(\/node\/[0-9]{5})\">(.*)<.*$/\1/p")
    task_name=$(echo $line_tmp | sed -nE "s/^<a href=\"(\/node\/[0-9]{5})\">(.*)<\/a>.*$/\2/p")

    if ! test -z $link_url
    then
        if ! test -z $title_check_flag
        then
            printf "$link_url\t"
            printf "$task_name\n"
            printf "https://sh.visualon.com$link_url" >> ./task.txt
            printf "\t" >> ./task.txt
            printf "$task_name\n" >> ./task.txt
        fi
    fi

    title_check_flag=$(echo $line_tmp2 | sed -nE "s/.*(title)\">$/\1/p")
    # echo $title_check_flag
done