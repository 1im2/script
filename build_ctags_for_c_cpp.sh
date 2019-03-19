#!/bin/bash


TAGS_LIST_FILE=".tags_file_list"
find . -type f -iname "*.c"   >   ${TAGS_LIST_FILE}
find . -type f -iname "*.cpp" >>  ${TAGS_LIST_FILE}
find . -type f -iname "*.h"   >>  ${TAGS_LIST_FILE}
find . -type f -iname "*.hpp" >>  ${TAGS_LIST_FILE}


#ctags -V --c++-kinds=+p --fields=+iaS --extra=+q -L ${TAGS_LIST_FILE}
ctags --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -L ${TAGS_LIST_FILE}


rm -f ${TAGS_LIST_FILE}
