# Main driver of FAT12 Program

import os
import fat/fat

proc main() =
  let args = commandLineParams()
  if args.len() < 2:
    stderr.writeLine("Not enough args!")
    stderr.flushFile();
    return 

  var fs: FatDisk
  new(fs)

  let ret = fs.init(args[0], args[1])
  if not ret:
    stderr.writeLine("File or dir could not be opened!")
    stderr.flushFile();
    return
  fs.findFiles()
  fs.close()

main()
