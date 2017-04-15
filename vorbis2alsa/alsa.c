#include <alsa/asoundlib.h>
#include "include/plugin.h"

static char *device = "default";
static snd_pcm_t *handle;
static v2a_plugin_type *PLUGIN;

static unsigned int format[] = {
  SND_PCM_FORMAT_S16_LE,
  SND_PCM_FORMAT_S16_BE,
  SND_PCM_FORMAT_S16,
  SND_PCM_FORMAT_U16_LE,
  SND_PCM_FORMAT_U16_BE,
  SND_PCM_FORMAT_U16,
  SND_PCM_FORMAT_U8,
  SND_PCM_FORMAT_S8
};

static void v2a_alsa_bytes(void *, int);
static void v2a_alsa_frames(void *, int);
static void v2a_alsa_close(void);

int
v2a_alsa_init(v2a_plugin_type *plugin)
{
  PLUGIN = NULL;

  if(snd_pcm_open(&handle, device, SND_PCM_STREAM_PLAYBACK, 0) < 0) {
    fprintf (stderr, "Alsa: Cannot open audio device\n");
    return -1;
  }
 
  if(snd_pcm_set_params(handle,
    format[plugin->audio.type],
    SND_PCM_ACCESS_RW_INTERLEAVED,
    plugin->audio.channels,
    plugin->audio.rate,
    1,
    500000) < 0) {
    fprintf(stderr, "Alsa: Playback open error\n");
    return -1;
  }

  plugin->bytes_audio = v2a_alsa_bytes;
  plugin->frames_audio = v2a_alsa_frames;
  plugin->close_audio = v2a_alsa_close;

  PLUGIN = plugin;
  return 0;
}

static void
v2a_alsa_bytes(void *data, int length)
{
  snd_pcm_sframes_t written_frames;
  int written_bytes, frames;  

  while(length > 0) {
    frames = snd_pcm_bytes_to_frames(handle, length);
    written_frames = snd_pcm_writei(handle, data, frames);

    if(written_frames > 0) {
      written_bytes = snd_pcm_frames_to_bytes(handle, written_frames);
      length -= written_bytes;
      data += written_bytes;
    }
  }
}

static void
v2a_alsa_frames(void *data, int length)
{
  snd_pcm_sframes_t written_frames;

  while(length > 0) {
    written_frames = snd_pcm_writei(handle, data, length);

    if(written_frames > 0) {
      length -= written_frames;
      data += written_frames;
    }
  }
}

static void
v2a_alsa_close()
{
  snd_pcm_close(handle);
}
