#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
cd $SCRIPT_DIR
JOBIDS=""
for a in x86_64 s390x ppc64le ; do
    sed 's|${ARCH}|'$a'|g;s|${GITHUB_TOKEN}|'${GITHUB_TOKEN}'|g;s|&|&amp;|g' beaker-job.xml > beaker-job-$a.xml
    JOBID=$(bkr job-submit beaker-job-$a.xml | sed -E "s|.*(J:[0-9]*).*|\1|")
    JOBIDS="$JOBIDS $JOBID"
    echo "${a} job submitted: $JOBID"
    rm beaker-job-$a.xml
done
for j in $JOBIDS ; do
    ; # bkr job-watch $j   # will block until finished
done
