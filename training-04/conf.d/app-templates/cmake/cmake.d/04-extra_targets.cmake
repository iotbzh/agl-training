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

# ----------------------------------------------------------------------------
#                                Archive target
# ----------------------------------------------------------------------------
#add_custom_command(OUTPUT  ${ARCHIVE_OUTPUT}
#	DEPENDS ${PROJECT_TARGETS}
#	#Create git archive of the main project
#	COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}\; git --git-dir=${CMAKE_CURRENT_SOURCE_DIR}/.git archive --format=tar --prefix=${NPKG_PROJECT_NAME}-${PROJECT_VERSION}/ HEAD -o ${ARCHIVE_OUTPUT_ARCHIVE}
#	#Create tmp git archive for each submodule
#	COMMAND cd ${CMAKE_CURRENT_SOURCE_DIR}\; git --git-dir=${CMAKE_CURRENT_SOURCE_DIR}/.git submodule foreach --recursive ${CMD_ARCHIVE_SUBMODULE}
#	#Concatenate main archive and tmp submodule archive
#	COMMAND  for SUBTAR in ${TMP_ARCHIVE_SUBMODULE}-*.tar\; do tar --concatenate --file=${ARCHIVE_OUTPUT_ARCHIVE} $$SUBTAR\;done
#	#Remove tmp submodule archive
#	COMMAND rm -rf ${TMP_ARCHIVE_SUBMODULE}-*.tar
#	#Compress main archive
#	COMMAND gzip --force --verbose ${ARCHIVE_OUTPUT_ARCHIVE}
#)
#add_custom_target(archive DEPENDS ${ARCHIVE_OUTPUT})

# ----------------------------------------------------------------------------
#                                Packaging target
# ----------------------------------------------------------------------------
#Format Build require package
#foreach (PKG_CONFIG ${PKG_REQUIRED_LIST})
#	#Unset TMP variable
#	unset(XPREFIX)
#	unset(XRULE)
#	unset(RPM_EXTRA_DEP)
#	unset(DEB_EXTRA_DEP)
#	#For deb package,add EOL format only for a new line
#	if(DEB_PKG_DEPS)
#		set(DEB_PKG_DEPS "${DEB_PKG_DEPS},\n")
#	endif()
#	#Get pkg-config rule on version
#	string(REGEX REPLACE "[<>]?=.*$" "" XPREFIX ${PKG_CONFIG})
#	string(REGEX MATCH "[<>]?="  XRULE ${PKG_CONFIG})
#	#Only if pkg-config has rule on version
#	if(XRULE)
#		string(REGEX REPLACE ".*[<>]?=" "" XVERS ${PKG_CONFIG})
#		set(RPM_EXTRA_DEP " ${XRULE} ${XVERS}")
#		set(DEB_EXTRA_DEP " (${XRULE} ${XVERS})")
#	endif()
#	# Format for rpm package
#	set(RPM_PKG_DEPS "${RPM_PKG_DEPS}BuildRequires: pkgconfig(${XPREFIX})${RPM_EXTRA_DEP}\n")
#
#	# Format for deb package
#	# Because the tool "dpkg" is used on the packages db to find the
#	# package providing the pkg-cong file ${XPREFIX}.pc, we need
#	# to test the OS release package type
#	# Only doable within a native environment not under SDK
#	if( OSRELEASE MATCHES "debian" AND NOT DEFINED ENV{SDKTARGETSYSROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
#		execute_process(
#			COMMAND dpkg -S *${XPREFIX}.pc
#					OUTPUT_VARIABLE TMP_PKG_BIN
#		)
#		if(TMP_PKG_BIN)
#			string(REGEX REPLACE ":.*$" "" PKG_BIN ${TMP_PKG_BIN})
#			set(DEB_PKG_DEPS "${DEB_PKG_DEPS} ${PKG_BIN} ${DEB_EXTRA_DEP}")
#		else()
#			message(FATAL_ERROR "-- ${Red}${XPREFIX} development files not installed. Abort.${ColourReset}")
#		endif()
#	endif()
#endforeach()
#
#if(NOT EXISTS ${TEMPLATE_DIR}/rpm-config.spec.in)
#	MESSAGE(FATAL_ERROR "${Red}Missing mandatory files: you need rpm-config.spec.in in ${TEMPLATE_DIR} folder.${ColourReset}")
#endif()
#
## Because the tool "dpkg" is used on the packages db to find the
## package providing the pkg-cong file ${XPREFIX}.pc, we need
## to test the OS release package type
## Only doable within a native environment not under SDK
#if(OSRELEASE MATCHES "debian" AND NOT DEFINED ENV{SDKTARGETSYSROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
#	add_custom_target(packaging_deb DEPENDS ${TEMPLATE_DIR}/debian.compat.in
#				${TEMPLATE_DIR}/debian.changelog.in
#				${TEMPLATE_DIR}/deb-config.dsc.in
#				${TEMPLATE_DIR}/deb-config.install.in
#				${TEMPLATE_DIR}/debian.control.in
#				${TEMPLATE_DIR}/debian.rules.in
#		COMMAND ${CMAKE_COMMAND} -DINFILE=${TEMPLATE_DIR}/debian.compat.in		-DOUTFILE=${PACKAGING_DEB_OUTPUT_COMPAT}	-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}	-P	${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
#		COMMAND ${CMAKE_COMMAND} -DINFILE=${TEMPLATE_DIR}/debian.changelog.in	-DOUTFILE=${PACKAGING_DEB_OUTPUT_CHANGELOG}	-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}	-P	${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
#		COMMAND ${CMAKE_COMMAND} -DINFILE=${TEMPLATE_DIR}/deb-config.dsc.in		-DOUTFILE=${PACKAGING_DEB_OUTPUT_DSC}		-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}	-P	${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
#		COMMAND ${CMAKE_COMMAND} -DINFILE=${TEMPLATE_DIR}/deb-config.install.in	-DOUTFILE=${PACKAGING_DEB_OUTPUT_INSTALL}	-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}	-P	${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
#		COMMAND ${CMAKE_COMMAND} -DINFILE=${TEMPLATE_DIR}/debian.control.in		-DOUTFILE=${PACKAGING_DEB_OUTPUT_CONTROL}	-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}	-P	${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
#		COMMAND ${CMAKE_COMMAND} -DINFILE=${TEMPLATE_DIR}/debian.rules.in		-DOUTFILE=${PACKAGING_DEB_OUTPUT_RULES}		-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}	-P	${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
#	)
#endif()
#
#add_custom_target(packaging)
#set(PACKAGING_SPEC_OUTPUT ${PROJECT_PKG_ENTRY_POINT}/${NPKG_PROJECT_NAME}.spec)
#add_custom_target(packaging_rpm DEPENDS ${TEMPLATE_DIR}/rpm-config.spec.in
#	COMMAND ${CMAKE_COMMAND} -DINFILE=${TEMPLATE_DIR}/rpm-config.spec.in -DOUTFILE=${PACKAGING_SPEC_OUTPUT} -DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
#)
#add_dependencies(packaging packaging_rpm)
#if(TARGET packaging_wgt)
#	add_dependencies(packaging packaging_wgt)
#endif()
#if(OSRELEASE MATCHES "debian" AND NOT DEFINED ENV{SDKTARGETSYSROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
#	# Target to add dependencies indirectly to "packaging" target.
#	add_dependencies(packaging packaging_deb)
#endif()

#Generate a cmake cache file usable by cmake script.
set(CacheForScript ${CMAKE_BINARY_DIR}/CMakeCacheForScript.cmake)
#Create a tmp cmake file.
file(WRITE ${CacheForScript} "")

get_cmake_property(Vars VARIABLES)
foreach(Var ${Vars})
	if(${Var})
		#Replace unwanted char.
		string(REPLACE "\\" "\\\\" VALUE ${${Var}})
		string(REPLACE "\n" "\\n" VALUE ${VALUE})
		string(REPLACE "\r" "\\n" VALUE ${VALUE})
		string(REPLACE "\"" "\\\"" VALUE ${VALUE})
	endif()
	file(APPEND ${CacheForScript} "set(${Var} \"${VALUE}\")\n")
endforeach()

# ----------------------------------------------------------------------------
#                                Autobuild target
# ----------------------------------------------------------------------------

add_custom_target(autobuild ALL DEPENDS ${CMAKE_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/template.d/autobuild/agl/autobuild.in
	${CMAKE_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/template.d/autobuild/linux/autobuild.in
	COMMAND ${CMAKE_COMMAND} -DINFILE=${CMAKE_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/template.d/autobuild/agl/autobuild.in -DOUTFILE=${PROJECT_TEMPLATE_AGL_AUTOBUILD_DIR}/autobuild -DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
	COMMAND ${CMAKE_COMMAND} -DINFILE=${CMAKE_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/template.d/autobuild/agl/autobuild.in -DOUTFILE=${PROJECT_TEMPLATE_LINUX_AUTOBUILD_DIR}/autobuild -DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
)
