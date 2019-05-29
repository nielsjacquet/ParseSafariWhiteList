#!/bin/bash

##cosmetic functions and Variables

##Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'
BLUE='\033[0;34m'

##Break function for readabillity
function BR {
  echo "  "
}

##DoubleBreak function for readabillity
function DBR {
  echo " "
  echo " "
}

##paths:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
##Variables
IFS=";"

##ask user for filename
echo "Type in the output filename"
read SRname
echo "Drag and drop the CSV file"
read CSVfile
echo CSVfile: $CSVfile
##parse output folder from scv file
CSVDir=$( dirname "${CSVfile}")
echo CSVDir: $CSVDir
CSVfile=${CSVfile%?}
SRfile="$CSVDir/$SRname""_SafariWhitelistProfile.mobileconfig"

echo $SRfile

##Genereate UUID's
UUID1Upper=$(uuidgen)
UUID2Upper=$(uuidgen)
UUID3Upper=$(uuidgen)

UUID1=$(echo $UUID1Upper | tr '[:upper:]' '[:lower:]')
UUID2=$(echo $UUID2Upper | tr '[:upper:]' '[:lower:]')
UUID3=$(echo $UUID3Upper | tr '[:upper:]' '[:lower:]')

echo $UUID1
echo $UUID2

##put it in variable
function parse {
  while read VAL title siteURL justavalue
   do
    echo VAL: $VAL
    echo title: $title
    echo URL: $siteURL

  if [[ $VAL = "REQ" ]]
    then
      echo -e "<dict>" >> $SRfile
      echo -e "<key>Title</key>" >> $SRfile
      echo -e "<string>$title</string>" >> $SRfile
      echo -e "<key>URL</key>" >> $SRfile
      echo -e "<string>$siteURL</string>" >> $SRfile
      echo -e "</dict>" >> $SRfile
   fi
  echo ----------------------------------------------------------------------------------------
  done < $CSVfile
}

function printHeader {
  echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple Inc//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">" >> $SRfile
  echo -e "<dict>\n<key>PayloadVersion</key>\n<integer>1</integer>\n<key>PayloadUUID</key>\n<string>Ignored</string>\n<key>PayloadType</key>\n<string>Configuration</string>\n<key>PayloadIdentifier</key>\n<string>Ignored</string>\n<key>PayloadContent</key>\n<array>\n<dict>\n<key>AutoFilterEnabled</key>\n<false/>\n<key>FilterBrowsers</key>\n<true/>\n<key>FilterSockets</key>\n<true/>\n<key>FilterType</key>\n<string>BuiltIn</string>\n<key>PayloadDescription</key>\n<string>Configures content filtering settings</string>\n<key>PayloadDisplayName</key>\n<string>Web Content Filter</string>\n<key>PayloadIdentifier</key>\n<string>com.apple.webcontent-filter.btp.$SRname</string>\n<key>PayloadType</key>\n<string>com.apple.webcontent-filter</string>\n<key>PayloadUUID</key>\n<string>$UUID1</string>\n<key>PayloadVersion</key>\n<integer>1</integer>\n<key>WhitelistedBookmarks</key>\n<array>" >> $SRfile
}

function printFooter {
  echo -e "</array>\n</dict>\n</array>\n</dict>\n</plist>" >> $SRfile
}
printHeader
parse
printFooter
