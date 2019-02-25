yorick-zeromq
=============

A simple ZMQ plugin for yorick.

The following ZMQ function are implemented:

  -  zeromq plugin/wrapper for yorick
  -  Available functions:
  -  zmq_version;
  -  zmq_ctx_new;
  -  zmq_ctx_get;
  -  zmq_ctx_set;
  -  zmq_socket;
  -  zmq_bind;
  -  zmq_unbind;
  -  zmq_recv
  -  zmq_send
  -  zmq_connect;
  -  zmq_disconnect;
  -  zmq_test;
  -  zmq_getsockopt
  -  zmq_setsockopt

Zero-MQ is a high level implementation of ethernet sockets that allows for easy implementation of TCP/IP communication. In Yorick, establishing a socket and communication is done generally with a few instructions:

```C
// Create a ZMQ context:
ctx = zmq_ctx_new();
// get a socket using Request/Reply
sub = zmq_socket(ctx, ZMQ_REQ);
// connect to a remote server (that has a ZMQ counterpart)
rc  = zmq_connect (comsub, "tcp://"+zmq_server_ip+":"+zmq_com_port);
// Send a request (e.g. if a REQ-REP has been selected)
rc = zmq_send(telsub,"N2PI",option);
// get the reply
ar = zmq_recv(telsub,char,msglen,ZMQ_OPTION);
// When done, disconnect
status = zmq_disconnect(telsub,"tcp://"+zmq_server_ip+":"+zmq_tel_port);
```

See zmq.i and zmq_examples.i for usage.
