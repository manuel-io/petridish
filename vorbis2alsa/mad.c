#include <mad.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include "include/plugin.h"

#define MPEGVERSION10 1
#define MPEGVERSION20 2
#define MPEGVERSION25 3

#define LAYER00I 1
#define LAYER0II 2
#define LAYERIII 3

static v2a_plugin_type *PLUGIN;
static struct mad_decoder decoder;
static FILE *in;
static void *fdm;
static unsigned int gconfig = 0x000000;

static void v2a_mad_play(void);
static void v2a_mad_close(void);

static int
unpacktagsize(v2a_mp3tag2_type id)
{
/*
 * The ID3v2 tag size is encoded with four bytes where the most
 * significant bit (bit 7) is set to zero in every byte, making a
 * total of 28 bits. The zeroed bits are ignored, so a 257 bytes long
 * tag is represented as $00 00 02 01.
 */

  unsigned int base = 0x000000;
  base |= id.size[0] << 22 | id.size[1] << 14 | id.size[2] << 7 | id.size[3];
  return base;
}

static int
v2a_mp3header_sync(unsigned int config)
{
  /* Frame sync (all bits must be set) */
  if((config & 0xff000000) >> 24 == 0xff) return 0;
  else return 1;
}

static int
v2a_mp3header_id(unsigned int config)
{
  switch((config & 0x00180000) >> 19) {
    case 0: return MPEGVERSION25; break;
    case 1: return MPEGVERSION10; break;
    case 2: return MPEGVERSION20; break;
    case 3: return MPEGVERSION10; break;
    default: return 0;
  }
}

#ifdef V2A_DEBUG
static int
v2a_mp3header_layer(unsigned int config) {
  switch((config & 0x00060000) >> 17) {
    case 0: return LAYERIII; break;
    case 1: return LAYERIII; break;
    case 2: return LAYER0II; break;
    case 3: return LAYERIII; break;
    default: return 0;
  }
}
#endif /* V2A_DEBUG */

static int
v2a_mp3header_samplefreq(unsigned int config)
{
  switch(v2a_mp3header_id(config)) {
    case MPEGVERSION10:
      switch((config & 0x00000c00) >> 10) {
        case 0: return 44100;
        case 1: return 48000;
        case 2: return 32000;
        case 3: return 44100;
        default: return 0;
      }
    break;
    case MPEGVERSION20:
      switch((config & 0x00000c00) >> 10) {
        case 0: return 22050; break;
        case 1: return 24000; break;
        case 2: return 16000; break;
        case 3: return 24000; break;
        default: return 0;
      }
    break;
    case MPEGVERSION25:
      switch((config & 0x00000c00) >> 10) {
        case 0: return 11025; break;
        case 1: return 12000; break;
        case 2: return 8000; break;
        case 3: return 11025; break;
        default: return 0;
      }
    break;
    default: return 0;
  }
  return 0;
}

static int
v2a_mp3header_channels(unsigned int config)
{
  switch((config & 0x00000c0) >> 6) {
    case 0: return 2; break;
    case 1: return 2; break;
    case 2: return 2; break;
    case 3: return 1; break;
    default: return 0;
  }
}

static enum mad_flow
v2a_mad_input(void *p, struct mad_stream *stream)
{
  v2a_plugin_type *plugin = (v2a_plugin_type *)p;
  if (!plugin->buffer.length) return MAD_FLOW_STOP;

  mad_stream_buffer(stream, plugin->buffer.start, plugin->buffer.length);
  plugin->buffer.length = 0;

  return MAD_FLOW_CONTINUE;
}

static signed int
downsample(mad_fixed_t sample)
{
  /* See ./libmad-0.15.1b/minimad.c */
  sample += (1L << (MAD_F_FRACBITS - 16));
  if (sample >= MAD_F_ONE) sample = MAD_F_ONE - 1;
  else if (sample < -MAD_F_ONE) sample = -MAD_F_ONE;
  return sample >> (MAD_F_FRACBITS + 1 - 16);
}

static enum mad_flow
v2a_mad_read(void *p, struct mad_header const *header, struct mad_pcm *pcm)
{
  v2a_plugin_type *plugin = (v2a_plugin_type *)p; 
  mad_fixed_t const *left_ch, *right_ch;
  int samples = pcm->length;
  signed int sample;

  /* 1152 because that's what mad has as a max; *4 because 940
   * there are 4 distinct bytes per sample (in 2 channel case)
   */
  unsigned char buffer[1152 * 4];
  unsigned char *ptr = buffer;

  left_ch   = pcm->samples[0];
  right_ch  = pcm->samples[1];
  
  while (samples--) {

    switch((gconfig & 0x00000c0) >> 6) {
      case 0:
      case 1:
      case 2:
        sample = (signed int) downsample(*left_ch++);
        *ptr++ = (unsigned char) ((sample >> 0) & 0xff);
        *ptr++ = (unsigned char) ((sample >> 8) & 0xff);

        sample = (signed int) downsample(*right_ch++);
        *ptr++ = (unsigned char) ((sample >> 0) & 0xff);
        *ptr++ = (unsigned char) ((sample >> 8) & 0xff);
        break;
      case 3:
        sample = (signed int) downsample(*left_ch++);
        *ptr++ = (unsigned char) ((sample >> 0) & 0xff);
        *ptr++ = (unsigned char) ((sample >> 8) & 0xff);
        break;
    }
  }

  switch((gconfig & 0x00000c0) >> 6) {
    case 0:
    case 1:
    case 2:
      plugin->bytes_audio(buffer, pcm->length * 4);
      break;
    case 3:
      plugin->bytes_audio(buffer, pcm->length * 2);
      break;
  }

  return MAD_FLOW_CONTINUE;
}

int
v2a_mad_init(char *filename, v2a_plugin_type *plugin)
{
  v2a_mp3header_type mp3header[4];
  v2a_mp3tag2_type mp3tag2;
  struct stat stat;

  fdm = NULL;
  PLUGIN = NULL;

  if((in = fopen(filename, "rb")) == NULL) {
    #ifdef V2A_DEBUG
    fprintf(stderr, "mad: Can not open input file\n");
    #endif /* V2A_DEBUG */
    return -1;
  }

  fread(&mp3tag2, 1, sizeof(v2a_mp3tag2_type), in);
  /* ID3v2 are located at the beginning of file, ID3v1 at the end */

  if(mp3tag2.tagid[0] == 'I' && mp3tag2.tagid[1] == 'D' && mp3tag2.tagid[2] == '3') {
    /* SEEK_SET, SEEK_CUR */
    fseek(in, unpacktagsize(mp3tag2), SEEK_CUR);
    fread(&mp3header, 1, 4 * sizeof(v2a_mp3header_type), in);
    /*
     * http://www.mp3-tech.org/programmer/frame_header.html
     */
    gconfig |= mp3header[0] << 24;
    gconfig |= mp3header[1] << 16 | mp3header[2] << 8 | mp3header[3];
  } else {
    rewind(in);
    fread(&mp3header, 1, 4 * sizeof(v2a_mp3header_type), in);
    gconfig |= mp3header[0] << 24;
    gconfig |= mp3header[1] << 16 | mp3header[2] << 8 | mp3header[3];
  }

  #ifdef V2A_DEBUG
  printf("Config: %x\n", gconfig);
  printf("ID: %d\n", v2a_mp3header_id(gconfig));
  printf("Layer: %d\n", v2a_mp3header_layer(gconfig));
  printf("Bitrate: %x\n", (gconfig & 0x0000f000) >> 12);
  printf("Rate: %d\n", v2a_mp3header_samplefreq(gconfig));
  printf("Channels: %d\n", v2a_mp3header_channels(gconfig));
  #endif /* V2A_DEBUG */

  fstat(fileno(in), &stat);
  fdm = mmap(0, stat.st_size, PROT_READ, MAP_SHARED, fileno(in), 0);

  plugin->buffer.start = fdm;
  plugin->buffer.length = stat.st_size;
  plugin->audio.channels = v2a_mp3header_channels(gconfig);
  plugin->audio.rate = v2a_mp3header_samplefreq(gconfig);
  plugin->audio.type = FMT_S16_LE;

  if (v2a_mp3header_sync(gconfig) || (plugin->audio.channels < 1 || plugin->audio.rate < 1)) {
    v2a_mad_close();
    return -1;
  }

  plugin->play_codec = v2a_mad_play;
  plugin->close_codec = v2a_mad_close;

  mad_decoder_init(&decoder, plugin, v2a_mad_input, NULL, NULL, v2a_mad_read, NULL, NULL);

  PLUGIN = plugin;
  return 0;
}

static void
v2a_mad_play()
{
  mad_decoder_run(&decoder, MAD_DECODER_MODE_SYNC);
}

static void
v2a_mad_close()
{
  struct stat stat;
  mad_decoder_finish(&decoder);
  fstat(fileno(in), &stat);
  munmap(fdm, stat.st_size);
  fclose(in);
}
