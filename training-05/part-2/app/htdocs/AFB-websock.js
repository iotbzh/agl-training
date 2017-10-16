var urlws;
var urlhttp;

AFB = function(base, initialtoken){

urlws = "ws://"+window.location.host+"/"+base;
urlhttp = "http://"+window.location.host+"/"+base;

/*********************************************/
/****                                     ****/
/****             AFB_context             ****/
/****                                     ****/
/*********************************************/
var AFB_context;
{
	var UUID = undefined;
	var TOKEN = initialtoken;

	var context = function(token, uuid) {
		this.token = token;
		this.uuid = uuid;
	}

	context.prototype = {
		get token() {return TOKEN;},
		set token(tok) {if(tok) TOKEN=tok;},
		get uuid() {return UUID;},
		set uuid(id) {if(id) UUID=id;}
	};

	AFB_context = new context();
}
/*********************************************/
/****                                     ****/
/****             AFB_websocket           ****/
/****                                     ****/
/*********************************************/
var AFB_websocket;
{
	var CALL = 2;
	var RETOK = 3;
	var RETERR = 4;
	var EVENT = 5;

	var PROTO1 = "x-afb-ws-json1";

	AFB_websocket = function(onopen, onabort) {
		var u = urlws;
		if (AFB_context.token) {
			u = u + '?x-afb-token=' + AFB_context.token;
			if (AFB_context.uuid)
				u = u + '&x-afb-uuid=' + AFB_context.uuid;
		}
		this.ws = new WebSocket(u, [ PROTO1 ]);
		this.pendings = {};
		this.awaitens = {};
		this.counter = 0;
		this.ws.onopen = onopen.bind(this);
		this.ws.onerror = onerror.bind(this);
		this.ws.onclose = onclose.bind(this);
		this.ws.onmessage = onmessage.bind(this);
		this.onopen = onopen;
		this.onabort = onabort;
		this.onclose = onabort;
	}

	function onerror(event) {
		var f = this.onabort;
		if (f) {
			delete this.onopen;
			delete this.onabort;
			f && f(this);
		}
		this.onerror && this.onerror(this);
	}

	function onopen(event) {
		var f = this.onopen;
		delete this.onopen;
		delete this.onabort;
		f && f(this);
	}

	function onclose(event) {
		for (var id in this.pendings) {
			var ferr = this.pendings[id].onerror;
			ferr && ferr(null, this);
		}
		this.pendings = {};
		this.onclose && this.onclose();
	}

	function fire(awaitens, name, data) {
		var a = awaitens[name];
		if (a)
			a.forEach(function(handler){handler(data);});
		var i = name.indexOf("/");
		if (i >= 0) {
			a = awaitens[name.substring(0,i)];
			if (a)
				a.forEach(function(handler){handler(data);});
		}
		a = awaitens["*"];
		if (a)
			a.forEach(function(handler){handler(data);});
	}

	function reply(pendings, id, ans, offset) {
		if (id in pendings) {
			var p = pendings[id];
			delete pendings[id];
			var f = p[offset];
			f(ans);
		}
	}

	function onmessage(event) {
		var obj = JSON.parse(event.data);
		var code = obj[0];
		var id = obj[1];
		var ans = obj[2];
		AFB_context.token = obj[3];
		switch (code) {
		case RETOK:
			reply(this.pendings, id, ans, 0);
			break;
		case RETERR:
			reply(this.pendings, id, ans, 1);
			break;
		case EVENT:
		default:
			fire(this.awaitens, id, ans);
			break;
		}
	}

	function close() {
		this.ws.close();
                this.onabort();
	}

	function call(method, request) {
		return new Promise((function(resolve, reject){
			var id, arr;
			do {
			   id = String(this.counter = 4095 & (this.counter + 1));
			} while (id in this.pendings);
			this.pendings[id] = [ resolve, reject ];
			arr = [CALL, id, method, request ];
			if (AFB_context.token) arr.push(AFB_context.token);
			this.ws.send(JSON.stringify(arr));
		}).bind(this));
	}

	function onevent(name, handler) {
		var id = name;
		var list = this.awaitens[id] || (this.awaitens[id] = []);
		list.push(handler);
	}

	AFB_websocket.prototype = {
		close: close,
		call: call,
		onevent: onevent
	};
}
/*********************************************/
/****                                     ****/
/****                                     ****/
/****                                     ****/
/*********************************************/
return {
	context: AFB_context,
	ws: AFB_websocket
};
};

