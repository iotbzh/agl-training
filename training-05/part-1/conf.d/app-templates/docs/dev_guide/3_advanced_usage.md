# Build a widget

## config.xml.in file

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

## Using cmake template macros

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

## Add external 3rd party library

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

## Macro reference

### PROJECT_TARGET_ADD

Typical usage would be to add the target to your project using macro
`PROJECT_TARGET_ADD` with the name of your target as parameter.

Example:

```cmake
PROJECT_TARGET_ADD(low-can-demo)
```

> ***NOTE***: This will make available the variable `${TARGET_NAME}`
> set with the specificied name. This variable will change at the next call
> to this macros.

### project_subdirs_add

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
