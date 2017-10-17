/*
 * Copyright (C) 2016, 2017 "IoT.bzh"
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <wrap-json.h>
#include <systemd/sd-event.h>

#define AFB_BINDING_VERSION 2
#include <afb/afb-binding.h>

static afb_event helloEvt;
static int evtCount = 10;

static void pingSample(struct afb_req request)
{
    static int pingcount = 0;

    afb_req_success_f(request, json_object_new_int(pingcount), "Ping count = %d", pingcount);

    AFB_NOTICE("Verbosity macro at level notice invoked at ping invocation count = %d", pingcount);

    pingcount++;
}

void evtPush()
{
    json_object *evtData = json_object_new_object();
    json_object *countJ = json_object_new_int(evtCount);

    json_object_object_add(evtData, "Event count: ", countJ);

    afb_event_push(helloEvt, evtData);
}

int timerNext (sd_event_source* source, uint64_t usec, void* context) {
    // Rearm timer if needed
    evtCount --;
    if (evtCount == 0) {
        evtPush();
        sd_event_source_unref(source);
        return 0;
    }
    else {
        evtPush();
        // otherwise validate timer for a new run
        sd_event_now(afb_daemon_get_event_loop(), CLOCK_MONOTONIC, &usec);
        sd_event_source_set_enabled(source, SD_EVENT_ONESHOT);
        sd_event_source_set_time(source, usec + 1000000);
    }

    return 0;
}

void timerEvtStart() {
    uint64_t usec;
    evtCount = 10;
    sd_event_source *evtSource;

    // set a timer with ~250us accuracy
    sd_event_now(afb_daemon_get_event_loop(), CLOCK_MONOTONIC, &usec);
    sd_event_add_time(afb_daemon_get_event_loop(), &evtSource, CLOCK_MONOTONIC, usec+100000, 250, timerNext, NULL);
}

static void subscribe(struct afb_req request)
{
    int err;

    AFB_NOTICE ("Subscribe Function");

    timerEvtStart();

    // subscribe hello client to hello event
    err = afb_req_subscribe(request, helloEvt);
    if (err) {
        afb_req_fail (request, "Fail-Event", "Fail to subscribe to helloEvt");
        goto OnErrorExit;
    }

    afb_req_success (request, NULL, "Subscribe-Event");

OnErrorExit:
    return;
}


// testArgsSample - return success only if argument is set to {"cezam": "open"}
static void testArgsSample(struct afb_req request)
{
	json_object *tmpJ;
	json_object *res = json_object_new_object();
	json_object *queryJ = afb_req_json(request);

	json_bool success = json_object_object_get_ex(queryJ, "cezam", &tmpJ);
	if (!success) {
		afb_req_fail_f(request, "ERROR", "key cezam not found in '%s'", json_object_get_string(queryJ));
		return;
	}

	if (json_object_get_type(tmpJ) != json_type_string) {
		afb_req_fail(request, "ERROR", "key cezam not a string");
		return;
	}

	if (strncmp(json_object_get_string(tmpJ), "open", 4) == 0) {
		json_object_object_add(res, "code", json_object_new_int(123456789));
		afb_req_success(request, res, NULL);
		return;
	}

	afb_req_fail_f(request, "ERROR", "value of cezam (%s) is not the expected one.", json_object_get_string(queryJ));
}

int init()
{
    helloEvt = afb_daemon_make_event("Awesome Hello Event");
    return afb_event_is_valid(helloEvt);
}

static const struct afb_verb_v2 verbs[] = {
	{.verb = "ping", .session = AFB_SESSION_NONE, .callback = pingSample, .auth = NULL},
    {.verb = "subscribe", .session = AFB_SESSION_NONE, .callback = subscribe, .auth = NULL},
	{.verb = "testargs", .session = AFB_SESSION_NONE, .callback = testArgsSample, .auth = NULL},
	{NULL}
};

const struct afb_binding_v2 afbBindingV2 = {
	.api = "helloworld",
	.specification = NULL,
	.verbs = verbs,
	.preinit = NULL,
	.init = init,
	.onevent = NULL,
	.noconcurrency = 0
};
