import headers
import fileops

export headers.FatDisk

proc initMem(fs: var FatDisk) =
  setFilePos(fs.disk_img, 0, fspSet)
  discard readBytes(fs.disk_img, fs.disk, 0, DISK_SIZE)

proc init*(fs: var FatDisk, img_file: string, out_dir: string): bool =
  let ret = open(fs.disk_img, img_file, fmRead)

  if ret == false:
    return false

  result = true
  fs.output_dir = out_dir
  fs.initMem()

proc close*(fs: var FatDisk) =
  close(fs.disk_img)

proc readFS(fs: var FatDisk) =
  setFilePos(fs.disk_img, FAT1_POS, fspSet)
  var bytes: array[3, uint16]
  var buf: array[3, uint8]

  for i in countup(0, FAT_SIZE div 6 - 1):
    let count = readBytes(fs.disk_img, buf, 0, 3)

    bytes[0] = buf[0]
    bytes[1] = buf[1]
    bytes[2] = buf[2]
    fs.fat[2 * i] = (bytes[0] and 0xFF) or ((bytes[1] and 0xF) shl 8)
    fs.fat[(2 * i) + 1] = ((bytes[2] and 0xFF) shl 4) or ((bytes[1] and 0xF0) shr 4)

proc findFiles*(fs: var FatDisk) =
  readFS(fs)
  parseDir(fs, ROOT_POS, "/")
