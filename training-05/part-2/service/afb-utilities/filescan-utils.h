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
 *
 * reference:
 *   amixer contents; amixer controls;
 *   http://www.tldp.org/HOWTO/Alsa-sound-6.html
 */

#ifndef FILESCAN_UTILS_H
#define FILESCAN_UTILS_H

#ifdef __cplusplus
    extern "C" {
#endif

#define AFB_BINDING_VERSION 2
#include <afb/afb-binding.h>
#include <json-c/json.h>

#ifndef PUBLIC
  #define PUBLIC
#endif
#define STATIC static

#ifndef CONTROL_MAXPATH_LEN
  #define CONTROL_MAXPATH_LEN 255
#endif

typedef enum {
  CTL_SCAN_FLAT=0,
  CTL_SCAN_RECURSIVE=1,
} CtlScanDirModeT;

PUBLIC const char *GetMidleName(const char*name);
PUBLIC const char *GetBinderName();
PUBLIC json_object* ScanForConfig (const char* searchPath, CtlScanDirModeT mode, const char *pre, const char *ext);
PUBLIC char *GetBindingDirPath();


#ifdef __cplusplus
    }
#endif

#endif /* FILESCAN_UTILS_H */
