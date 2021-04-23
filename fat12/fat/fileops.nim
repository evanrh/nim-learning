import headers

proc parseDir*(fs: var FatDisk, dirOffset: uint32, dirPath: string) =
  echo "In parse dir"
