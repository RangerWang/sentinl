#!/bin/bash -x

## 1 0 1 * * /home/ec2-user/raw-cas/update-index-monthly.sh >> /home/ec2-user/raw-cas/log.monthly 2>&1
option=$1
date=$2
index=$3

CLOUD=aws
ES_PATH=/home/ec2-user/raw-cas
NAME=(raw-cas test-cas-connection test-cas-session test-cas-satisfice raw-test-cas test-cas-media)

add_month_index() {

    if [ x"$date" = x ]; then
        begin=$(date +%s -d "next month")
        d=$(date +%Y.%m -d "@$begin")
        else
        if [ ${date%.*} -ge 2018 ];then
            d=$date
            else
            index=$2
            begin=$(date +%s -d "next month")
            d=$(date +%Y.%m -d "@$begin")
        fi
    fi

    if [ x"$index" = x ]; then
         for x in ${NAME[@]}
         do
            echo "Create Index [ $x-$d ]"
            $ES_PATH/elastic.sh $CLOUD create-index $x-$d $ES_PATH/config/$x.json
         done
    else
         flag=false
         for x in ${NAME[@]}
         do
            if [ $x = $index ];then
                flag=true
            fi
         done

         if [ $flag = true ]; then
             $ES_PATH/elastic.sh $CLOUD create-index $index-$d $ES_PATH/config/$index.json
             echo "Create Index $index-$d"
             else
             echo "Invalid Index [ $index-$d ]"
             exit 1
         fi
    fi
}

del_month_index() {

    if [ x"$date" = x ]; then
        begin=$(date +%s -d '2 month ago')
        d=$(date +%Y.%m -d "@$begin")
        else
        if [ ${date%.*} -ge 2018 ];then
            d=$date
            else
            index=$2
            begin=$(date +%s -d '2 month ago')
            d=$(date +%Y.%m -d "@$begin")
        fi
    fi

    if [ x"$index" = x ]; then
         for x in ${NAME[@]}
         do
            echo "Delete Index [ $x-$d ]"
            $ES_PATH/elastic.sh $CLOUD delete-index  $x-$d
         done
    else
         flag=false
         for x in ${NAME[@]}
         do
            if [ $x = $index ];then
                flag=true
            fi
         done

         if [ $flag = true ]; then
             $ES_PATH/elastic.sh $CLOUD delete-index  $index-$d
             echo "Create Index $index-$d"
             else
             echo "Invalid Index [ $index-$d ]"
             exit 1
         fi
    fi
}

case $option in
    create)
        add_month_index
       ;;
    delete)
        del_month_index
       ;;
    *)
        add_month_index
        del_month_index
       ;;
esac
exit 0
