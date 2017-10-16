# helloworld-service

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
cmake ..
make
```

## Test

### Native Linux

For native build you need to have tools **afb-daemon**.
You can build it by your self [app-framework-binder][app-framework-binder], or use binary package from OBS: [opensuse.org/LinuxAutomotive][opensuse.org/LinuxAutomotive]

```bash
export PORT=8000
afb-daemon --port=${PORT}  --ldpaths=/opt/AGL/helloworld-service/lib/

curl http://localhost:${PORT}/api/helloworld/ping
#For a nice display
curl http://localhost:${PORT}/api/helloworld/ping 2>/dev/null | python -m json.tool
```

[opensuse.org/LinuxAutomotive]:https://en.opensuse.org/LinuxAutomotive
[app-framework-binder]:https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/app-framework-binder
