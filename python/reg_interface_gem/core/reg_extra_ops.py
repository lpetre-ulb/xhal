import os
from ctypes import *

lib = CDLL("librpcman.so")
rReg = lib.getReg
rReg.restype = c_uint
rReg.argtypes=[c_uint]
wReg = lib.putReg
wReg.argtypes=[c_uint,c_uint]
rpc_connect = lib.init
rpc_connect.argtypes = [c_char_p]
rpc_connect.restype = c_uint
rpc_disconnect = lib.deinit
rpc_disconnect.argtypes = [ ]
rpc_disconnect.restype = c_uint

rBlock = lib.getBlock
rBlock.restype = c_uint
rBlock.argtypes=[c_uint,POINTER(c_uint32)]

repeatedRead = lib.repeatedRegRead
repeatedRead.argtypes = [c_char_p, c_uint, c_bool ]
repeatedRead.restype = c_uint

getRPCTTCmain = lib.getmonTTCmain
getRPCTTCmain.argtypes = [POINTER(c_uint32)]
getRPCTTCmain.restype = c_uint

getRPCTRIGGERmain = lib.getmonTRIGGERmain
getRPCTRIGGERmain.argtypes = [POINTER(c_uint32), c_uint32]
getRPCTRIGGERmain.restype = c_uint

getRPCTRIGGEROHmain = lib.getmonTRIGGEROHmain
getRPCTRIGGEROHmain.argtypes = [POINTER(c_uint32), c_uint32]
getRPCTRIGGEROHmain.restype = c_uint

getRPCDAQmain = lib.getmonDAQmain
getRPCDAQmain.argtypes = [POINTER(c_uint32)]
getRPCDAQmain.restype = c_uint

getRPCDAQOHmain = lib.getmonDAQOHmain
getRPCDAQOHmain.argtypes = [POINTER(c_uint32), c_uint32]
getRPCDAQOHmain.restype = c_uint

getRPCOHmain = lib.getmonOHmain
getRPCOHmain.argtypes = [POINTER(c_uint32), c_uint32]
getRPCOHmain.restype = c_uint

rList = lib.getList
rList.restype = c_uint
rList.argtypes=[POINTER(c_uint32),POINTER(c_uint32)]

scanGBTPhases = lib.scanGBTPhases
scanGBTPhases.restype = c_uint
scanGBTPhases.argtype = [POINTER(c_uint), c_uint, c_uint, c_uint, c_uint, c_uint, c_uint]

update_atdb = lib.update_atdb
update_atdb.argtypes = [c_char_p]
update_atdb.restype = c_uint

writeGBTConfig = lib.writeGBTConfig
writeGBTConfig.restype = c_uint
writeGBTConfig.argtype = [c_uint, c_uint, c_uint, POINTER(c_char)]

writeGBTPhase = lib.writeGBTPhase
writeGBTPhase.restype = c_uint
writeGBTPhase.argtype = [c_uint, c_uint, c_char]
