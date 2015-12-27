#/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
INDEX=/tmp/duplicates-idx-$$.log
DUPS=/tmp/duplicates-dup-$$.log
MD5S=/tmp/duplicates-md5-$$.log
FOUND=/tmp/duplicates-rst-$$.log
VERSION=0.0.1

#
# Check the MD5 checksum of each found file
#
function check() {
   echo "start checking ..."
   for FILE in $(find -type f); do
      echo -ne "checking $FILE ...\033[0K\r"
      MD5=$(md5sum $FILE | cut -f1 -d' ')
      echo "$MD5" >> $DUPS
      echo "$MD5 $FILE" >> $INDEX
   done
   echo "finished checking."
}

#
# Filter all the MD5 who have more than 1 result
#
function dups() {
   echo "starting to find duplicates ...";
   sort $DUPS | uniq -c | egrep -v "\s+1" >> $MD5S
   echo "finished finding duplicates."
}

#
# Find filenames of duplicated MD5s
#
function proc() {
   local RST
   echo "starting to find filenames ..."
   for MD5 in $(cat $MD5S); do
      MD5=$(echo $MD5 | sed 's/\s\+[0-9]\s//')
      echo -ne "checking MD5 $MD5 on index ($INDEX) ...\033[0K\r"
      RST=$(grep $MD5 $INDEX | cut -f2 -d' ')
      echo "------------------------------------\n" >> $FOUND
      echo $RST >> $FOUND
   done
   echo -e "\nfinished to find filenames."
}

#
# Analyse the results
#
function analyse() {
   if [ -s $FOUND ]; then
      echo "encontrados:"
      cat $FOUND
      echo "results in $FOUND."
   else
      echo "no duplicated files found."
   fi
}

#
# Print header
#
function header() {
   echo "Duplicated $VERSION"
   echo "Find duplicated files, based on the MD5 sum"
   echo "https://github.com/taq/duplicates.sh"
   echo "Licensed under GPL v2.0"
   echo "-------------------------------------------"
   echo "index on $INDEX"
   echo "found files on $FOUND"
}

#
# Run program
#
function main() {
   header
   check
   dups
   proc
   analyse
}
main "$@"
