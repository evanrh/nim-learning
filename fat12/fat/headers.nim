const NUM_SECTORS* = 2880
const SECTOR_SIZE* = 512
const DISK_SIZE* = NUM_SECTORS * SECTOR_SIZE
const FAT1_POS* = 1 * SECTOR_SIZE
const FAT_SIZE* = SECTOR_SIZE * 9
const ROOT_SECTOR* = 19
const ROOT_SECTOR_END* = 32
const ROOT_POS* = 19 * SECTOR_SIZE
const START_SECTOR* = 31
const DATA_START* = 31 * SECTOR_SIZE

const NUM_DIR_ENTRIES = 16
const DIR_NUM_BYTES = 32
const FILE_ENTRY = 1
const DIR_ENTRY = 2

type
  FatDisk* = ref FatDiskObj
  FatDiskObj = object
    output_dir*: string
    disk_img*: File
    fat*: array[FAT_SIZE div 3, uint32]
    disk*: array[DISK_SIZE, uint8]