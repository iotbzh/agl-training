/*
 * Copyright (C) 2016 "IoT.bzh"
 * Author Fulup Ar Foll <fulup@iot.bzh>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <sys/prctl.h>
#include <dirent.h>

#include "filescan-utils.h"

// List Avaliable Configuration Files
PUBLIC json_object* ScanForConfig (const char* searchPath, CtlScanDirModeT mode, const char *pre, const char *ext) {
    json_object *responseJ;
    char *dirPath;
    char* dirList= strdup(searchPath);
    size_t extLen=0;

    void ScanDir (char *searchPath) {
    DIR  *dirHandle;
        struct dirent *dirEnt;
        dirHandle = opendir (searchPath);
        if (!dirHandle) {
            AFB_DEBUG ("CONFIG-SCANNING dir=%s not readable", searchPath);
            return;
        }

        //AFB_NOTICE ("CONFIG-SCANNING:ctl_listconfig scanning: %s", searchPath);
        while ((dirEnt = readdir(dirHandle)) != NULL) {

            // recursively search embedded directories ignoring any directory starting by '.' or '_'
            if (dirEnt->d_type == DT_DIR && mode == CTL_SCAN_RECURSIVE) {
                char newpath[CONTROL_MAXPATH_LEN];
                if (dirEnt->d_name[0]=='.' || dirEnt->d_name[0]=='_') continue;

                strncpy(newpath, searchPath, sizeof(newpath));
                strncat(newpath, "/", sizeof(newpath)-strlen(newpath)-1);
                strncat(newpath, dirEnt->d_name, sizeof(newpath)-strlen(newpath)-1);
                ScanDir(newpath);
                continue;
            }

            // Unknown type is accepted to support dump filesystems
            if (dirEnt->d_type == DT_REG || dirEnt->d_type == DT_UNKNOWN) {

                // check prefix and extention
                ssize_t extIdx=strlen(dirEnt->d_name)-extLen;
                if (extIdx <= 0) continue;
                if (pre && !strcasestr (dirEnt->d_name, pre)) continue;
                if (ext && strcasecmp (ext, &dirEnt->d_name[extIdx])) continue;

                struct json_object *pathJ = json_object_new_object();
                json_object_object_add(pathJ, "fullpath", json_object_new_string(searchPath));
                json_object_object_add(pathJ, "filename", json_object_new_string(dirEnt->d_name));
                json_object_array_add(responseJ, pathJ);
            }
        }
        closedir(dirHandle);
    }

    if (ext) extLen=strlen(ext);
    responseJ = json_object_new_array();

    // loop recursively on dir
    for (dirPath= strtok(dirList, ":"); dirPath && *dirPath; dirPath=strtok(NULL,":")) {
         ScanDir (dirPath);
    }

    return (responseJ);
}

PUBLIC const char *GetMidleName(const char*name) {
    char *fullname = strdup(name);

    for (int idx = 0; fullname[idx] != '\0'; idx++) {
        if (fullname[idx] == '-') {
            int start;
            start = idx + 1;
            for (int jdx = start; ; jdx++) {
                if (fullname[jdx] == '-' || fullname[jdx] == '.' || fullname[jdx] == '\0') {
                    fullname[jdx] = '\0';
                    return &fullname[start];
                }
            }
            break;
        }
    }
    return "";
}

PUBLIC const char *GetBinderName() {
    static char *binderName=NULL;

    if (binderName) return binderName;

    binderName= getenv("AFB_BINDER_NAME");
    if (!binderName) {
        char psName[17];
        // retrieve binder name from process name afb-name-trailer
        prctl(PR_GET_NAME, psName,NULL,NULL,NULL);
        binderName=(char*)GetMidleName(psName);
    }

    return binderName;
}

PUBLIC char *GetBindingDirPath()
{
    // A file description should not be greater than 999.999.999
    char fd_link[CONTROL_MAXPATH_LEN];
    char retdir[CONTROL_MAXPATH_LEN];
    sprintf(fd_link, "/proc/self/fd/%d", afb_daemon_rootdir_get_fd());

    ssize_t len;
    if((len = readlink(fd_link, retdir, sizeof(retdir)-1)) == -1)
    {
        perror("lstat");
        AFB_ERROR("Error reading stat of link: %s", fd_link);
        strncpy(retdir, "/tmp", 4);
    }
    else
    {
        retdir[len] = '\0';
    }

    return strndup(retdir, sizeof(retdir));
}
