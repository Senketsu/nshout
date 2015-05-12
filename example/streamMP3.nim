import os, strutils , nshout

const debug: bool = true

proc streamerInit*(shout: PShout): bool =

 if shout.setHost("127.0.0.1") > 0:
  echo("***Error Streamer: $1" %[$shout.getError()])

 if shout.setProtocol(SHOUT_PROTOCOL_HTTP) != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setPort(8000) != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setPassword("hackme") != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setMount("/main.mp3") != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setUser("source") != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setFormat(SHOUT_FORMAT_MP3) != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setGenre("radio") != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setName("nshout test") != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setDescription("nshout streaming test") != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 if shout.setAudioInfo(SHOUT_AI_BITRATE , "256") != SHOUTERR_SUCCESS:
  echo("***Error Streamer: $1" %[$shout.getError()])
  return

 echo("*Notice Streamer: Connection init successful")
 result = true


proc streamerStart*(shout: PShout, filePath: string)=
 var
  totRead,fileLen: int32
  ret,read: int
  fileBuffer: TaintedString = ""
  sendBuffer: cstring = ""
  bEOF: bool

 if shout.open() ==  SHOUTERR_SUCCESS:
  echo("*Notice Streamer: Connection to server successful")
  var
   songFile: File

  if songFile.open(filePath ,fmRead):
    totRead = 0
    fileBuffer = readAll(songFile)
    songFile.close()
    fileLen = int32(fileBuffer.len())
    if debug:
      echo "*Debug: FileSize:" & $fileLen
    while true:
     var sendArr: array[4096,char]
     for i in 0..4095:
      if totRead + i == fileLen:
       bEOF = true
       read = i
       break
      else:
       sendArr[i] = fileBuffer[totRead+i]
       read = i
     totRead = totRead + int32(read)
     if debug:
      echo ("*Debug: sending data: $1 / $2" % [$totRead,$fileLen])
     ret = send(shout, sendArr, csize(read))
     if (ret != SHOUTERR_SUCCESS):
      echo("***Error Streamer: $1" %[$shout.getError()])
      break
     sync(shout)
     if bEOF:
      echo "*Notice streamer: End of file. Streaming file successful"
      return

proc main () =
  var
    shout: PShout
    fpSong: string = ""

  if paramCount() < 1:
    echo "Usage: streamFile [filepath]"
    return
  else:
    fpSong = paramStr(1)
    if fileExists(fpSong) == false:
      echo "***Error: File does not exists"
      return

  shoutInit()
  shout = shoutNew()
  if shout.streamerInit():
    shout.streamerStart(fpSong)
  shout.free()
  shoutShutdown()

when isMainModule: main()
