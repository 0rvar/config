#!/usr/bin/env fish
set -l years (find . | awk -F"./" '{print $2}' | grep -Eo "^\d{4}" | sort | uniq)
for year in $years
  echo "Backing up ./$year* to Storage/Photos/Camera\ Uploads/$year/"
  rsync -vzP --itemize-changes ./$year* hemulen:"/volume1/Storage/Photos/Camera\ Uploads/$year/"
end

echo "To clean up:"
for year in $years
  echo "rm $year*"
end