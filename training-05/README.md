# 5. AGL Microservices Architecure

## Part 1

Take the binding that you made at training-04, you should be able to reproduce
the helloworld service with its WebUI.

Now you should implements a new verb to implements and use the event signaling
from the Application Framework Binder on your API that make a subscription
against a binding event handle.

Step should be:

- create an event handle. Simplest way to do that is to initiate a new handle at
 binding init :
  - create the init function the signature **int function()** which will make
  event handle calling `afb_daemon_make_event("EventName")`
  ```c
  struct afb_event helloEvent = afb_daemon_make_event("EventName");
  ```
  - change the field `init` in the `afbBindingV2` structure to point the init
    function.
- create new verb in the `verbs` array that handles subscription
- create the callback from that verb which will do the call to
 `afb_req_subscribe()` binder function.
 ```c
 afb_req_subscribe(request, helloEvent);
 ```
- call `afb_event_push()` on that event after a ping to push new event or
 generate an event each second using systemd event loop, or both if you got
 time.

## Part 2

To gain in flexibility AGL Application Framework implements shadow API mechanism
which let access an app to an AGL service. You have an Helloworld app which
use a WebUI, the app, and a service, the binding.

You have now to separate both. Create two separate project with one containing
the web interface. You should reconfigure the widget configuration file to
remove the `provided-api` feature since this will be separated. But keep the
feature `required-api` since WebApp call it.

Then in the other keep only the helloworld binding.

Install both on a target and confirm that WebUI correctly call the api provided
by the binding from the other target.

> **NOTE**: You doesn't need to start the helloworld service since it is
started at demand. Only access the WebUI is enough to start the helloworld
service.

## Part 3

Add another binding which interact transparently with the first service.

The example is to have another binding that will call X times `ping` verb on
the **helloworld** api passing _X_ by argument.

Write another binding with a simple verb that do X ping at once on the first
binding using `afb_service_call_sync` function.

```c
afb_service_call_sync("helloworld", "ping", queryJ, &resultJ);
```
