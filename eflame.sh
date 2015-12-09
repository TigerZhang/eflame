#!/usr/bin/env bash
# Copyright yunba.io 2015
#
# tool for launching eflame2
#

#BEAMPROCS=`ps ax | grep -v grep | grep beam | grep setcookie`
#LINECOUNT=`echo $BEAMPROCS | wc -l`

declare -i seconds=10

function search_running_beams() {
    TEMPFILE=`mktemp`

    #for PROC in `ps ax | grep -v grep | grep beam | grep setcookie`
    ps -ef | grep -v grep | grep beam | grep setcookie | while read PROC;
    do
        COOKIE=`echo ${PROC} | sed 's/.*-setcookie \([a-zA-Z0-9]*\).*/\1/'`
        NodeName=`echo ${PROC} | grep "\-name" | sed 's/.*-name \([a-zA-Z0-9.@]*\).* .*/\1/'`
        NodeSName=`echo ${PROC} | grep "\-sname" | sed 's/.*-sname \([a-zA-Z0-9.@]*\).*/\1/'`
        # echo "*****$COOKIE, $NodeName, $NodeSName ****"
        if [ -z "$NodeName" ]; then
            NodeName=${NodeSName}@`hostname`
        fi
        echo "${NodeName} ${COOKIE}"
    done > $TEMPFILE

    echo $TEMPFILE
    cat $TEMPFILE
    LINECOUNT=`wc -l $TEMPFILE | awk '{print $1}'`
    if [ "${LINECOUNT}" == 1 ]; then
        node_name=`cat $TEMPFILE | cut -d " " -f 1`
        cookie=`cat $TEMPFILE | cut -d " " -f 2`
    else
        echo "found running beams(name, cookie):"
        cat $TEMPFILE
        echo
    fi
}

function show_help() {
    echo "$0 [-n <node_name>] [-c <cookie>] [-s <seconds>]"
}

function get_opts() {
    # A POSIX variable
    OPTIND=1         # Reset in case getopts has been used previously in the shell.

    # Initialize our own variables:
    node_name=""
    cookie=""

    while getopts "h?vn:c:s:" opt; do
#        echo "opt: $opt"
#        echo "OPTARGS: $OPTARG"
        case "$opt" in
        h|\?)
            show_help
            exit 0
            ;;
        v)  verbose=1
            ;;
        n)  node_name=$OPTARG
            ;;
        c)  cookie=$OPTARG
            ;;
        s)  seconds=$OPTARG
            ;;
        esac
    done

    shift $((OPTIND-1))

    [ "$1" = "--" ] && shift

    echo "node_name: ${node_name} cookie: ${cookie} seconds: ${seconds}"
}

function do_eflame() {
    rm *.svg
    echo "eflame launch"
    escript eflame_launch.erl ${node_name} ${cookie} ${seconds}

#    rm $TEMPFILE

    TIMESTAMP=`date +%F-%H-%M`
    OUTPUT=${TIMESTAMP}-${node_name}.svg
    OUTPUT_NO_SLEEP=${TIMESTAMP}-no-sleep-${node_name}.svg

    # rm ${OUTPUT}
    # rm ${OUTPUT_NO_SLEEP}

    echo "generate output.svg"
    cat /tmp/ef.test.0.out | ./flamegraph.pl > ${OUTPUT}
    echo "generate output-no-sleep.svg"
    grep -v 'SLEEP' /tmp/ef.test.0.out | ./flamegraph.pl > ${OUTPUT_NO_SLEEP}
    # echo "open output.svg"
    # open ${OUTPUT}
    # echo "open output-no-sleep.svg"
    # open ${OUTPUT_NO_SLEEP}
    if [ -x ./post_eflame.sh ]; then ./post_eflame.sh ${OUTPUT} ${OUTPUT_NO_SLEEP}; fi
}

# main

get_opts $*

if [ -z ${node_name} ] && [ -z ${cookie} ]; then
    search_running_beams
fi

if [ -z ${node_name} ] || [ -z ${cookie} ]; then
    show_help
else
    do_eflame
fi
