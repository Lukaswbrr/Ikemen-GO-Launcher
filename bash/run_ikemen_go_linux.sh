#!/bin/bash
open() {
    cd ~
    cd "$1"
    ./"$2"
}

"$@"
