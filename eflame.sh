#!/usr/bin/env bash
# Copyright yunba.io 2015

BEAMPROCS=`ps ax | grep -v grep | grep beam | grep setcookie`
LINECOUNT=`echo $BEAMPROCS | wc -l`

declare -a NODENAMES
declare -a COOKIES

i=0
#for PROC in `ps ax | grep -v grep | grep beam | grep setcookie`
while read $PROC;
do
    COOKIES[i]=`echo ${BEAMPROCS} | sed 's/.*-setcookie \([a-zA-Z0-9]*\).*/\1/'`
    NODENAMES[i]=`echo ${BEAMPROCS} | sed 's/.*-name \([a-zA-Z0-9.@]*\).*/\1/'`
    i=$((i+1))
done < ${

echo $i
echo $COOKIES
echo $NODENAMES

exit 0

if [ $LINECOUNT -eq 1 ]; then
    COOKIE=`echo ${BEAMPROCS} | sed 's/.*-setcookie \([a-zA-Z0-9]*\).*/\1/'`
fi

echo "eflame launch"
escript eflame_launch.erl plumtree3@127.0.0.1 plumtree 5

echo "generate output.svg"
cat /tmp/ef.test.0.out | ./flamegraph.riak-color.pl > output.svg
echo "generate output-no-sleep.svg"
grep -v 'SLEEP' /tmp/ef.test.0.out | ./flamegraph.riak-color.pl > output-no-sleep.svg
echo "open output.svg"
open output.svg
echo "open output-no-sleep.svg"
open output-no-sleep.svg
