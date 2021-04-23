import headers
import strutils
import strformat
import os

type
  Offsets = enum
    FName = 0,
    Ext = 8,
    Attributes = 11,
    First_cluster = 26,
    File_size = 28

  DirEntry = object
    first_cluster: uint16
    fname: string
    ext: string
    size: uint32
    deleted: bool

var fileCount: uint = 0

proc sector_start(cluster: uint16): uint32 =
  return (START_SECTOR + cluster) * SECTOR_SIZE

proc entryType(attr: uint8): uint8 =
  if (attr and 0x10) == 0x10:
    return headers.DIR_ENTRY
  elif (attr and 0x20) == 0x20:
    return headers.FILE_ENTRY
  else:
    return 0

proc isSubDir(ent: DirEntry): bool =
  const currDir: string = "."
  const parentDir: string = ".."
  
  return not ((ent.fname == currDir) or (ent.fname == parentDir))

proc getFilename(ent: var DirEntry, fname: string) =
  ent.fname = fname

  if cast[uint8](fname[0]) == 0xE5:
    ent.fname[0] = '_'
    ent.deleted = true
  else:
    ent.deleted = false

  ent.fname = ent.fname.strip()

proc printFile(ent: DirEntry, path: string) =
  if ent.deleted:
    echo &"FILE\tDELETED\t{path}{ent.fname}.{ent.ext}\t{ent.size}"
  else:
    echo &"FILE\tNORMAL\t{path}{ent.fname}.{ent.ext}\t{ent.size}"

proc writeFile(fs: FatDisk, ent: DirEntry) =
  var
    size: uint = ent.size
    cluster: uint16 = ent.first_cluster
    output: File
  let
    cwd: string = getCurrentDir()

  setCurrentDir(fs.output_dir)

  discard open(output, fmt"file{fileCount}.{ent.ext}", fmWrite)
  fileCount += 1

  if not ent.deleted:
    while size >= cast[uint](SECTOR_SIZE):
      let
        offset: uint = sectorStart(cluster)
      var
        writeSize: uint = SECTOR_SIZE

      if SECTOR_SIZE > size:
        writeSize = size

      let str: string = cast[string](fs.disk[offset .. (offset + writeSize - 1)])

      write(output, str)
      size -= SECTOR_SIZE

  setCurrentDir(cwd)
  close(output)

proc parseDir*(fs: var FatDisk, dirOffset: uint32, dirPath: string) =
  var offset: uint32 = dirOffset

  while fs.disk[offset] != 0x0:
    var ent: DirEntry
    let
      fname: string = cast[string](fs.disk[offset..(offset+FNAME_BYTES-1)])
      attr: uint8 = cast[uint8](fs.disk[offset + ord(Attributes)])
    getFilename(ent, fname)
    ent.ext = cast[string](fs.disk[(offset + ord(Ext)) .. (offset + ord(Ext) + EXT_BYTES - 1)])

    ent.first_cluster = cast[uint8](fs.disk[offset + ord(First_cluster)])
    ent.first_cluster = ent.first_cluster or (cast[uint16](fs.disk[offset + ord(First_cluster) + 1]) shl 8)

    for i in countup(0, FILE_SIZE_BYTES - 1):
      let fullOffset = offset + ord(File_size) + cast[uint32](i)
      ent.size = ent.size or (cast[uint32](fs.disk[fullOffset]) and 0xFF) shl (8 * i)

    if entryType(attr) == headers.DIR_ENTRY:
      let path = dirPath & ent.fname & "/"
      if isSubDir(ent):
        let start = sectorStart(ent.first_cluster)
        parseDir(fs, start, path)
    else:
      printFile(ent, dirPath)
      writeFile(fs, ent)

    offset += DIR_NUM_BYTES
