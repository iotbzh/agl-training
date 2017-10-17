# Developper Guide: use AGL CMake Templates

## Abstract

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
