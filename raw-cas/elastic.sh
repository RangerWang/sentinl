#!/bin/bash -x

cloud=${1:-local}
cmd=$2

case $cloud in
    aws)
        cloud=52.39.115.73:9200

        # qa
        #cloud=52.39.115.73:9200

        ;;
    elastic)
        #cloud=http://bob.he:dev1cevm@5a60bf34178c71e154c18524405115bf.us-east-1.aws.found.io:9200
        cloud=http://emr:Y68d97!Bq@eba6a884170238618671dcb8209aeb31.us-west-2.aws.found.io:9200
        ;;

    test)
        cloud="http://54.151.20.170:9200"
        ;;

    test-2)
        cloud="http://elastic:1234qwer@54.183.132.174:9200"
        ;;

    *)
        cloud=127.0.0.1:9200
        ;;
esac

#curl -XDELETE search-st2-api-log-bbo2zdfzjf7xgj6jaonp3dt5gy.us-west-1.es.amazonaws.com:80/st2-api

case $cmd in
    get-index)
        curl -XGET "$cloud/$3?pretty"
        ;;
    purge-index)
        curl -XPOST "$cloud/$3/_optimize?only_expunge_deletes=true"
        ;;
    delete-index)
        curl -XDELETE "$cloud/$3"
        ;;
    delete-all-index)
        curl -XDELETE "$cloud/_all"
        ;;
    create-index)
        curl -H "Content-Type: application/json" -XPUT "$cloud/$3?pretty" -d @$4
        # elasticsearch 1.5.2
        #curl -XPOST "$cloud/$3" -d @$4
        ;;
    update-index)
        curl -XPUT "$cloud/$3/_settings?pretty" -d @$4
        ;;
    get-stats)
        curl -XGET "$cloud/_cluster/stats?human&pretty"
        ;;
    get-mapping)
        curl -XGET "$cloud/_mapping?pretty"
        ;;
    put-mapping)
        curl -XPUT "$cloud/$3/_mapping/$4?pretty" -d @$5
        ;;
    get-setting)
        curl -XGET "$cloud/_all/_settings?pretty"
        ;;
    set-alias)
        # $3: index
        # $4: index alias
        curl -XPUT "$cloud/$3/_alias/$4?pretty"
        ;;
    delete-alias)
        # $3: index
        # $4: index alias
        curl -XDELETE "$cloud/$3/_alias/$4?pretty"
        ;;
    cat-alias)
        curl -XGET "$cloud/_cat/aliases?v"
        ;;
    bulk)
        curl -XPOST "$cloud/_bulk?pretty" --data-binary @$3
        ;;
    backup-kibana)
        # npm install elasticdump -g
        elasticdump --input=$cloud/.kibana --output=kibana.json
        ;;
    restore-kibana)
        # npm install elasticdump -g
        elasticdump --input=kibana.json --output=$cloud/.kibana
        ;;
    *)
        echo "Usage:"
        echo "    elastic.sh cloud command param ..."
esac

