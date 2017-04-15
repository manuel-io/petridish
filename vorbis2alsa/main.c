#include "include/plugin.h"

#define STR_EXPAND(tok) #tok
#define STR(tok) STR_EXPAND(tok)

static int
output(v2a_plugin_type *plugin)
{
  int (*libs[])(v2a_plugin_type *) = {
    v2a_pulse_init,
    v2a_alsa_init
  };
 
  for(unsigned int i = 0; i < 1; i++)
    if(libs[i](plugin) == 0) return 0;

  return -1;
}

static int
input(char *filename, v2a_plugin_type *plugin)
{
  int (*libs[])(char *, v2a_plugin_type *) = {
    v2a_mad_init,
    v2a_opus_init,
    v2a_vorbis_init
  };
 
  for(unsigned int i = 0; i < 3; i++)
    if(libs[i](filename, plugin) == 0) return 0;

  return -1;
}

int
main(int argc, char **argv)
{
  v2a_plugin_type plugin;

  if(argc < 2) {
    fprintf(stderr, "%s [options] file\n", STR(V2A_NAME));
    return -1;
  }

  if(input(argv[1], &plugin) != 0) {
    fprintf(stderr, "Unable to play input: %s\n", argv[1]);
    return -1;
  }

  if(output(&plugin) != 0) { 
    fprintf(stderr, "Unable to play output\n");
    return -1;
  }

  plugin.play_codec();
  plugin.close_audio();
  plugin.close_codec();
  return 0;
}
