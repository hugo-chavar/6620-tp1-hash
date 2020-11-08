#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "hash.h"

#define BUFFERSIZ 256

int si = 1; /* es standard input: por defecto es true */
int so = 1; /* es standard output: por defecto es true */

FILE *input;
FILE *output;


typedef struct {
	int32_t hash;
	char *msg;
} regression;

int32_t
get_hash_(string_hash *sh, char *msg, size_t len, size_t stride)
{
	char *ptr = msg;
	size_t delta;
	size_t rem;

	string_hash_init(sh);
	for (rem = len; rem > 0; ) {
		if (rem >= stride)
			delta = stride;
		else
			delta = rem;
	
		string_hash_more(sh, ptr, delta);
		rem -= delta;
		ptr += delta;
	}
	string_hash_done(sh);

	return string_hash_value(sh);
}

int
get_hash(char *msg)
{
	size_t len = strlen(msg);
	size_t stride;
	string_hash sh;
	int32_t h0;
	int32_t h;

	if (len > 1) {
		h0 = get_hash_(&sh, msg, len, len);

		for (stride = len; stride >= 1; stride--) {
			h = get_hash_(&sh, msg, len, stride);
			assert(h0 == h);
		}
	}

	return h0;
}


int
main (int argc, char **argv)
{
  int c;
  input = stdin;
  output = stdout;

  static struct option long_options[] =
  {
    {"help",    no_argument,       0, 'h'},
    {"version", no_argument,       0, 'V'},
    {"input",   required_argument, 0, 'i'},
    {"output",  required_argument, 0, 'o'},
    {0, 0, 0, 0}
  };


  while (1)
  {
    /* getopt_long stores the option index here. */
    int option_index = 0;

    c = getopt_long (argc, argv, "hV:i:o:",
                      long_options, &option_index);

    /* Detect the end of the options. */
    if (c == -1)
      break;

    switch (c)
      {

      case 'h':
        fprintf(stderr, "Usage:\n  %s -h \n  %s -v\n  %s -i in_file -o out_file\n", argv[0], argv[0], argv[0]);
        fprintf(stderr, "Options:\n  -h, --help     Print this information and quit.\n  -V, --version  Print version and quit.\n  -i, --input    Specify input stream/file, \"-\" for stdin.\n  -o, --output   Specify output stream/file, \"-\" for stdout.\n");
        fprintf(stderr, "Examples:\n  tp1 < in.txt > out.txt \n  cat in.txt | tp1 -i - > out.txt\n");
        break;

      case 'V':
        puts ("tp1 orga6620 v1.0\n");
        break;

      case 'i':
        
        si = 0;
        if (strcmp(optarg, "-")) {
          
          input = fopen(optarg, "r");
          if (input == NULL)
          {
            fprintf (stderr, "Can't open file `%s` for reading. %s\n", optarg, strerror(errno));
            exit (1);
          }

        }

        break;

      case 'o':
        
        so = 0;
        if (strcmp(optarg, "-")) {
          output = fopen(optarg, "w+");
          if (output == NULL)
          {
            fprintf (stderr, "Can't open file `%s` for writing. %s \n", optarg, strerror(errno));
            exit (1);
          }

        }
        
        break;

      default:
        exit(1);
      }
  }

  /* No pueden haber mas argumentos se da error */
  if (optind < argc)
  {
    //printf ("non-option ARGV-elements: ");
    while (optind < argc)
      fprintf (stderr, "%s non-valid argument\n", argv[optind++]);
    
    fclose(input);
    fclose(output);
    exit(1);
  }

  size_t linesiz = 0;
  char* linebuf = NULL;
  ssize_t linelen = 0;
  int32_t hash;
  while ((linelen = getline(&linebuf, &linesiz, input) > 0))
  {
    hash = get_hash(linebuf);
    //process_line(linebuf, linesiz);
    
    char * tempStr = (char *) malloc(strlen(linebuf)+11);
    sprintf(tempStr, "0x%08x %s", hash, linebuf);
    //printf("[%s]\n", linebuf);
    fwrite(tempStr, 1, strlen(tempStr), output);
    free(tempStr);
    
  }

  free(linebuf);
  fclose(input);
  fclose(output);

  exit (0);
}

