#include <stdio.h>
#include <stdlib.h>
#include "myassert.h"

void
myassert (int32_t expression)
{
  if (!expression)
  {
    fprintf(stderr, "Assertion failed.\n");
    exit(1);
  }
}
