#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifndef V2A_PLUGIN
#define V2A_PLUGIN

typedef enum {
  FMT_S16_LE,
  FMT_S16_BE,
  FMT_S16_NE,
  FMT_U16_LE,
  FMT_U16_BE,
  FMT_U16_NE,
  FMT_U8,
  FMT_S8
} v2a_pcm_type;

struct buffer {
  unsigned char *start;
  unsigned long length;
};

struct v2a_audio_type {
  unsigned int channels;
  unsigned int samples;
  unsigned int rate;
  v2a_pcm_type type;
};

typedef struct {
  void (*bytes_audio)(void *, int);
  void (*frames_audio)(void *, int);
  void (*close_audio)(void);
  void (*play_codec)(void);
  void (*close_codec)(void);
  struct v2a_audio_type audio;
  struct buffer buffer;
} v2a_plugin_type;

#include "alsa.h"
#include "pulse.h"

#include "mad.h"
#include "opus.h"
#include "vorbis.h"

#endif /* V2A_PLUGIN */
