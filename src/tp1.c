#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

#define BUFFERSIZ 256

int si = 1; /* es standard input: por defecto es true */
int so = 1; /* es standard output: por defecto es true */

FILE *input;
FILE *output;

int
main (int argc, char **argv)
{
  int c;
  ssize_t nr;
  char buf[BUFFERSIZ];
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
  char* linebuf = 0;
  ssize_t linelen = 0;
  while ((linelen = getline(&linebuf, &linesiz, input) > 0))
  {
    //TODO: invocar la funcion de hash
    //process_line(linebuf, linesiz);

    printf("[%s]\n", linebuf);
    free(linebuf);
    linebuf = NULL;
  }

  fclose(input);
  fclose(output);

  exit (0);
}

