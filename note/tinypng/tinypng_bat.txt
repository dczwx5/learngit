# #!/bin/bash
dir=/tiny_src
dir2=/tiny_dest
echo Enter $dir
cd $dir
mkdir -p $dir2

parse_json(){  
value=`echo $1 | sed 's/.*"url":\([^,}]*\).*/\1/'`
echo $value | sed 's/\"//g'
}  

travel_file()
{
    echo $1    
    mkdir -p $2
    for file in `ls $1`
    do
        if [ -f "$1/$file" ]; then
            echo $1/$file
            if [ ${file##*.} == "png" ] || [ ${file##*.} == "PNG" ]; then
                for i in {1..2}
                do
                    echo upload$i $1/$file
                    s=$(cat $1/$file | curl https://api.tinify.com/shrink --user api:i4S-XnT3ykpdjwSMrA8T1aPfxcZpvXVE --data-binary @- --connect-timeout 10 -m 2000)
                    echo "s:$s"
                    url=$(parse_json $s "url")
                    echo "url:$url"
                    if [ -n "$url" ]; then
                        break
                    fi
                done

                for i in {1..2}
                do
                    echo getlength$i $url
                    length=$(curl --head $url --connect-timeout 10 -m 30 | grep "Content-Length" | cut -c 17-)
                    if [ -n "$length" ]; then
                        length=${length:0:${#length}-1}
                        echo length ${#length} $length
                        break
                    fi
                done

                for i in {1..2}
                do
                    echo download$i $url                    
                    curl $url > $2/$file --connect-timeout 10 -m 400
                    len=$(ls -l $2/$file | awk '{print $5}')
                    echo len ${#len} $len
                    echo length ${#length} $length
                    if [ $len == $length ]; then
                        echo success! $file
                        break
                    fi
                done
            fi
        fi
        if [ -d "$1/$file" ]; then
            travel_file $1/$file $2/$file
        fi
    done

}


travel_file $dir $dir2