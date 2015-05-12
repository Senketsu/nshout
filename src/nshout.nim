# nshout - Nim shout wrapper library
# by Senketsu ( #Senketsu_Dev | https://github.com/Senketsu )
{.deadCodeElim: on.}
{.push gcsafe.}
when defined(Windows):
 const LibName* = "libshout.dll"
elif defined(Linux):
 const LibName* = "libshout.so"
elif defined(macosx):
 const LibName* = "libshout.dylib"

const
  SHOUTERR_SUCCESS* = (0)
  SHOUTERR_INSANE* = (- 1)
  SHOUTERR_NOCONNECT* = (- 2)
  SHOUTERR_NOLOGIN* = (- 3)
  SHOUTERR_SOCKET* = (- 4)
  SHOUTERR_MALLOC* = (- 5)
  SHOUTERR_METADATA* = (- 6)
  SHOUTERR_CONNECTED* = (- 7)
  SHOUTERR_UNCONNECTED* = (- 8)
  SHOUTERR_UNSUPPORTED* = (- 9)
  SHOUTERR_BUSY* = (- 10)
  SHOUT_FORMAT_OGG* = (0)
  SHOUT_FORMAT_MP3* = (1)
  SHOUT_FORMAT_WEBM* = (2)
  SHOUT_FORMAT_VORBIS* = SHOUT_FORMAT_OGG
  SHOUT_PROTOCOL_HTTP* = (0)
  SHOUT_PROTOCOL_XAUDIOCAST* = (1)
  SHOUT_PROTOCOL_ICY* = (2)
  SHOUT_AI_BITRATE* = "bitrate"
  SHOUT_AI_SAMPLERATE* = "samplerate"
  SHOUT_AI_CHANNELS* = "channels"
  SHOUT_AI_QUALITY* = "quality"
  LIBSHOUT_DEFAULT_HOST* = "localhost"
  LIBSHOUT_DEFAULT_PORT* = 8000
  LIBSHOUT_DEFAULT_FORMAT* = SHOUT_FORMAT_OGG
  LIBSHOUT_DEFAULT_PROTOCOL* = SHOUT_PROTOCOL_HTTP
  LIBSHOUT_DEFAULT_USER* = "source"
  LIBSHOUT_DEFAULT_USERAGENT* = "libnshout/0.1"
  SHOUT_BUFSIZE* = 4096

type
 sock_t* = int
 TShoutMeta* = object
  key*: cstring
  val*: cstring
  next*: ptr TShoutMeta

 TShoutBuf* = object
  data*: array[SHOUT_BUFSIZE, cuchar]
  len*: cuint
  pos*: cuint
  prev*: ptr TShoutBuf
  next*: ptr TShoutBuf

 TShoutQueue* = object
  head*: ptr TShoutBuf
  len*: csize

 TShoutState* {.size: sizeof(cint).} = enum
  SHOUT_STATE_UNCONNECTED = 0, SHOUT_STATE_CONNECT_PENDING,
  SHOUT_STATE_REQ_PENDING, SHOUT_STATE_RESP_PENDING, SHOUT_STATE_CONNECTED

 TShout* = object
  host*: cstring          # hostname or IP of icecast server
  port*: cint             # port of the icecast server
  password*: cstring      # login password for the server
  protocol*: cuint        # server protocol to use
  format*: cuint          # type of data being sent
  audio_info*: TShoutMeta # audio encoding parameters
  useragent*: cstring     # user-agent to use when doing HTTP login
  mount*: cstring         # mountpoint for this stream
  name*: cstring          # name of the stream
  url*: cstring           # homepage of the stream
  genre*: cstring         # genre of the stream
  description*: cstring   # description of the stream
  dumpfile*: cstring      # icecast 1.x dumpfile
  user*: cstring          # username to use for HTTP auth.
  public*: cint           # is this stream private?
  socket*: cint          # socket the connection is on
  state*: TShoutState
  nonblocking*: cint
  format_data*: pointer
  rqueue*: TShoutQueue
  wqueue*: TShoutQueue
  starttime*: uint64      # start of this period's timeclock
  senttime*: uint64       # amout of data we've sent (in milliseconds)
  error*: cint

type
  PShout* = ptr TShout
  PShoutMeta* = ptr TShoutMeta

# initializes the shout library. Must be called before anything else
proc shoutInit*()
  {.cdecl, dynlib: LibName, importc:"shout_init".}

# shuts down the shout library, deallocating any global storage. Don't call
#  anything afterwards
proc shoutShutdown*()
  {.cdecl, dynlib: LibName, importc:"shout_shutdown".}

# returns a static version string.  Non-null parameters will be set to the
#  value of the library major, minor, and patch levels, respectively
proc shoutVersion*(majon,minor,patch: int):cstring
  {.cdecl, dynlib: LibName, importc:"shout_version".}

# Allocates and sets up a new PShout.  Returns NULL if it can't get enough
#  memory.  The returns PShout must be disposed of with shout_free
proc shoutNew*():PShout
  {.cdecl, dynlib: LibName, importc:"shout_new".}

# Free all memory allocated by a PShout
proc free*(self: PShout)
  {.cdecl, dynlib: LibName, importc:"shout_free".}

# Returns a statically allocated string describing the last shout error
#  to occur.  Only valid until the next libshout call on this PShout
proc getError*(self: PShout): cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_error".}

# Return the error code (e.g. SHOUTERR_SOCKET) for this shout instance
proc getErrno*(self: PShout): int
  {.cdecl, dynlib: LibName, importc:"shout_get_errno".}

# returns SHOUTERR_CONNECTED or SHOUTERR_UNCONNECTED
proc getConnected*(self: PShout): int
  {.cdecl, dynlib: LibName, importc:"shout_get_connected".}

# Parameter manipulation functions.  libshout makes copies of all parameters,
#  the caller may free its copies after giving them to libshout.  May return
#  SHOUTERR_MALLOC
proc setHost*(self: PShout,host: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_host".}

proc getHost*(self: PShout): cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_host".}

proc setPort*(self: PShout,port: cushort): int
  {.cdecl, dynlib: LibName, importc:"shout_set_port".}

proc getPort*(self: PShout):cushort
  {.cdecl, dynlib: LibName, importc:"shout_get_port".}

proc setPassword*(self: PShout,password: cstring): int
  {.cdecl, dynlib: LibName, importc:"shout_set_password".}

proc getPassword*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_password".}

proc setMount*(self: PShout, mount: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_mount".}

proc getMount*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_mount".}

proc setName*(self: PShout, name: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_name".}

proc getName*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_name".}

proc setUrl*(self: PShout, url: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_url".}

proc getUrl*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_url".}

proc setGenre*(self: PShout, genre: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_genre".}

proc getGenre*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_genre".}

proc setUser*(self: PShout, username: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_user".}

proc getUser*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_user".}

proc setAgent*(self: PShout, agent: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_agent".}

proc getAgent*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_agent".}

proc setDescription*(self: PShout, description: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_description".}

proc getDescription*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_description".}

proc setDumpfile*(self: PShout, dumpfile: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_dumpfile".}

proc getDumpfile*(self: PShout):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_dumpfile".}

proc setAudioInfo*(self: PShout, name,value: cstring):int
  {.cdecl, dynlib: LibName, importc:"shout_set_audio_info".}

proc getAudioInfo*(self: PShout, name:cstring):cstring
  {.cdecl, dynlib: LibName, importc:"shout_get_audio_info".}

proc setPublic*(self: PShout, make_public: uint):int
  {.cdecl, dynlib: LibName, importc:"shout_set_public".}

proc getPublic*(self: PShout):uint
  {.cdecl, dynlib: LibName, importc:"shout_get_public".}

# takes a SHOUT_FORMAT_xxxx argument
proc setFormat*(self: PShout, format: uint):int
  {.cdecl, dynlib: LibName, importc:"shout_set_format".}

proc getFormat*(self: PShout):uint
  {.cdecl, dynlib: LibName, importc:"shout_get_format".}

# takes a SHOUT_PROTOCOL_xxxxx argument
proc setProtocol*(self: PShout, protocol: uint):int
  {.cdecl, dynlib: LibName, importc:"shout_set_protocol".}

proc getProtocol*(self: PShout):uint
  {.cdecl, dynlib: LibName, importc:"shout_get_protocol".}

# Instructs libshout to use nonblocking I/O. Must be called before
#  shout_open (no switching back and forth midstream at the moment).
proc setNonblocking*(self: PShout, nonblocking: uint):int
  {.cdecl, dynlib: LibName, importc:"shout_set_nonblocking".}

proc getNonblocking*(self: PShout):uint
  {.cdecl, dynlib: LibName, importc:"shout_get_nonblocking".}

# Opens a connection to the server.  All parameters must already be set
proc open*(self: PShout):int
  {.cdecl, dynlib: LibName, importc:"shout_open".}

# Closes a connection to the server
proc close*(self: PShout):int
  {.cdecl, dynlib: LibName, importc:"shout_close".}

# Send data to the server, parsing it for format specific timing info
proc send*(self: PShout, data: cstring, len: csize):int
  {.cdecl, dynlib: LibName, importc:"shout_send".}

# Send unparsed data to the server.  Do not use this unless you know
# what you are doing. Returns the number of bytes written, or < 0 on error.
proc sendRaw*(self: PShout, data: cstring, len: csize):csize
  {.cdecl, dynlib: LibName, importc:"shout_send_raw".}

# return the number of bytes currently on the write queue (only makes sense in
#  nonblocking mode).
proc queueLen*(self: PShout):csize
  {.cdecl, dynlib: LibName, importc:"shout_queuelen".}

# Puts caller to sleep until it is time to send more data to the server
proc sync*(self: PShout)
  {.cdecl, dynlib: LibName, importc:"shout_sync".}

# Amount of time in ms caller should wait before sending again
proc delay*(self: PShout):cint
  {.cdecl, dynlib: LibName, importc:"shout_delay".}

# Sets MP3 metadata.
# Returns:
# *   SHOUTERR_SUCCESS
# *   SHOUTERR_UNSUPPORTED if format isn't MP3
# *   SHOUTERR_MALLOC
# *   SHOUTERR_INSANE
# *   SHOUTERR_NOCONNECT
# *   SHOUTERR_SOCKET
proc setMetadata*(self: PShout, metadata: PShoutMeta):cint
  {.cdecl, dynlib: LibName, importc:"shout_set_metadata".}

# Allocates a new metadata structure.  Must be freed by shout_metadata_free.
proc metadataNew*(): PShoutMeta
  {.cdecl, dynlib: LibName, importc:"shout_metadata_new".}

# Free resources allocated by PShoutMeta
proc free*(self: PShoutMeta)
  {.cdecl, dynlib: LibName, importc:"shout_metadata_free".}

# Add a parameter to the metadata structure.
# Returns:
# *   SHOUTERR_SUCCESS on success
# *   SHOUTERR_INSANE if self isn't a valid PShoutMeta* or name is null
# *   SHOUTERR_MALLOC if memory can't be allocated
proc add*(self: PShoutMeta,name,value: cstring):cint
  {.cdecl, dynlib: LibName, importc:"shout_metadata_add".}


proc main() =
 echo "***************************************************************"
 echo "* nshout - Nim shout wrapper library"
 echo "*  by Senketsu ( #Senketsu_Dev | https://github.com/Senketsu )"
 echo "***************************************************************"
 echo "*  THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,"
 echo "*  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES"
 echo "*  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT."
 echo "*  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,"
 echo "*  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,"
 echo "*  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE"
 echo "*  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
 echo "***************************************************************"
when isMainModule: main()
