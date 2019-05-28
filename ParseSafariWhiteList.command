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

SRfile="$CSVDir/$SRname""_SecurityRestrictions.mobileconfig"

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
  while read Key Type	Value Recommended_Value	Requested_Value Priority
   do
     if [[ -z $Requested_Value ]]
       then
        echo Requested Value not Available
        echo Original RV: $Requested_Value
        Requested_Value="$Recommended_Value"
        echo altered RV:  $Requested_Value
     fi

     echo Key:                $Key
     echo Type:               $Type
     #echo Value:              $Value
     echo Recommended_Value:  $Recommended_Value
     echo Requested_Value:    $Requested_Value
     #echo Priority:           $Priority

  if [[ $Type = "string" ]]
    then
      echo -e "<key>$Key</key>\n<$Type>$Requested_Value</$Type>" >> $SRfile
   fi

   if [[ $Type = "integer" ]]
    then
      echo -e "<key>$Key</key>\n<$Type>$Requested_Value</$Type>" >> $SRfile
   fi

   if [[ $Type = "real" ]]
    then
      echo -e "<key>$Key</key>\n<$Type>$Requested_Value</$Type>" >> $SRfile
   fi

   if [[ $Type = "boolean" ]]
    then
      echo -e "<key>$Key</key>" >> $SRfile
      echo "<$Requested_Value/>" | tr "[:upper:]" "[:lower:]" >> $SRfile
   fi

   if [[ $Key = "insertPasswordPolicy" ]]
    then
     passwordPolicy
   fi

   if [[ $Type = "array of strings" ]]
    then
     echo -e "<key>$Key</key>\n<array>\n$Requested_Value\n</array>" >> $SRfile
   fi

  echo ----------------------------------------------------------------------------------------
  done < $CSVfile
}
function printHeader {
  echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple Inc//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">" >> $SRfile
  echo -e "<dict>\n<key>PayloadContent</key>\n<array>\n<dict>\n<key>PayloadDescription</key>\n<string>Configures restrictions</string>\n<key>PayloadDisplayName</key>\n<string>Restrictions</string>\n<key>PayloadIdentifier</key>\n<string>com.apple.applicationaccess.$UUID1</string>\n<key>PayloadType</key>\n<string>com.apple.applicationaccess</string>\n<key>PayloadUUID</key>\n<string>$UUID1</string>\n<key>PayloadVersion</key>\n<integer>1</integer>" >> $SRfile
}
function printFooter {
  echo -e "</dict>\n</array>\n<key>PayloadDisplayName</key>\n<string>$SRname</string>\n<key>PayloadIdentifier</key>\n<string>$SRname</string>\n<key>PayloadRemovalDisallowed</key>\n<false/>\n<key>PayloadType</key>\n<string>Configuration</string>\n<key>PayloadUUID</key>\n<string>$UUID3</string>\n<key>PayloadVersion</key>\n<integer>1</integer>\n</dict>\n</plist>" >> $SRfile
}
function passwordPolicy {
  echo -e "</dict>" >> $SRfile
  echo -e "<dict>\n<key>PayloadDescription</key>\n<string>Configures passcode settings</string>\n<key>PayloadDisplayName</key>\n<string>Passcode</string>\n<key>PayloadIdentifier</key>\n<string>com.apple.applicationaccess.$SRname</string>\n<key>PayloadType</key>\n<string>com.apple.mobiledevice.passwordpolicy</string>\n<key>PayloadUUID</key>\n<string>$UUID2</string>\n<key>PayloadVersion</key>\n<integer>1</integer>" >> $SRfile
}
printHeader
parse
printFooter
