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
#     Customise your preferences in "./etc/config.cmake"
#--------------------------------------------------------------------------

# Get colorized message output non Windows OS. You know bash ? :)
if(NOT WIN32)
	string(ASCII 27 Esc)
	set(ColourReset "${Esc}[m")
	set(ColourBold  "${Esc}[1m")
	set(Red         "${Esc}[31m")
	set(Green       "${Esc}[32m")
	set(Yellow      "${Esc}[33m")
	set(Blue        "${Esc}[34m")
	set(Magenta     "${Esc}[35m")
	set(Cyan        "${Esc}[36m")
	set(White       "${Esc}[37m")
	set(BoldRed     "${Esc}[1;31m")
	set(BoldGreen   "${Esc}[1;32m")
	set(BoldYellow  "${Esc}[1;33m")
	set(BoldBlue    "${Esc}[1;34m")
	set(BoldMagenta "${Esc}[1;35m")
	set(BoldCyan    "${Esc}[1;36m")
	set(BoldWhite   "${Esc}[1;37m")
endif()

# Native packaging name
set(NPKG_PROJECT_NAME agl-${PROJECT_NAME})

string(REGEX MATCH "[0-9]+" LINUX_VERSION_CODE ${LINUX_VERSION_CODE_LINE})
math(EXPR a "${LINUX_VERSION_CODE} >> 16")
math(EXPR b "(${LINUX_VERSION_CODE} >> 8) & 255")
math(EXPR c "(${LINUX_VERSION_CODE} & 255)")

set(KERNEL_VERSION "${a}.${b}.${c}")

# Include project configuration
# ------------------------------
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES})
set(PROJECT_LIBDIR "${CMAKE_SOURCE_DIR}/libs" CACHE PATH "Subpath to libraries")
set(PROJECT_RESOURCES "${CMAKE_SOURCE_DIR}/data" CACHE PATH "Subpath to data")

set(AFB_TOKEN   ""      CACHE PATH "Default AFB_TOKEN")
set(AFB_REMPORT "1234" CACHE PATH "Default AFB_TOKEN")

# Check GCC minimal version
if (gcc_minimal_version)
message (STATUS "${Cyan}-- Check gcc_minimal_version (found gcc version ${CMAKE_C_COMPILER_VERSION}) \
(found g++ version ${CMAKE_CXX_COMPILER_VERSION})${ColourReset}")
if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version} OR CMAKE_C_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version})
message(FATAL_ERROR "${Red}**** FATAL: Require at least gcc-${gcc_minimal_version} please set CMAKE_C[XX]_COMPILER")
endif()
endif(gcc_minimal_version)

# Check Kernel mandatory version, will fail the configuration if required version not matched.
if (kernel_mandatory_version)
message (STATUS "${Cyan}-- Check kernel_mandatory_version (found kernel version ${KERNEL_VERSION})${ColourReset}")
if (KERNEL_VERSION VERSION_LESS ${kernel_mandatory_version})
message(FATAL_ERROR "${Red}**** FATAL: Require at least ${kernel_mandatory_version} please use a recent kernel or source your SDK environment then clean and reconfigure your CMake project.")
endif (KERNEL_VERSION VERSION_LESS ${kernel_mandatory_version})
endif(kernel_mandatory_version)

# Check Kernel minimal version just print a Warning about missing features
# and set a definition to be used as preprocessor condition in code to disable
# incompatibles features.
if (kernel_minimal_version)
message (STATUS "${Cyan}-- Check kernel_minimal_version (found kernel version ${KERNEL_VERSION})${ColourReset}")
if (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
message(WARNING "${Yellow}**** Warning: Some feature(s) require at least ${kernel_minimal_version}. Please use a recent kernel or source your SDK environment then clean and reconfigure your CMake project.${ColourReset}")
else (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
add_definitions(-DKERNEL_MINIMAL_VERSION_OK)
endif (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
endif(kernel_minimal_version)

# Project path variables
# ----------------------
set(PKGOUT_DIR package CACHE PATH "Output directory for packages")

# Define a default package directory
if(PKG_PREFIX)
	set(PROJECT_PKG_BUILD_DIR ${PKG_PREFIX}/${PKGOUT_DIR} CACHE PATH "Application contents to be packaged")
else()
	set(PROJECT_PKG_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/${PKGOUT_DIR} CACHE PATH "Application contents to be packaged")
endif()

# Paths to templates files
set(TEMPLATE_DIR "${PKG_TEMPLATE_PREFIX}/template.d" CACHE PATH "Subpath to a directory where are stored needed files to launch on remote target to debuging purposes")

string(REGEX REPLACE "^(.*)/.*$" "\\1" ENTRY_POINT "${PKG_TEMPLATE_PREFIX}")
set(PROJECT_PKG_ENTRY_POINT ${ENTRY_POINT}/packaging CACHE PATH "Where package build files, like rpm.spec file or config.xml, are write.")

set(WIDGET_ICON "${ENTRY_POINT}/wgt/${PROJECT_ICON}" CACHE PATH "Path to the widget icon")
set(WIDGET_CONFIG_TEMPLATE ${TEMPLATE_DIR}/config.xml.in CACHE PATH "Path to widget config file template (config.xml.in)")

# Path to autobuild template
set(PROJECT_TEMPLATE_AGL_AUTOBUILD_DIR ${CMAKE_SOURCE_DIR}/conf.d/autobuild/agl CACHE PATH "Subpath to a directory where are stored autobuild script")
set(PROJECT_TEMPLATE_LINUX_AUTOBUILD_DIR ${CMAKE_SOURCE_DIR}/conf.d/autobuild/linux CACHE PATH "Subpath to a directory where are stored autobuild script")

# Archive target variables
set(ARCHIVE_OUTPUT_ARCHIVE ${PROJECT_PKG_ENTRY_POINT}/${NPKG_PROJECT_NAME}_${PROJECT_VERSION}.orig.tar)
set(ARCHIVE_OUTPUT ${ARCHIVE_OUTPUT_ARCHIVE}.gz)
set(TMP_ARCHIVE_SUBMODULE ${PROJECT_PKG_ENTRY_POINT}/${NPKG_PROJECT_NAME}-sub)
set(CMD_ARCHIVE_SUBMODULE \'git archive --verbose --prefix=${NPKG_PROJECT_NAME}-${PROJECT_VERSION}/$$path/ --format tar HEAD --output ${TMP_ARCHIVE_SUBMODULE}-$$sha1.tar\' )

if(OSRELEASE MATCHES "debian" AND NOT DEFINED ENV{SDKTARGETSYSROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
	# build deb spec file from template
	set(PACKAGING_DEB_OUTPUT_DSC       ${PROJECT_PKG_ENTRY_POINT}/${NPKG_PROJECT_NAME}.dsc)
	set(PACKAGING_DEB_OUTPUT_INSTALL   ${PROJECT_PKG_ENTRY_POINT}/debian.${NPKG_PROJECT_NAME}.install)
	set(PACKAGING_DEB_OUTPUT_CHANGELOG ${PROJECT_PKG_ENTRY_POINT}/debian.changelog)
	set(PACKAGING_DEB_OUTPUT_COMPAT    ${PROJECT_PKG_ENTRY_POINT}/debian.compat)
	set(PACKAGING_DEB_OUTPUT_CONTROL   ${PROJECT_PKG_ENTRY_POINT}/debian.control)
	set(PACKAGING_DEB_OUTPUT_RULES     ${PROJECT_PKG_ENTRY_POINT}/debian.rules)
endif()

# Break After Binding are loaded but before they get initialised
set(GDB_INITIAL_BREAK "personality" CACHE STRING "Initial Break Point for GDB remote")

# Define some checker binaries to verify input DATA files
# to be included in package. Schema aren't checked for now.
# Dummy checker about JSON.
set(LUA_CHECKER "luac" "-p" CACHE STRING "LUA compiler")
set(XML_CHECKER "xmllint" CACHE STRING "XML linter")
set(JSON_CHECKER "" CACHE STRING "JSON linter")
