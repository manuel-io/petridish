#include <opus/opusfile.h>
#include "include/plugin.h"

static v2a_plugin_type *PLUGIN;
static OggOpusFile *file;

static void v2a_opus_play(void);
static void v2a_opus_close(void);

static int v2a_opus_read(int *);

int
v2a_opus_init(char *filename, v2a_plugin_type *plugin)
{
  PLUGIN = NULL;

  if((file = op_open_file(filename, NULL)) == NULL) {
    #ifdef V2A_DEBUG
    fprintf(stderr, "Opus: Not an Ogg Opus bitstream\n");
    #endif /* V2A_DEBUG */
    return -1;
  }

  plugin->play_codec = v2a_opus_play;
  plugin->close_codec = v2a_opus_close;

  plugin->audio.channels = op_channel_count(file, -1);
  plugin->audio.rate = 48000;
  plugin->audio.type = FMT_S16_NE;

  PLUGIN = plugin;
  return 0;
}

static int
v2a_opus_read(int *current_section)
{
  opus_int16 pcmout[6 * 960 * PLUGIN->audio.channels * 2];
  int frames;
  frames = op_read(file, pcmout, sizeof(pcmout), current_section);
  PLUGIN->frames_audio(pcmout, frames);
  return frames;
}

static void
v2a_opus_play()
{
  int current_section;
  while(v2a_opus_read(&current_section));
}

static void
v2a_opus_close()
{
  op_free(file);
}
