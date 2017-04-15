#include <vorbis/vorbisfile.h>
#include "include/plugin.h"

static v2a_plugin_type *PLUGIN;
static OggVorbis_File file;
static FILE *in;

static void v2a_vorbis_play(void);
static void v2a_vorbis_close(void);

int
v2a_vorbis_init(char *filename, v2a_plugin_type *plugin)
{
  PLUGIN = NULL;
  vorbis_info *info;

  if((in = fopen(filename, "rb")) == NULL) {
    #ifdef V2A_DEBUG
    fprintf(stderr, "Vorbis: Can not open input file\n");
    #endif /* V2A_DEBUG */
    return -1;
  }

  if(ov_open_callbacks(in, &file, NULL, 0, OV_CALLBACKS_NOCLOSE) < 0) {
    #ifdef V2A_DEBUG
    fprintf(stderr, "Vorbis: Not an Ogg Vorbis bitstream\n");
    #endif /* V2A_DEBUG */
    fclose(in);
    return -1;
  }

  plugin->play_codec = v2a_vorbis_play;
  plugin->close_codec = v2a_vorbis_close;

  info = ov_info(&file, -1);
  plugin->audio.channels = info->channels;
  plugin->audio.rate = info->rate;
  plugin->audio.type = FMT_S16_NE;

  PLUGIN = plugin;
  return 0;
}

static int
v2a_vorbis_read(int *current_section)
{
  char pcmout[4096];
  int bytes;
  bytes = ov_read(&file, pcmout, sizeof(pcmout), 0, 2, 1, current_section);
  PLUGIN->bytes_audio(pcmout, bytes);
  return bytes;
}

static void
v2a_vorbis_play()
{
  int current_section;
  while(v2a_vorbis_read(&current_section));
}

static void
v2a_vorbis_close()
{
  ov_clear(&file);
  fclose(in);
}
