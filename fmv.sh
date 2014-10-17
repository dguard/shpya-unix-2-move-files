#!/usr/bin/env bash

DIR_FOR_FIND=$1
DIR_TO_MOVE=$2
CURRENT_COMMAND=$3
FILE_EXTENSION=$4

# allowed commands
COMMANDS="pdf
picture
odp
ext
"

# run without params
if [[ ${1} == ""  ]] || [[ ${2} == ""  ]] || [[ ${3} == "" ]]
then
     echo "Формат команды: директория назначение тип_перемещения($(echo -ne ${COMMANDS} | sed 's/ /\|/g')) [extension]"
     echo "Пример: ./fmv.sh ~/Загрузки ~/Загрузки/Documents pdf"
     exit
fi

# run only allowed commands
if [[ ${COMMANDS} != *${CURRENT_COMMAND}* ]]
then
     echo -en "Доступны типы перемещения: "
     for COMMAND in ${COMMANDS}
        do
        echo -en ${COMMAND}" "
        done
     echo
     exit
fi

# if not passed extension
if [[ ${CURRENT_COMMAND} == "ext" ]] && [[ ${FILE_EXTENSION} == "" ]]
then
     echo "Не передано расширение для поиска"
     echo "Пример: ./fmv.sh ~/Загрузки ~/Загрузки/Music ext mp3"
     exit
fi

function move_files {
   # add "{{new_line}}" after each file name
   NEW_LINE="{{new_line}}"

   files=$(find ${1} -regextype posix-extended -regex $3 -printf "%p${NEW_LINE}")

   # create the directory if not exists
   mkdir -p $2
   # escape all spaces and replace all "{{new_line}}" to space to pass it xargs
   echo ${files} | sed -e 's| |\\\ |g' | sed -e "s|${NEW_LINE}| |g" | xargs mv -t $2 2>/dev/null

   if [[ "${files}" != "" ]]
   then
        echo "Перемещены файлы:"
        echo ${files} | sed -e "s|${NEW_LINE}|\n|g"
        echo "Всего перемещено файлов: " $(echo ${files} | grep -o "${NEW_LINE}" | wc -l )
   else
        echo "Ни один файл не был перемещен"
   fi
}

function move_files_pdf {
    move_files ${1} ${2} "^.*\.pdf$"
}

function move_files_opd {
    move_files ${1} ${2} "^.*\.odp$"
}

function move_files_picture {
    move_files ${1} ${2} "^.*\.(jpg|png|jpeg|bmp|gif)$"
}

function move_files_ext {
    move_files ${1} ${2} "^.*\.(${FILE_EXTENSION})$"
}

move_files_${CURRENT_COMMAND} ${DIR_FOR_FIND} ${DIR_TO_MOVE}