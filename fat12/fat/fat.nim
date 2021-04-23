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
  var buf: pointer = addr bytes

  for i in countup(1, FAT_SIZE div 3 - 1):
    let count = readBuffer(fs.disk_img, buf, 3)

    fs.fat[i - 1] = (bytes[0] and 0xFF) or ((bytes[1] and 0xF) shl 8)
    fs.fat[i] = ((bytes[2] and 0xFF) shl 4) or ((bytes[1] and 0xF0) shr 4)

proc findFiles*(fs: var FatDisk) =
  readFS(fs)
  parseDir(fs, ROOT_POS, "/")
