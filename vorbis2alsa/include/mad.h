#ifndef V2A_MAD
#define V2A_MAD

typedef struct {
  unsigned char tagid[3];
  unsigned char version[2];  
  unsigned char flags; 
  unsigned char size[4];
} v2a_mp3tag2_type;

typedef unsigned char v2a_mp3header_type;

int v2a_mad_init(char *, v2a_plugin_type *);

#endif /* MAD2ALSA_MAD */
