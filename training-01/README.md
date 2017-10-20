# Training Roadmap

## 1. General AGL Architecture

- topics:
  - binder / binding
  - APIs definition
  - transport
- exercise: none

## 2. Native Development setup

- topics:
  - native environment - why ?
  - native setup (RPM,DEB packages)
  - IDE setup (netbeans ...)
- exercise:
  - helloworld app (simple HTML5 UI, simple binding with a ping verb, no events)

## 3. Cross Development setup

- topics:
  - why XDS ?
  - docker container setup
  - VirtualBox setup (target emulation) - is it an option ???
  - XDS setup
- exercise:
  - rebuild helloworld app (same as in previous module), deploy, run & debug

## 4. Application development workflow

- topics:
  - various types of applications: natives, html5, QML, services, legacy...
  - application framework usage (afm-util)
  - sources folder setup: app-templates, cmakefiles ...
  - widget creation: config.xml explained
  - monitoring
- exercise:
  - rebuild, package, deploy & test app

## 5. AGL Microservices Architecture

- topics:
  - events
  - shadow APIs
  - subcalls
- exercises:
  - part 1: helloworld: add events in main service, subscribe, received events
  - part 2: helloworld: split app + service
  - part 3: helloworld+dummyAPI, subcalls
