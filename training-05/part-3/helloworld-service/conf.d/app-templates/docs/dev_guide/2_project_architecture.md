# Project architecture

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

## Manage app-templates submodule

### Update

You may have some news bug fixes or features available from app-templates
repository that you want. To update your submodule proceed like the following:

```bash
git submodule update --remote
git commit -s conf.d/app-templates
```

This will update the submodule to the HEAD of master branch repository. Save
the modification by commiting it in your master git project.

### Checkout submodule to a git tag

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
