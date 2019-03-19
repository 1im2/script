#!/bin/bash

echo -e "\n\n\n\n    Search key(*.c*): $@\n\n"
find . -name "*.c*" -exec grep --color -n -H -i "$@" {} \
