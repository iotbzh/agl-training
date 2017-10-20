# 2. Native development

A Helloworld AGL application for AGL Training 02.

## Build for 'native' Linux distros (Fedora, openSUSE, Debian, Ubuntu, ...)

Easy way using autobuild script:

```bash
./conf.d/autobuild/linux/autobuild package
```

Step-by-step build:

```bash
mkdir build
cd build
BUILD_DIR=$(pwd)
cmake ..
make
```

## Test

### Native Linux

For native build you need to install **afb-daemon** tools.
You can build it by your self [app-framework-binder][app-framework-binder], or use binary package from OBS: [opensuse.org/LinuxAutomotive][opensuse.org/LinuxAutomotive]

```bash
cd ${BUILD_DIR}
export PORT=8000

afb-daemon --port=${PORT}  --ldpaths=./package/lib/ --roothttp=./package/htdocs

curl http://localhost:${PORT}/api/helloworld/ping
#For a nice display
curl http://localhost:${PORT}/api/helloworld/ping 2>/dev/null | python -m json.tool
```

From a Web Browser, you can access the webui at:

```bash
xdg-open http://localhost:${PORT}/htdocs/index.html?token=${TOKEN}
```

[opensuse.org/LinuxAutomotive]:https://en.opensuse.org/LinuxAutomotive#AGL_Application_Framework
[app-framework-binder]:https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/app-framework-binder
