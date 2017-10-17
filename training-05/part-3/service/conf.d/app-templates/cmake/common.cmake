###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
#
# author: Fulup Ar Foll <fulup@iot.bzh>
# contrib: Romain Forlot <romain.forlot@iot.bzh>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################


#--------------------------------------------------------------------------
#  WARNING:
#     Do not change this cmake template
#     Customise your preferences in "./conf.d/cmake/config.cmake"
#--------------------------------------------------------------------------

# Include ExternalProject CMake module by default
include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)

if(DEFINED ENV{SDKTARGETSYSROOT})
file(STRINGS $ENV{SDKTARGETSYSROOT}/usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
set(BUILD_ENV_SYSROOT $ENV{SDKTARGETSYSROOT})
elseif(DEFINED ENV{PKG_CONFIG_SYSROOT_DIR})
file(STRINGS $ENV{PKG_CONFIG_SYSROOT_DIR}/usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
set(BUILD_ENV_SYSROOT $ENV{PKG_CONFIG_SYSROOT_DIR})
else()
file(STRINGS /usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
set(BUILD_ENV_SYSROOT "")
endif()

# Get the os type
# Used to package .deb
set(OS_RELEASE_PATH "${BUILD_ENV_SYSROOT}/etc/os-release")
if(EXISTS ${OS_RELEASE_PATH})
	execute_process(COMMAND bash "-c" "grep -E '^ID(_LIKE)?=' ${OS_RELEASE_PATH} | tail -n 1"
		OUTPUT_VARIABLE TMP_OSRELEASE
	)

	if (NOT TMP_OSRELEASE STREQUAL "")
		string(REGEX REPLACE ".*=\"?([0-9a-z\._-]*)\"?\n" "\\1" OSRELEASE ${TMP_OSRELEASE})
	else()
		set(OSRELEASE "NOT COMPATIBLE !")
	endif()

else()
	set(OSRELEASE "NOT COMPATIBLE ! Missing ${OS_RELEASE_PATH} file.")
endif()
message(STATUS "Distribution used ${OSRELEASE}")

file(GLOB project_cmakefiles ${PROJECT_APP_TEMPLATES_DIR}/cmake/cmake.d/[0-9][0-9]-*.cmake)
file(GLOB distro_cmakefiles ${PROJECT_APP_TEMPLATES_DIR}/../cmake/[0-9][0-9]-${OSRELEASE}*.cmake ${PROJECT_APP_TEMPLATES_DIR}/../cmake/[0-9][0-9]-common*.cmake)
list(SORT distro_cmakefiles)
if(NOT distro_cmakefiles)
	file(GLOB distro_cmakefiles ${PROJECT_APP_TEMPLATES_DIR}/../cmake/[0-9][0-9]-default*.cmake)
endif()

list(APPEND project_cmakefiles "${distro_cmakefiles}")
list(SORT project_cmakefiles)

file(GLOB home_cmakefiles $ENV{HOME}/.config/app-templates/cmake.d/[0-9][0-9]-common*.cmake $ENV{HOME}/.config/app-templates/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake)
list(SORT home_cmakefiles)
file(GLOB system_cmakefiles /etc/app-templates/cmake.d/[0-9][0-9]-common*.cmake /etc/app-templates/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake)
list(SORT system_cmakefiles)

foreach(file ${system_cmakefiles} ${home_cmakefiles} ${project_cmakefiles})
	message(STATUS "Include: ${file}")
	include(${file})
endforeach()

if(DEFINED PROJECT_SRC_DIR_PATTERN)
	project_subdirs_add(${PROJECT_SRC_DIR_PATTERN})
else()
	project_subdirs_add()
endif(DEFINED PROJECT_SRC_DIR_PATTERN)

configure_files_in_dir(${PROJECT_APP_TEMPLATES_DIR}/${ENTRY_POINT}/template.d)
configure_files_in_dir($ENV{HOME}/.config/app-templates/scripts)
configure_files_in_dir(/etc/app-templates/scripts)

project_targets_populate()
remote_targets_populate()
project_package_build()
project_closing_msg()
