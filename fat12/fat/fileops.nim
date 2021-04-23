import headers

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

proc entryType(attr: uint8): uint8 =
  if (attr and 0x10) == 0x10:
    return headers.DIR_ENTRY
  elif (attr and 0x20) == 0x20:
    return headers.FILE_ENTRY
  else:
    return 0

proc parseDir*(fs: var FatDisk, dirOffset: uint32, dirPath: string) =
  var offset: uint32 = dirOffset
