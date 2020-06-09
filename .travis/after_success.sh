#!/bin/bash

source .travis/common.sh
set -e

# Close the after_success fold travis has created already.
travis_fold end after_success

ANACONDA_TOKEN="Qu-54f16daa-a80a-4df4-abd8-a8ec53676b69"
ANACONDA_USER="Quicklogic-Corp"

if [[ $UPLOAD == "no-upload" ]]; then
    echo "Job without upload..."
else
    echo "Job with Conda upload..."

    $SPACER

    start_section "package.upload" "${GREEN}Package uploading...${NC}"
    if [[ -z $CUSTOM_LABEL ]]; then
        anaconda -t $ANACONDA_TOKEN upload --user $ANACONDA_USER --label main $CONDA_OUT
    else
        anaconda -t $ANACONDA_TOKEN upload --user $ANACONDA_USER --label $CUSTOM_LABEL $CONDA_OUT
    fi
    end_section "package.upload"

    $SPACER
fi

start_section "success.tail" "${GREEN}Success output...${NC}"
echo "Log is $(wc -l /tmp/output.log) lines long."
echo "Displaying last 1000 lines"
echo
tail -n 1000 /tmp/output.log
end_section "success.tail"
