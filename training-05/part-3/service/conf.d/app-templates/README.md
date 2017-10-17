# AGL CMake template

Files used to build an application, or binding, project with the
AGL Application Framework.

To build your AGL project using these templates, you have to install
them within your project and adjust compilation option in `config.cmake`.
For technical reasons, you also have to specify **cmake** target in
sub CMakeLists.txt installed. Make a globbing search to find source files
isn't recommended now to handle project build especially in a multiuser
project because CMake will not be aware of new or removed source files.

You'll find usage samples here:

- [helloworld-service](https://github.com/iotbzh/helloworld-service)
- [low-level-can-service](https://gerrit.automotivelinux.org/gerrit/apps/low-level-can-service)
- [high-level-viwi-service](https://github.com/iotbzh/high-level-viwi-service)
- [audio-binding](https://github.com/iotbzh/audio-binding)
- [unicens2-binding](https://github.com/iotbzh/unicens2-binding)

## Quickstart

### Initialization

To use these templates files on your project just install the reference files using
**git submodule** then use `config.cmake` file to configure your project specificities :

```bash
git submodule add https://gerrit.automotivelinux.org/gerrit/p/apps/app-templates.git conf.d/app-templates
mkdir conf.d/cmake
cp conf.d/app-templates/samples.d/config.cmake.sample conf.d/cmake/config.cmake
```

Edit the copied config.cmake file to fit your needs.

Now, create your top CMakeLists.txt file which include `config.cmake` file.

An example is available in **app-templates** submodule that you can copy and
use:

```bash
cp conf.d/app-templates/samples.d/CMakeLists.txt.sample CMakeLists.txt
```

### Create your CMake targets

For each target part of your project, you need to use ***PROJECT_TARGET_ADD***
to include this target to your project.

Using it, make available the cmake variable ***TARGET_NAME*** until the next
***PROJECT_TARGET_ADD*** is invoked with a new target name.

So, typical usage defining a target is:

```cmake
PROJECT_TARGET_ADD(SuperExampleName) --> Adding target to your project

add_executable/add_library(${TARGET_NAME}.... --> defining your target sources

SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES.... --> fit target properties
for macros usage
```

### Targets PROPERTIES

You should set properties on your targets that will be used to package your
apps in a widget file that could be installed on an AGL system.

Specify what is the type of your targets that you want to be included in the
widget package with the property **LABELS**:

Choose between:

- **BINDING**: Shared library that be loaded by the AGL Application Framework
- **BINDINGV2**: Shared library that be loaded by the AGL Application Framework
 This has to be accompagnied with a JSON file named like the
 *${OUTPUT_NAME}-apidef* of the target that describe the API with OpenAPI
 syntax (e.g: *mybinding-apidef*). Or you can choose the name, without the
 extension, by setting the *CACHE* cmake variable *OPENAPI_DEF* (***CAUTION***:
 setting a CACHE variable is needed, or set a normal variable with the
 *PARENT_SCOPE* option to make it visible for the parent scope where the target
 is defined) JSON file will be used to generate header file using `afb-genskel`
 tool.
- **PLUGIN**: Shared library meant to be used as a binding plugin. Binding
 would load it as a plugin to extend its functionnalities. It should be named
 with a special extension that you choose with SUFFIX cmake target property or
 it'd be **.ctlso** by default.
- **HTDOCS**: Root directory of a web app. This target has to build its
 directory and puts its files in the ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
- **DATA**: Resources used by your application. This target has to build its
 directory and puts its files in the ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
- **EXECUTABLE**: Entry point of your application executed by the AGL
 Application Framework
- **LIBRARY**: An external 3rd party library bundled with the binding for its
 own purpose because platform doesn't provide it.

> **TIP** you should use the prefix _afb-_ with your **BINDING* targets which
> stand for **Application Framework Binding**.

```cmake
SET_TARGET_PROPERTIES(${TARGET_NAME}
	PREFIX "afb-"
	LABELS "BINDING"
	OUTPUT_NAME "file_output_name"
)
```

> **NOTE**: You doesn't need to specify an **INSTALL** command for these
> targets. This is already handle by template and will be installed in the
> following path : **${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}**

## More details: Typical project architecture

A typical project architecture would be :

```tree
<project-root-path>
│
├── conf.d/
│   ├── autobuild/
│   │   ├── agl
│   │   │   └── autobuild
│   │   ├── linux
│   │   │   └── autobuild
│   │   └── windows
│   │       └── autobuild
│   ├── app-templates/
│   │   ├── README.md
│   │   ├── cmake/
│   │   │   ├── export.map
│   │   │   └── macros.cmake
│   │   ├── samples.d/
│   │   │   ├── CMakeLists.txt.sample
│   │   │   ├── config.cmake.sample
│   │   │   ├── config.xml.in.sample
│   │   │   └── xds-config.env.sample
│   │   ├── template.d/
│   │   │   ├── autobuild/
│   │   │   │   ├── agl
│   │   │   │   │   └── autobuild.in
│   │   │   │   ├── linux
│   │   │   │   │   └── autobuild.in
│   │   │   │   └── windows
│   │   │   │       └── autobuild.in
│   │   │   ├── config.xml.in
│   │   │   ├── deb-config.dsc.in
│   │   │   ├── deb-config.install.in
│   │   │   ├── debian.changelog.in
│   │   │   ├── debian.compat.in
│   │   │   ├── debian.rules.in
│   │   │   ├── gdb-on-target.ini.in
│   │   │   ├── install-wgt-on-target.sh.in
│   │   │   ├── start-on-target.sh.in
│   │   │   ├── rpm-config.spec.in
│   │   │   └── xds-project-target.conf.in
│   │   └── wgt/
│   │       ├── icon-default.png
│   │       ├── icon-html5.png
│   │       ├── icon-native.png
│   │       ├── icon-qml.png
│   │       └── icon-service.png
│   ├── packaging/
│   │   ├── config.spec
│   │   └── config.deb
│   ├── cmake
│   │   └── config.cmake
│   └── wgt
│      └── config.xml.in
├── <libs>
├── <target>
│   └── <files>
├── <target>
│   └── <file>
└── <target>
    └── <files>
```

| # | Parent | Description |
| - | -------| ----------- |
| \<root-path\> | - | Path to your project. Hold master CMakeLists.txt and general files of your projects. |
| conf.d | \<root-path\> | Holds needed files to build, install, debug, package an AGL app project |
| app-templates | conf.d | Git submodule to app-templates AGL repository which provides CMake helpers macros library, and build scripts. config.cmake is a copy of config.cmake.sample configured for the projects. SHOULD NOT BE MODIFIED MANUALLY !|
| autobuild | conf.d | Scripts generated from app-templates to build packages the same way for differents platforms.|
| cmake | conf.d | Contains at least config.cmake file modified from the sample provided in app-templates submodule. |
| wgt | conf.d | Contains at least config.xml.in template file modified from the sample provided in app-templates submodule for the needs of project (See config.xml.in.sample file for more details). |
| packaging | conf.d | Contains output files used to build packages. |
| \<libs\> | \<root-path\> | External dependencies libraries. This isn't to be used to include header file but build and link statically specifics libraries. | Library sources files. Can be a decompressed library archive file or project fork. |
| \<target\> | \<root-path\> | A target to build, typically library, executable, etc. |

### Update app-templates submodule

You may have some news bug fixes or features available from app-templates
repository that you want. To update your submodule proceed like the following:

```bash
git submodule update --remote
git commit -s conf.d/app-templates
```

This will update the submodule to the HEAD of master branch repository.

You could just want to update at a specified repository tag or branch or commit
, here are the method to do so:

```bash
cd conf.d/app-templates
# Choose one of the following depending what you want
git checkout <tag_name>
git checkout --detach <branch_name>
git checkout --detach <commit_id>
# Then commit
cd ../..
git commit -s conf.d/app-templates
```

### Build a widget

#### config.xml.in file

To build a widget you need a _config.xml_ file describing what is your apps and
how Application Framework would launch it. This repo provide a simple default
file _config.xml.in_ that should work for simple application without
interactions with others bindings.

It is recommanded that you use the sample one which is more complete. You can
find it at the same location under the name _config.xml.in.sample_ (stunning
isn't it). Just copy the sample file to your _conf.d/wgt_ directory and name it
_config.xml.in_, then edit it to fit your needs.

> ***CAUTION*** : The default file is only meant to be use for a
> simple widget app, more complicated ones which needed to export
> their api, or ship several app in one widget need to use the provided
> _config.xml.in.sample_ which had all new Application Framework
> features explained and examples.

#### Using cmake template macros

To leverage all cmake templates features, you have to specify ***properties***
on your targets. Some macros will not works without specifying which is the
target type.

As the type is not always specified for some custom targets, like an ***HTML5***
application, macros make the difference using ***LABELS*** property.

Choose between:

- **BINDING**: Shared library that be loaded by the AGL Application Framework
- **BINDINGV2**: Shared library that be loaded by the AGL Application Framework
 This has to be accompagnied with a JSON file named like the
 *${OUTPUT_NAME}-apidef* of the target that describe the API with OpenAPI
 syntax (e.g: *mybinding-apidef*). Or you can choose the name, without the
 extension, by setting the *CACHE* cmake variable *OPENAPI_DEF* (***CAUTION***:
 setting a CACHE variable is needed, or set a normal variable with the
 *PARENT_SCOPE* option to make it visible for the parent scope where the target
 is defined) JSON file will be used to generate header file using `afb-genskel`
 tool.
- **PLUGIN**: Shared library meant to be used as a binding plugin. Binding
 would load it as a plugin to extend its functionnalities. It should be named
 with a special extension that you choose with SUFFIX cmake target property or
 it'd be **.ctlso** by default.
- **HTDOCS**: Root directory of a web app. This target has to build its
 directory and puts its files in the ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
- **DATA**: Resources used by your application. This target has to build its
 directory and puts its files in the ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
- **EXECUTABLE**: Entry point of your application executed by the AGL
 Application Framework
- **LIBRARY**: An external 3rd party library bundled with the binding for its
 own purpose because platform doesn't provide it.

> **TIP** you should use the prefix _afb-_ with your **BINDING* targets which
> stand for **Application Framework Binding**.

Example:

```cmake
SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
		LABELS "HTDOCS"
		OUTPUT_NAME dist.prod
	)
```

> **NOTE**: You doesn't need to specify an **INSTALL** command for these
> targets. This is already handle by template and will be installed in the
> following path : **${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}**

#### Add external 3rd party library

You could need to include an external library that isn't shipped in the
platform. Then you have to bundle the required library in the `lib` widget
directory.

Templates includes some facilities to help you to do so. Classic way to do so
is to declare as many CMake ExternalProject as library you need.

An ExternalProject is a special CMake module that let you define how to:
download, update, patch, configure, build and install an external project. It
doesn't have to be a CMake project and custom step could be added for special
needs using ExternalProject step. More informations on CMake [ExternalProject
documentation site](https://cmake.org/cmake/help/v3.5/module/ExternalProject.html?highlight=externalproject).

Example to include `mxml` library for [unicens2-binding](https://github.com/iotbzh/unicens2-binding)
project:

```cmake
set(MXML external-mxml)
set(MXML_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/mxml)
ExternalProject_Add(${MXML}
    GIT_REPOSITORY https://github.com/michaelrsweet/mxml.git
    GIT_TAG release-2.10
    SOURCE_DIR ${MXML_SOURCE_DIR}
    CONFIGURE_COMMAND ./configure --build x86_64 --host aarch64
    BUILD_COMMAND make libmxml.so.1.5
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
)

PROJECT_TARGET_ADD(mxml)

add_library(${TARGET_NAME} SHARED IMPORTED GLOBAL)

SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
    LABELS LIBRARY
    IMPORTED_LOCATION ${MXML_SOURCE_DIR}/libmxml.so.1
    INTERFACE_INCLUDE_DIRECTORIES ${MXML_SOURCE_DIR}
)

add_dependencies(${TARGET_NAME} ${MXML})
```

Here we define an external project that drive the build of the library then we
define new CMake target of type **IMPORTED**. Meaning that this target hasn't
be built using CMake but is available at the location defined in the target
property *IMPORTED_LOCATION*.

Then target *LABELS* property is set to **LIBRARY** to ship it in the widget.

Unicens project also need some header from this library, so we use the target
property *INTERFACE_INCLUDE_DIRECTORIES*. Setting that when another target link
to that imported target, it can access to the include directories.

We bound the target to the external project using a CMake dependency at last.

#### Macro reference

##### PROJECT_TARGET_ADD

Typical usage would be to add the target to your project using macro
`PROJECT_TARGET_ADD` with the name of your target as parameter.

Example:

```cmake
PROJECT_TARGET_ADD(low-can-demo)
```

> ***NOTE***: This will make available the variable `${TARGET_NAME}`
> set with the specificied name. This variable will change at the next call
> to this macros.

##### project_subdirs_add

This macro will search in all subfolder any `CMakeLists.txt` file. If found then
it will be added to your project. This could be use in an hybrid application by
example where the binding lay in a sub directory.

Usage :

```cmake
project_subdirs_add()
```

You also can specify a globbing pattern as argument to filter which folders
will be looked for.

To filter all directories that begin with a number followed by a dash the
anything:

```cmake
project_subdirs_add("[0-9]-*")
```

## Advanced build customization

### Including additionnals cmake files

#### Machine and system custom cmake files

Advanced tuning is possible using addionnals cmake files that are included
automatically from some specifics locations. They are included in that order:

- Project CMake files normaly located in _<project-root-path>/conf.d/app-templates/cmake/cmake.d_
- Home CMake files located in _$HOME/.config/app-templates/cmake.d_
- System CMake files located in _/etc/app-templates/cmake.d_

CMake files has to be named using the following convention: `XX-common*.cmake`
or `XX-${PROJECT_NAME}*.cmake`, where `XX` are numbers, `*` file name
(ie. `99-common-my_customs.cmake`).

> **NOTE** You need to specify after numbers that indicate include order, to
which project that file applies, if it applies to all project then use keyword
`common`.

So, saying that you should be aware that every normal cmake variables used at
project level could be overwrited by home or system located cmake files if
variables got the same name. Exceptions are cached variables set using
**CACHE** keyword:

Example:

```cmake
set(VARIABLE_NAME 'value string random' CACHE STRING 'docstring')
```

#### OS custom cmake files

This is meant to personalize the project depending on the OS your are using.
At the end of config.cmake, common.cmake will include lot of cmake file to
customize project build depending on your plateform. It will detect your OS
deducing it from file _/etc/os-release_ now as default in almost all Linux
distribution.

So you can use the value of field **ID_LIKE** or **ID** if the
first one doesn't exists and add a cmake file for that distribution in your
_conf.d/cmake/_ directory or relatively to your _app-templates_ submodule path
_app-templates/../cmake/_

Those files has to be named use the following scheme _XX-${OSRELEASE}*.cmake_
where _XX_ are numbers, ${OSRELEASE} the **ID_LIKE** or **ID** field from
_/etc/os-release_ file. You can also define default OS configuration file
to use as fallback is none specific OS configuration is available using the
scheme _XX-default*.cmake_. Then is you need by example a module that isn't
named the same in one distro only, you only has to define a specific file to
handle that case then for all the other case put the configuration in the
default file.

### Include customs templated scripts

As well as for additionnals cmake files you can include your own templated
scripts that will be passed to cmake command `configure_file`.

Just create your own script to the following directories:

- Home location in _$HOME/.config/app-templates/scripts_
- System location in _/etc/app-templates/scripts_

Scripts only needs to use the extension `.in` to be parsed and configured by
CMake command.

## Autobuild script usage

### Generation

To be integrated in the Yocto build workflow you have to generate `autobuild`
scripts using _autobuild_ target.

To generate those scripts proceeds:

```bash
mkdir -p build
cd build
cmake .. && make autobuild
```

You should see _conf.d/autobuild/agl/autobuild_ file now.

### Available targets

Here are the available targets available from _autobuild_ scripts:

- **clean** : clean build directory from object file and targets results.
- **distclean** : delete build directory
- **configure** : generate project Makefile from CMakeLists.txt files.
- **build** : compile all project targets.
- **package** : build and output a wgt package.

You can specify variables that modify the behavior of compilation using
the following variables:

- **CONFIGURE_ARGS** : Variable used at **configure** time.
- **BUILD_ARGS** : Variable used at **build** time.
- **DEST** : Directory where to output ***wgt*** file.

Variable as to be in CMake format. (ie: BUILD_ARGS="-DC_FLAGS='-g -O2'")

Usage example:

```bash
./conf.d/autobuild/wgt/autobuild package DEST=/tmp
```
