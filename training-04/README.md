# helloworld-service

A Helloworld AGL application for AGL Training 04.

Goal is to create a helloworld application form scratch for an AGL
system. As you already know how to build an app using XDS to cross build
for a target board as well as build using native OS, you are free to
choose the way you'll build and test.

## Instructions

Step by step app building flow:

1. create empty git repo
 ```bash
 mkdir my-helloworld
 cd my-helloworld
 export PROJECT_DIR=$(pwd)
 git init
 ```
2. add `app-template` submodule to the repo:
 ```bash
 cd ${PROJECT_DIR}
 git submodule add https://gerrit.automotivelinux.org/gerrit/apps/app-templates conf.d/app-templates
 ```
3. Initialize your project by copying and editing the samples files:
 ```bash
 cd ${PROJECT_DIR}/conf.d/
 mkdir -p cmake wgt
  cp app-templates/samples.d/CMakeLists.txt ${PROJECT_DIR}/CMakeLists.txt
 cp app-templates/samples.d/config.xml.in.sample wgt/config.xml.in
 cp app-templates/samples.d/config.cmake.sample cmake/config.cmake
 vim cmake/config.cmake
 ```
4. create and develop the AGL service target:
 ```bash
 cd ${PROJECT_DIR}
 mkdir -p afb-helloworld
 cd afb-helloworld
 touch helloworld-service.c CMakeLists.txt
 ```

## Build

Use instructions learnt from training 02-03 to build your app

## Test

Use instructions learnt from training 02-03 to test your app
