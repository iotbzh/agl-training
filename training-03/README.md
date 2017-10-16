# helloworld-service

A Helloworld AGL application for AGL Training 03.

## Build with XDS

You need to [declare your project](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/xds/part-1/4_build-first-app.html#declare-project-into-xds)
within XDS.

Go to your XDS dashboard which should be at http://localhost:8000/ and use the
Web interface to add your project.

### From XDS Dashboard

The you can [build using dashboard](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/xds/part-1/4_build-first-app.html#build-from-xds-dashboard)
from the build page. Just select **Project**, your **Cross SDK** and use build button:

- **Clean**: Remove your build directory
- **Pre-build**: Configure the project
- **Build**: build the project target *all*
- **Populate**: Let you transfer the built app to a target board. Only possible
 when project as been configured with **RSYNC_TARGET** and **RSYNC_PREFIX**
 variables set.

Build results could be retrieve from `build` directory.

### From command-line

[From command-line](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/xds/part-1/4_build-first-app.html#build-from-command-line):

You need to determine which is the unique id of your project. You can find this
 ID in project page of XDS dashboard or you can get it from command line using
 the --list option. This option lists all existing projects ID:

```bash
./bin/xds-exec --list

List of existing projects:
  CKI7R47-UWNDQC3_myProject
  CKI7R47-UWNDQC3_test2
  CKI7R47-UWNDQC3_test3
```

Now to refer your project, just use –id option or use XDS_PROJECT_ID environment variable.

```bash
# Add xds-exec in the PATH
export PATH=${PATH}:/opt/AGL/bin

# Create a build directory
xds-exec --id=CKI7R47-UWNDQC3_myProject --sdkid=poky-agl_aarch64_4.0.1 --url=http://localhost:8000 -- mkdir build

# Generate build system using cmake
xds-exec --id=CKI7R47-UWNDQC3_myProject --sdkid=poky-agl_aarch64_4.0.1 --url=http://localhost:8000 -- cd build && cmake ..

#- Build the project
xds-exec --id=CKI7R47-UWNDQC3_myProject --sdkid=poky-agl_aarch64_4.0.1 --url=http://localhost:8000 -- cd build && make all
```

```bash
#setup your build environement
. /xdt/sdk/environment-setup-aarch64-agl-linux
#build your application
./conf.d/autobuild/agl/autobuild package
```

## Deploy

### AGL target

```bash
export YOUR_BOARD_IP=X.X.X.X
export APP_NAME=helloworld-service
scp build/${APP_NAME}.wgt root@${YOUR_BOARD_IP}:/tmp
ssh root@${YOUR_BOARD_IP} afm-util install /tmp/${APP_NAME}.wgt
APP_VERSION=$(ssh root@${YOUR_BOARD_IP} afm-util list | grep ${APP_NAME}@ | cut -d"\"" -f4| cut -d"@" -f2)
ssh root@${YOUR_BOARD_IP} afm-util start ${APP_NAME}@${APP_VERSION}
```

## TEST

### For AGL

```bash
export YOUR_BOARD_IP=192.168.1.X
export PORT=8000
ssh root@${YOUR_BOARD_IP} afb-daemon --ws-client=unix:/run/user/0/apis/ws/helloworld --port=${PORT} --token='x' -v

#On an other terminal
ssh root@${YOUR_BOARD_IP} afb-client-demo -H 127.0.0.1:${PORT}/api?token=x helloworld ping true
#or
curl http://${YOUR_BOARD_IP}:${PORT}/api/helloworld/ping?token=x
#For a nice display
curl http://${YOUR_BOARD_IP}:${PORT}/api/helloworld/ping?token=x 2>/dev/null | python -m json.tool
```

[opensuse.org/LinuxAutomotive]:https://en.opensuse.org/LinuxAutomotive
[app-framework-binder]:https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/app-framework-binder
