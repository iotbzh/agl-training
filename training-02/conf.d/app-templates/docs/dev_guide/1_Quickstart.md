# Quickstart

## Initialization

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

## Create your CMake targets

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

INSTALL(TARGETS ${TARGET_NAME}....
```

## Targets PROPERTIES

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
	OUTPUT_NAME "file_output_name")
```

> **NOTE**: You doesn't need to specify an **INSTALL** command for these
> targets. This is already handle by template and will be installed in the
> following path : **${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}**
