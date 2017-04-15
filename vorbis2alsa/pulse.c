#include <pulse/simple.h>
#include "include/plugin.h"

static pa_simple *handle = NULL;
static v2a_plugin_type *PLUGIN;

static void v2a_pulse_bytes(void *, int);
static void v2a_pulse_frames(void *, int);
static void v2a_pulse_close(void);

int
v2a_pulse_init(v2a_plugin_type *plugin)
{
  PLUGIN = NULL;

  pa_sample_spec spec = {
     .format = PA_SAMPLE_S16LE,
     .rate = plugin->audio.rate,
     .channels = plugin->audio.channels
   };

  if((handle = pa_simple_new(NULL,
    "vorbis2alsa",
    PA_STREAM_PLAYBACK,
    NULL,
    "Music",
    &spec,
    NULL,
    NULL,
    NULL
  )) == NULL) {
    fprintf(stderr, "Pulse: Error");
    return -1;
  }

  plugin->bytes_audio = v2a_pulse_bytes;
  plugin->frames_audio = v2a_pulse_frames;
  plugin->close_audio = v2a_pulse_close;

  PLUGIN = plugin;
  return 0;
}

static void
v2a_pulse_bytes(void *data, int length)
{
  pa_simple_write(handle, data, (size_t)length, NULL);
}

static void
v2a_pulse_frames(void *data, int length)
{
  pa_simple_write(handle, data, (size_t)(length * PLUGIN->audio.channels * 2), NULL);
}

static void
v2a_pulse_close()
{
  pa_simple_free(handle);
}
