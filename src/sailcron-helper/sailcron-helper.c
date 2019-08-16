#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char command[4096], cmdline[4096];
    int i;
    if (setuid(0) != 0) {
        perror("Setuid failed, no suid-bit set?");
        return 1;
    }
    for (i = 1; i < argc; i++) {
        strcat(command, argv[i]);
        strcat(command, " ");
    }
    sprintf(cmdline, "/usr/share/harbour-sailcron/helper/sailcronhelper.sh %s",
            command);

    system(cmdline);
    return 0;
}
