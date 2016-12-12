#include <stdio.h>

int a = 0, b = 0, c = 1, d = 0;

int main() {
line0:
  a = 1;
line1:
  b = 1;
line2:
  d = 26;
line3:
  if (c) goto line5;
line4:
  if (1) goto line9;
line5:
  c = 7;
line6:
  d++;
line7:
  c--;
line8:
  if (c) goto line6;
line9:
  c = a;
line10:
  a++;
line11:
  b--;
line12:
  if (b) goto line10;
line13:
  b = c;
line14:
  d--;
line15:
  if (d) goto line9;
line16:
  c = 19;
line17:
  d = 14;
line18:
  a++;
line19:
  d--;
line20:
  if (d) goto line18;
line21:
  c--;
line22:
  if (c) goto line17;

  printf("%d\n", a);
  return 0;
}

