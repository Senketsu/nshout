# nshout
Nim's libshout wrapper library

## Example file included
* example of how to streams mp3 file to icecast
* usage 'streamMP3 [filepath]'

### Usage:
* nshout naming convention is very simple
* e.g: ```shout_set_agent > setAgent```
* a few exceptions (ambiguous calls for example) are:
```
shout_init = shoutInit
shout_shutdown = shoutShutdown
shout_new = shoutNew
shout_metadata_new = metadataNew
shout_version = shoutVersion
```
* you got the idea
