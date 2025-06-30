/*
    Assignement 2
    Author: cskang510

    Date: 2025-06-30

    Syntax: writer <dir_path>/filename write_string
    Note: dir_path must exist before running this program.
*/
#include <stdio.h>
#include <syslog.h>


int main(int argc, char *argv[])
{
    FILE *fp;
    char *filename = "output.txt";
    int i;

    // Open syslog for logging
    openlog("writer", LOG_PID | LOG_CONS, LOG_USER);
    syslog(LOG_INFO, "Program started with %d arguments", argc);

    /* check the number of arguments */
    if (argc < 2) {
        printf("Usage: %s %s %s\n", argv[0], "<dir_path>/filename", "<write_string>");
        syslog(LOG_ERR, "Insufficient arguments provided");
        closelog();
        return 1;
    }

    // Open the file for writing
    fp = fopen(argv[1], "w");
    if (fp == NULL) {
        perror("Error opening file");
        syslog(LOG_ERR, "Error opening file: %s", argv[1]);
        closelog();
        return 1;
    }

    // Write the string to the file
    if(fprintf(fp, "%s\n", argv[2]) < 0) {
        perror("Error writing to file");
        fclose(fp);
        syslog(LOG_ERR, "Error writing to file: %s", argv[1]);
        closelog();
        return 1;
    } else {
        syslog(LOG_INFO, "Writing %s to %s", argv[2], argv[1]);
    }

    // Close the file
    fclose(fp);
    closelog();
    return 0;
}
