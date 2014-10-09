/*
 * zeromq.c
 * wrapper routines for the zeromq C library
 *
 * Copyright (c) 2013, Francois RIGAUT (francois.rigaut@anu.edu.au)
 *
 * This program is free software; you can redistribute it and/or  modify it
 * under the terms of the GNU General Public License  as  published  by the
 * Free Software Foundation; either version 2 of the License,  or  (at your
 * option) any later version.
 *
 * This program is distributed in the hope  that  it  will  be  useful, but
 * WITHOUT  ANY   WARRANTY;   without   even   the   implied   warranty  of
 * MERCHANTABILITY or  FITNESS  FOR  A  PARTICULAR  PURPOSE.   See  the GNU
 * General Public License for more details (to receive a  copy  of  the GNU
 * General Public License, write to the Free Software Foundation, Inc., 675
 * Mass Ave, Cambridge, MA 02139, USA).
 *
 */

#define ZMQ_DEBUG 0

#include <zmq.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include "ydata.h"
#include "pstdlib.h"

//:::::::::::::::::::::::::::::::::::::
/* OPAQUE OBJECTS */

/* 1) 0MQ context */
typedef struct _context object_context;

static void on_free_context(void *);

static y_userobj_t zmq_context_opaque = {
  "0MQ context", on_free_context, NULL, NULL, NULL, NULL
};

struct _context {
  void *context;
};

static void on_free_context(void *addr)
{
  object_context *this = (object_context *)addr;
  if (this->context) zmq_ctx_destroy(this->context);
}

static object_context *get_context(int iarg)
{
  void *addr = yget_obj(iarg, &zmq_context_opaque);
  if (! addr) y_error("expecting ZMQ context");
  return (object_context *)addr;
}

/* 2) 0MQ socket */
typedef struct _socket object_socket;

static void on_free_socket(void *);

static y_userobj_t zmq_socket_opaque = {
  "0MQ socket", on_free_socket, NULL, NULL, NULL, NULL
};

struct _socket {
  void *socket;
};

static object_socket *get_socket(int iarg)
{
  void *addr = yget_obj(iarg, &zmq_socket_opaque);
  if (! addr) y_error("expecting ZMQ socket");
  return (object_socket *)addr;
}

static void on_free_socket(void *addr)
{
  object_socket *this = (object_socket *)addr;
  if (this->socket) zmq_close(this->socket);
}

/* END OPAQUE OBJECTS */
//:::::::::::::::::::::::::::::::::::::

/* Built in functions.
   Refer to 0MQ documentation.
*/

void Y_zmq_version(int argc)
{
  int major, minor, patch;
  zmq_version (&major, &minor, &patch); 
  long dims[Y_DIMSIZE];
  dims[0] = 1; dims[1] = 3;
  int *a = ypush_i(dims);
  a[0] = major;
  a[1] = minor;
  a[2] = patch;
}


void Y_zmq_ctx_new(int argc)
{
  object_context *this;
  this = (object_context *)ypush_obj(&zmq_context_opaque, sizeof(object_context));
  this->context = zmq_ctx_new();
  if (!this->context) y_error("ZMQ: Unable to create new context");
}


void Y_zmq_ctx_get(int argc)
{
  if (argc!=2) y_error("zmq_ctx_get takes exactly two arguments");
  void *context = get_context(argc-1)->context;
  int option = ygets_i(argc-2);
  object_socket *this;
  this = (object_socket *)ypush_obj(&zmq_socket_opaque, sizeof(object_socket));
  ypush_int(zmq_ctx_get(context, option));
}


void Y_zmq_ctx_set(int argc)
{
  if (argc!=3) y_error("zmq_ctx_set takes exactly three arguments");
  void *context = get_context(argc-1)->context;
  int option = ygets_i(argc-2);
  int value  = ygets_i(argc-3);
  object_socket *this;
  this = (object_socket *)ypush_obj(&zmq_socket_opaque, sizeof(object_socket));
  ypush_int(zmq_ctx_set(context, option, value));
} 


void Y_zmq_socket(int argc)
{
  if (argc!=2) y_error("zmq_socket takes exactly two arguments");
  void *context = get_context(argc-1)->context;
  int type = ygets_i(argc-2);
  object_socket *this;
  this = (object_socket *)ypush_obj(&zmq_socket_opaque, sizeof(object_socket));
  this->socket = zmq_socket(context, type);
  if (!this->socket) y_error("ZMQ: Unable to create new socket");
}


void Y__zmq_getsockopt(int argc)
{
  void *socket = get_socket(argc-1)->socket;
  int option = ygets_i(argc-2);
  /*
  void *value= ygets_
  size_t *len[1];
  int status;
  status = zmq_getsockopt(socket, option, value, *len);
  */
}


void Y__zmq_setsockopt(int argc)
{
  if (argc!=4) y_error("zmq_setsockopt takes exactly four arguments");
  void *socket = get_socket(argc-1)->socket;
  int option = ygets_i(argc-2);
  void *value = ygets_p(argc-3);
  int len = ygets_i(argc-4);
  ypush_int(zmq_setsockopt(socket, option, value, len));
}


void Y_zmq_bind(int argc)
{
  if (argc!=2) y_error("zmq_bind takes exactly two arguments");
  void *socket = get_socket(argc-1)->socket;
  long n, dims[Y_DIMSIZE];
  char **endpoint = ygeta_q(0, &n, dims);
  if (ZMQ_DEBUG) printf("Binding to %s\n",*endpoint);
  ypush_int(zmq_bind(socket, *endpoint));
}

void Y_zmq_unbind(int argc)
{
  if (argc!=2) y_error("zmq_unbind takes exactly two arguments");
  void *socket = get_socket(argc-1)->socket;
  long n, dims[Y_DIMSIZE];
  char **endpoint = ygeta_q(0, &n, dims);
  if (ZMQ_DEBUG) printf("Unbinding from %s\n",*endpoint);
  ypush_int(zmq_unbind(socket, *endpoint));
}

void Y_zmq_connect(int argc)
{
  if (argc!=2) y_error("zmq_connect takes exactly two arguments");
  void *socket = get_socket(argc-1)->socket;
  long n, dims[Y_DIMSIZE];
  char **endpoint = ygeta_q(0, &n, dims);
  if (ZMQ_DEBUG) printf("Connecting to %s\n",*endpoint);
  ypush_int(zmq_connect(socket, *endpoint));
}

void Y_zmq_disconnect(int argc)
{
  if (argc!=2) y_error("zmq_disconnect takes exactly two arguments");
  void *socket = get_socket(argc-1)->socket;
  long n, dims[Y_DIMSIZE];
  char **endpoint = ygeta_q(0, &n, dims);
  if (ZMQ_DEBUG) printf("Disconnecting from %s\n",*endpoint);
  ypush_int(zmq_disconnect(socket, *endpoint));
}


void Y__zmq_send(int argc)
{
  if (argc!=4) y_error("zmq_send takes exactly four arguments");
  void *socket = get_socket(argc-1)->socket;
  void *buf = ygets_p(argc-2);
  size_t len = (size_t) ygets_l(argc-3);
  int flags = ygets_i(argc-4);
  ypush_int(zmq_send(socket,buf,len,flags));
}


void Y__zmq_recv(int argc)
{
  if (argc!=4) y_error("zmq_send takes exactly four arguments");
  void *socket = get_socket(argc-1)->socket;
  void *buf = ygets_p(argc-2);
  size_t len = (size_t) ygets_l(argc-3);
  int flags = ygets_i(argc-4);
  ypush_int(zmq_recv(socket,buf,len,flags));
}


void Y_zmq_special(int argc)
{
  int value = 1;
  void *socket = get_socket(argc-1)->socket;
  zmq_setsockopt(socket, ZMQ_RCVHWM, &value, sizeof(value));
}

void Y_zmq_special2(int argc)
{
  int value = 1;
  void *socket = get_socket(argc-1)->socket;
  zmq_setsockopt(socket, ZMQ_SNDHWM, &value, sizeof(value));
}


void Y_zmq_special3(int argc)
{
  void *socket = get_socket(argc-1)->socket;
  
  int sndhwm;
  size_t sndhwm_size = sizeof (sndhwm);
  zmq_getsockopt (socket, ZMQ_SNDHWM, &sndhwm, &sndhwm_size);
  int rcvhwm;
  size_t rcvhwm_size = sizeof (rcvhwm);
  zmq_getsockopt (socket, ZMQ_RCVHWM, &rcvhwm, &rcvhwm_size);

  printf("HWM: SND=%d  RCV=%d\n",sndhwm,rcvhwm);
}


void Y_zmq_test(int argc)
{
  long n, dims[Y_DIMSIZE];
  char **msg;
  dims[0] = 0;
  msg = ypush_q(dims);
  msg[0] = p_strcpy("celine");
  n = strlen(*msg);
  printf("Got %s [length %d]\n",*msg,n);
}

/* 0MQ constants */

void Y__EAGAIN(int argc) { ypush_int(EAGAIN); }
void Y__ENOTSUP(int argc) { ypush_int(ENOTSUP); }
void Y__EFSM(int argc) { ypush_int(EFSM); }  
void Y__ETERM(int argc) { ypush_int(ETERM); }
void Y__ENOTSOCK(int argc) { ypush_int(ENOTSOCK); }
void Y__EINTR(int argc) { ypush_int(EINTR); }
void Y__EINVAL(int argc) { ypush_int(EINVAL); }

void Y__ZMQ_IO_THREADS(int argc) { ypush_int(ZMQ_IO_THREADS); }
void Y__ZMQ_MAX_SOCKETS(int argc) { ypush_int(ZMQ_MAX_SOCKETS); }
void Y__ZMQ_PAIR(int argc) { ypush_int(ZMQ_PAIR); }
void Y__ZMQ_PUB(int argc) { ypush_int(ZMQ_PUB); }
void Y__ZMQ_SUB(int argc) { ypush_int(ZMQ_SUB); }
void Y__ZMQ_REQ(int argc) { ypush_int(ZMQ_REQ); }
void Y__ZMQ_REP(int argc) { ypush_int(ZMQ_REP); }
void Y__ZMQ_DEALER(int argc) { ypush_int(ZMQ_DEALER); }
void Y__ZMQ_ROUTER(int argc) { ypush_int(ZMQ_ROUTER); }
void Y__ZMQ_PULL(int argc) { ypush_int(ZMQ_PULL); }
void Y__ZMQ_PUSH(int argc) { ypush_int(ZMQ_PUSH); }
void Y__ZMQ_XPUB(int argc) { ypush_int(ZMQ_XPUB); }
void Y__ZMQ_XSUB(int argc) { ypush_int(ZMQ_XSUB); }
void Y__ZMQ_AFFINITY(int argc) { ypush_int(ZMQ_AFFINITY); }
void Y__ZMQ_IDENTITY(int argc) { ypush_int(ZMQ_IDENTITY); }
void Y__ZMQ_SUBSCRIBE(int argc) { ypush_int(ZMQ_SUBSCRIBE); }
void Y__ZMQ_UNSUBSCRIBE(int argc) { ypush_int(ZMQ_UNSUBSCRIBE); }
void Y__ZMQ_RATE(int argc) { ypush_int(ZMQ_RATE); }
void Y__ZMQ_RECOVERY_IVL(int argc) { ypush_int(ZMQ_RECOVERY_IVL); }
void Y__ZMQ_SNDBUF(int argc) { ypush_int(ZMQ_SNDBUF); }
void Y__ZMQ_RCVBUF(int argc) { ypush_int(ZMQ_RCVBUF); }
void Y__ZMQ_RCVMORE(int argc) { ypush_int(ZMQ_RCVMORE); }
void Y__ZMQ_FD(int argc) { ypush_int(ZMQ_FD); }
void Y__ZMQ_EVENTS(int argc) { ypush_int(ZMQ_EVENTS); }
void Y__ZMQ_TYPE(int argc) { ypush_int(ZMQ_TYPE); }
void Y__ZMQ_LINGER(int argc) { ypush_int(ZMQ_LINGER); }
void Y__ZMQ_RECONNECT_IVL(int argc) { ypush_int(ZMQ_RECONNECT_IVL); }
void Y__ZMQ_BACKLOG(int argc) { ypush_int(ZMQ_BACKLOG); }
void Y__ZMQ_RECONNECT_IVL_MAX(int argc) { ypush_int(ZMQ_RECONNECT_IVL_MAX); }
void Y__ZMQ_MAXMSGSIZE(int argc) { ypush_int(ZMQ_MAXMSGSIZE); }
void Y__ZMQ_SNDHWM(int argc) { ypush_int(ZMQ_SNDHWM); }
void Y__ZMQ_RCVHWM(int argc) { ypush_int(ZMQ_RCVHWM); }
void Y__ZMQ_MULTICAST_HOPS(int argc) { ypush_int(ZMQ_MULTICAST_HOPS); }
void Y__ZMQ_RCVTIMEO(int argc) { ypush_int(ZMQ_RCVTIMEO); }
void Y__ZMQ_SNDTIMEO(int argc) { ypush_int(ZMQ_SNDTIMEO); }
void Y__ZMQ_IPV4ONLY(int argc) { ypush_int(ZMQ_IPV4ONLY); }
void Y__ZMQ_LAST_ENDPOINT(int argc) { ypush_int(ZMQ_LAST_ENDPOINT); }
void Y__ZMQ_ROUTER_MANDATORY(int argc) { ypush_int(ZMQ_ROUTER_MANDATORY); }
void Y__ZMQ_TCP_KEEPALIVE(int argc) { ypush_int(ZMQ_TCP_KEEPALIVE); }
void Y__ZMQ_TCP_KEEPALIVE_CNT(int argc) { ypush_int(ZMQ_TCP_KEEPALIVE_CNT); }
void Y__ZMQ_TCP_KEEPALIVE_IDLE(int argc) { ypush_int(ZMQ_TCP_KEEPALIVE_IDLE); }
void Y__ZMQ_TCP_KEEPALIVE_INTVL(int argc) { ypush_int(ZMQ_TCP_KEEPALIVE_INTVL); }
void Y__ZMQ_TCP_ACCEPT_FILTER(int argc) { ypush_int(ZMQ_TCP_ACCEPT_FILTER); }
void Y__ZMQ_DELAY_ATTACH_ON_CONNECT(int argc) { ypush_int(ZMQ_DELAY_ATTACH_ON_CONNECT); }
void Y__ZMQ_XPUB_VERBOSE(int argc) { ypush_int(ZMQ_XPUB_VERBOSE); }
void Y__ZMQ_MORE(int argc) { ypush_int(ZMQ_MORE); }
void Y__ZMQ_DONTWAIT(int argc) { ypush_int(ZMQ_DONTWAIT); }
void Y__ZMQ_SNDMORE(int argc) { ypush_int(ZMQ_SNDMORE); }
void Y__ZMQ_EVENT_CONNECTED(int argc) { ypush_int(ZMQ_EVENT_CONNECTED); }
void Y__ZMQ_EVENT_CONNECT_DELAYED(int argc) { ypush_int(ZMQ_EVENT_CONNECT_DELAYED); }
void Y__ZMQ_EVENT_CONNECT_RETRIED(int argc) { ypush_int(ZMQ_EVENT_CONNECT_RETRIED); }
void Y__ZMQ_EVENT_LISTENING(int argc) { ypush_int(ZMQ_EVENT_LISTENING); }
void Y__ZMQ_EVENT_BIND_FAILED(int argc) { ypush_int(ZMQ_EVENT_BIND_FAILED); }
void Y__ZMQ_EVENT_ACCEPTED(int argc) { ypush_int(ZMQ_EVENT_ACCEPTED); }
void Y__ZMQ_EVENT_ACCEPT_FAILED(int argc) { ypush_int(ZMQ_EVENT_ACCEPT_FAILED); }
void Y__ZMQ_EVENT_CLOSED(int argc) { ypush_int(ZMQ_EVENT_CLOSED); }
void Y__ZMQ_EVENT_CLOSE_FAILED(int argc) { ypush_int(ZMQ_EVENT_CLOSE_FAILED); }
void Y__ZMQ_EVENT_DISCONNECTED(int argc) { ypush_int(ZMQ_EVENT_DISCONNECTED); }
void Y__ZMQ_POLLIN(int argc) { ypush_int(ZMQ_POLLIN); }
void Y__ZMQ_POLLOUT(int argc) { ypush_int(ZMQ_POLLOUT); }
void Y__ZMQ_POLLERR(int argc) { ypush_int(ZMQ_POLLERR); }