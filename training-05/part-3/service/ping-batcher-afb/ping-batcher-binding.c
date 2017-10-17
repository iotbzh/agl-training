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
#include <string.h>
#include <wrap-json.h>
#include <time.h>
#include <systemd/sd-event.h>

#define AFB_BINDING_VERSION 2
#include <afb/afb-binding.h>

static afb_event pingBatcherEvent;
static const char *partnerName = "helloworld";

static void pingBatcher(struct afb_req request)
{
	int total = 0;
	json_object *result, *queryJ = afb_req_json(request);
	int err = wrap_json_unpack(queryJ, "{si}", "total", &total);
	if(err)
	{
		afb_req_fail_f(request, "Cannot unpack JSON %s", json_object_to_json_string(queryJ));
		return;
	}

	while(total > 0)
	{
		total --;
		if(afb_service_call_sync(partnerName, "ping", queryJ, &result) < 0)
		{
			afb_req_fail_f(request, "Cannot invoke ping on %s api", partnerName);
			return;
		}
		afb_req_success_f(request, result, "Ping on %s OK", partnerName);
	}
}

static void subscribe(struct afb_req request)
{
	json_object *result, *queryJ = afb_req_json(request);
	if(afb_service_call_sync(partnerName, "subscribe", queryJ, &result) < 0)
	{
		afb_req_fail_f(request, "Cannot invoke subscribe on %s api", partnerName);
		return;
	}
	if(afb_req_subscribe(request, pingBatcherEvent) < 0)
	{
		afb_req_fail(request, NULL, "Cannot subscribe");
		return;
	}
	afb_req_success_f(request, result, "Subscribe on %s OK", partnerName);
}

static void set_partner(struct afb_req request)
{
	json_object *queryJ = afb_req_json(request);

	int err = wrap_json_unpack(queryJ, "{ss}", "partnerName", &partnerName);
	if(err)
	{
		afb_req_fail(request, "ERROR: wrong JSON object provided must be {'partnerName': '<name of the other helloworld api>'}", NULL);
	}
	afb_req_success_f(request, NULL, "New partner name: %s", partnerName);
}

int init()
{
	// Create an event handle to be used within this binding.
	// if event isn't valid then init failed and binding doesn't start
	pingBatcherEvent = afb_daemon_make_event("Helloworld Client");
	return afb_event_is_valid(pingBatcherEvent);
}

void evtListener(const char* evtName, json_object* dataJ)
{
	// Just relay event with the local event handle pingBatcherEvent
	afb_event_push(pingBatcherEvent, dataJ);
}

static const struct afb_verb_v2 verbs[] = {
	{.verb = "ping_batch", .session = AFB_SESSION_NONE, .callback = pingBatcher, .auth = NULL},
	{.verb = "subscribe", .session = AFB_SESSION_NONE, .callback = subscribe, .auth = NULL},
	{.verb = "set_partner", .session = AFB_SESSION_NONE, .callback = set_partner, .auth = NULL},
	{NULL}
};

const struct afb_binding_v2 afbBindingV2 = {
	.api = "ping-batcher",
	.specification = NULL,
	.verbs = verbs,
	.preinit = NULL,
	.init = init,
	.onevent = evtListener,
	.noconcurrency = 0
};
