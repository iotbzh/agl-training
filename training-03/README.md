# 3. Cross Development

This section describes how to cross build Helloworld AGL application and deploy
it on a real target running AGL.

## Build with XDS

You need to [declare your project](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/xds/part-1/4_build-first-app.html#declare-project-into-xds)
within XDS.

Go to your XDS dashboard which should be at <http://localhost:8000/> and use the
Web interface to add your project.

### From XDS Dashboard

Then you can [cross build using dashboard](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/xds/part-1/4_build-first-app.html#build-from-xds-dashboard)
from the build page. Just select the **Project**, your **Cross SDK** and use
build button:

- **Clean**: Remove your build directory
- **Pre-build**: Configure the project
- **Build**: build the project target *all*
- **Populate**: Let you transfer the built app to a target board. Only possible
 when project as been configured with **RSYNC_TARGET** and **RSYNC_PREFIX**
 variables set.

Build results could be retrieve from `build` directory.

### From command-line

Full document about how to build [from command-line](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/xds/part-1/4_build-first-app.html#build-from-command-line).

You need to determine which is the unique id of your project. You can find this
 ID in project page of XDS dashboard or you can get it from command line using
 the --list option. This option lists all existing projects ID:

```bash
xds-exec --list

List of existing projects:
  CKI7R47-UWNDQC3_myProject
  CKI7R47-UWNDQC3_test2
  CKI7R47-UWNDQC3_test3
```

Now to refer your project, just use `--id` option or use `xds-project.conf` file
to set project id, xds server url,...
Please refer to [Build from command line](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/xds/part-1/4_build-first-app.html#build-from-command-line)
doc chapter for more details about `xds-project.conf` file.

```bash
# Create a build directory
# for example YOUR_PROJECT_DIR=$HOME/xds-workspace/agl-training/agl-training-03
cd ${YOUR_PROJECT_DIR} && mkdir build

# Edit auto-created xds-project.conf file or create a new one
# Note that you MUST update YOUR_BOARD_IP string by the ip or the name of your target
cat > $YOUR_PROJECT_DIR/xds-project.conf << EOF
  export XDS_SERVER_URL=localhost:8000
  export XDS_PROJECT_ID=CKI7R47-UWNDQC3_myProject
  export XDS_SDK_ID=poky-agl_aarch64_4.0.1

  export RSYNC_TARGET=root@YOUR_BOARD_IP
  export RSYNC_PREFIX=/tmp
EOF

# Generate build system using cmake
cd build
xds-exec --config=../xds-project.conf -- cmake ../

# Build the project
xds-exec --config=../xds-project.conf -- make all
```

Now package your application:

```bash
# Package your application to a widget
cd build
xds-exec --config=../xds-project.conf -- make widget
```

## Deploy

### AGL target

```bash
xds-exec --config=./xds-project.conf -- build/target/install-wgt-on-root@YOUR_BOARD_IP.sh
```

## TEST

### For AGL

```bash
export YOUR_BOARD_IP=192.168.1.X
export PORT=1234
export TOKEN=""

#Start application on board
xds-exec --config=./xds-project.conf -- build/target/start-on-root@${YOUR_BOARD_IP}.sh

#On an other terminal
ssh root@${YOUR_BOARD_IP} afb-client-demo -H 127.0.0.1:${PORT}/api?token=$TOKEN helloworld ping true
#or
curl http://${YOUR_BOARD_IP}:${PORT}/api/helloworld/ping?token=$TOKEN
#For a nice display
curl http://${YOUR_BOARD_IP}:${PORT}/api/helloworld/ping?token=$TOKEN 2>/dev/null | python -m json.tool
```

[opensuse.org/LinuxAutomotive]:https://en.opensuse.org/LinuxAutomotive
[app-framework-binder]:https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/app-framework-binder
