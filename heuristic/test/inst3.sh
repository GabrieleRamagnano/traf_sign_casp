#!/bin/bash

declare pack_test="theory_delta"
declare prefix="tail"
declare tail="/${prefix}0.sh"

function move
{
    cp -r "./${pack_test}/"*.sh .
}

function delete
{
    rm -r "./${prefix}"*.sh
}

function execute
{
    bash "./${tail}" test_start "${pack_test}"
}

"$@"

