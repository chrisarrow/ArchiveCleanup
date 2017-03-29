#!/bin/sh

#  ArchiveCleanup.sh
#
#  The purpose of this shell script is to copy only the relevant files for a customer archive from
#  an Elsevier job folder and clean them up to prepare them to be burnt to a disk.
#
#  Run ArchiveCleanup.sh in Terminal then drag the folder to be copied into the terminal window after the prompt.
#  After the path is copied to the window hit return to run.
#
#  Created by Chris Arrow on 7/1/16.
#  Updated 3/29/17
#


#  This tells bash that it should exit the script if any statement returns a non-true return value. The benefit of using -e is that it prevents errors snowballing into serious issues when they could have been caught earlier. Again, for readability you may want to use set -o errexit.
set -e

# I learned this here: http://superuser.com/questions/222395/unix-copy-a-directory

#  Sets location of the BurnFolder "variable="Some String"
burnFolder="/Users/chrisa/Desktop/ToBurn"

#  this chunk of text prints a question asking what the source for copying should be.
echo "----------------------------------------------------"
echo "         Welcome to the Elsevier Archiver           "
echo " Drag the job folder you want to burn to this window"
echo "                  then hit RETURN                   "
echo "----------------------------------------------------"

#  Then the "read" command asks the user to enther the path to be copied and saves it to variable sourcePath
read jobPathInput

#  Learned from here http://stackoverflow.com/questions/23162299/how-to-get-the-last-part-of-dirname-in-bash
#  Creates Job Folder to put files in burnFolder
jobFolder="$(basename "$jobPathInput")"

#  Learned this here http://stackoverflow.com/questions/4906579/how-to-use-bash-to-create-a-folder-if-it-doesnt-already-exist
#  This creates the jobFolder in the burnFolder
mkdir -p "$burnFolder"/"$jobFolder"

#  Learned from here http://unix.stackexchange.com/questions/138634/shortest-way-to-extract-last-3-characters-of-base-minus-suffix-filename
#  Extracts last 13 characters from the folder name (this will be the 13 digit ISBN)
isbn="${jobFolder#"${jobFolder%?????????????}"}"
echo ISBN: "$isbn"

#  "cp -r" copies stuff in the format "cp-r dir1 dir2" I put sourcePath in quotes because of these damn spaces.
#  $burnFolder is a variable for copy destination.
#cp -r "$jobPathInput" "$burnFolder"/"$jobFolder"

#  learned directory check here http://stackoverflow.com/questions/59838/check-if-a-directory-exists-in-a-shell-script
if [ -d "$jobPathInput"/Art-"$isbn" ]
then
    #  This grabs the Art Folder regardless of ISBN
    cp -r "$jobPathInput"/Art-"$isbn" "$burnFolder"/"$jobFolder"
    echo "Art copied"
else
    #  Alert for missing folder
    echo "WARNING: No Art Folder"
fi

#  Gets Fonts
#if [ -d "$jobPathInput"/Fonts-* ]
#then
#    cp -r "$jobPathInput"/Fonts-* "$burnFolder"/"$jobFolder"
#else
#    echo "WARNING: No Fonts Folder"
#fi

#  Copies zipped fonts file, extracts it instead of Fonts folder (if .zip exists)
if [ -f "$jobPathInput"/Fonts-"$isbn".zip ]
then
    #  This unzips the fonts file if it exists in the destination job folder in the burn folder
    echo "Zipped Fonts Found, Extracting"
    #  Found here http://askubuntu.com/questions/86849/how-to-unzip-a-zip-file-from-the-terminal
    #unzip "$jobPathInput"/Fonts-*.zip -d "$burnFolder"/"$jobFolder"
    #  CANT do the above command line and maintain mac metadata, instead have to run the command line equivalent of double clicking: "ditto" http://xahlee.info/UnixResource_dir/macosx.html
    ditto -xk "$jobPathInput"/Fonts-"$isbn".zip "$burnFolder"/"$jobFolder"
elif [ -d "$jobPathInput"/Fonts-"$isbn" ]
then
        cp -r "$jobPathInput"/Fonts-"$isbn" "$burnFolder"/"$jobFolder"
        echo "Fonts copied"
else
        echo "WARNING: No Fonts Folder"
fi

#  Gets Global Art
if [ -d "$jobPathInput"/Global-"$isbn" ]
then
    cp -r "$jobPathInput"/Global-"$isbn" "$burnFolder"/"$jobFolder"
    echo "Global copied"
else
    echo "WARNING: No Global Folder"
fi

#  Gets InDesign
if [ -d "$jobPathInput"/InDesign-"$isbn" ]
then
    cp -r "$jobPathInput"/InDesign-"$isbn" "$burnFolder"/"$jobFolder"
    echo "InDesign copied"
else
    echo "WARNING: No InDesign Folder"
fi

#Gets PDF
if [ -d "$jobPathInput"/PDF-"$isbn" ]
then
    cp -r "$jobPathInput"/PDF-"$isbn" "$burnFolder"/"$jobFolder"
    echo "PDF copied"
else
    echo "WARNING: No PDF Folder"
fi

#Gets Word
if [ -d "$jobPathInput"/Word-"$isbn" ]
then
    cp -r "$jobPathInput"/Word-"$isbn" "$burnFolder"/"$jobFolder"
    echo "Word Copied"
else
    echo "WARNING: No Word Folder"
fi

#  The last line echos the sourcePath and says its been copied.. but who knows if it has been or not???
echo "$jobFolder" "has been copied to the Burn Folder"


#  copied from http://stackoverflow.com/questions/2016844/bash-recursively-remove-files

#  all this stuff removes .DS_Store files and any other "._" crap. No idea what "-print0 | xargs -0 rm -rf" means
#  I made sure it is removing them from the copied folder because I'm not dumb.

find "$burnFolder"/"$jobFolder"/Art-"$isbn" -name ".DS_Store" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/Global-"$isbn" -name ".DS_Store" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/InDesign-"$isbn" -name ".DS_Store" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/PDF-"$isbn" -name ".DS_Store" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/Word-"$isbn" -name ".DS_Store" -print0 | xargs -0 rm -rf

find "$burnFolder"/"$jobFolder"/Art-"$isbn" -name "._*" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/Global-"$isbn" -name "._*" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/InDesign-"$isbn" -name "._*" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/PDF-"$isbn" -name "._*" -print0 | xargs -0 rm -rf
find "$burnFolder"/"$jobFolder"/Word-"$isbn" -name "._*" -print0 | xargs -0 rm -rf

echo ".DS_Store and any hidden ._ files removed"

#  Here im seaching and deleting unwanted art folders
#  found here: http://unix.stackexchange.com/questions/89925/how-to-delete-directories-based-on-find-output

#  Finds and deletes "mathML". 2> /dev/null is to get rid of the error message.
find "$burnFolder"/"$jobFolder"/Art-"$isbn" -name "mathML" -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/Global-"$isbn" -name "mathML" -print0 | xargs -0 rm -r

#  Finds and deletes "web_art".
find "$burnFolder"/"$jobFolder"/Art-"$isbn" -name "web_art" -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/Global-"$isbn" -name "web_art" -print0 | xargs -0 rm -r

#  Finds and deletes "old".
find "$burnFolder"/"$jobFolder"/Art-"$isbn" -name "*old*" -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/Global-"$isbn" -name "*old*" -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/InDesign-"$isbn" -name "*old*" -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/PDF-"$isbn" -name "*old*" -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/Word-"$isbn" -name "*old*" -print0 | xargs -0 rm -r

#  Finds and deletes "DNU".
find "$burnFolder"/"$jobFolder"/Art-"$isbn" -name *"DNU"* -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/Global-"$isbn" -name *"DNU"* -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/InDesign-"$isbn" -name *"DNU"* -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/PDF-"$isbn" -name *"DNU"* -print0 | xargs -0 rm -r
find "$burnFolder"/"$jobFolder"/Word-"$isbn" -name *"DNU"* -print0 | xargs -0 rm -r

echo "MathML, web_art, old, and DNU removed"

#  Finds and deletes empty directories
#  found here: http://unix.stackexchange.com/questions/8430/how-to-remove-all-empty-directories-in-a-subtree

find "$burnFolder"/"$jobFolder"/Art-"$isbn" -type d -empty -delete
find "$burnFolder"/"$jobFolder"/Global-"$isbn" -type d -empty -delete
find "$burnFolder"/"$jobFolder"/InDesign-"$isbn" -type d -empty -delete
find "$burnFolder"/"$jobFolder"/PDF-"$isbn" -type d -empty -delete
find "$burnFolder"/"$jobFolder"/Word-"$isbn" -type d -empty -delete
echo "Empty folders removed"

echo "----------------------------------------------------"
echo "cleanup finished"

#  Learned from here
#  http://askubuntu.com/questions/1224/how-do-i-determine-the-total-size-of-a-directory-folder-from-the-command-line
#  Outputs disk usage of a directory

du -hs "$burnFolder"/"$jobFolder"




