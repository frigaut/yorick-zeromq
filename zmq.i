/* DOCUMENT zmq
*  zeromq plugin/wrapper for yorick
*  Available functions:
*  zmq_version;
*  zmq_ctx_new;
*  zmq_ctx_get;
*  zmq_ctx_set;
*  zmq_socket;
*  zmq_bind;
*  zmq_unbind;
*  zmq_recv
*  zmq_send
*  zmq_connect;
*  zmq_disconnect;
*  zmq_test;
*  zmq_getsockopt
*  zmq_setsockopt
*  See zmq.i and zmq_examples.i for usage
*/

plug_in,"zmq";


func zmq_setsockopt(socket, option, value)
{
  if (structof(value)==string) value = strchar(value)(1:-1); // -> in char
  return _zmq_setsockopt(socket,option,&value,sizeof(value));
}

func zmq_getsockopt(socket, option)
{
  return _zmq_getsockopt(socket,option);
}

func zmq_send(socket,data,flags)
{
  if (flags==[]) flags=0;
  if (structof(data)==string) data = strchar(data)(1:-1);
  return _zmq_send(socket,&data,sizeof(data),flags);
}


func zmq_recv(socket,type,nelem,flags)
{
  if (flags==[]) flags=0;
  otype = type;
  if (otype==string) type=char;
  totsize = sizeof(type)*nelem;
  data = array(type,nelem);
  nbytes = _zmq_recv(socket,&data,totsize,flags);
  if (zmq_debug>10) write,format="received %d bytes\n",nbytes;
  if (nbytes==-1) return;
  data = data(1:nbytes/sizeof(type));
  if (otype==string) data = strchar(_(data,0));
  return data;
}


extern zmq_version;
extern zmq_ctx_new;
extern zmq_ctx_get;
extern zmq_ctx_set;
extern zmq_socket;
extern _zmq_getsockopt;
extern _zmq_setsockopt;
extern zmq_bind;
extern zmq_unbind;
extern zmq_connect;
extern zmq_disconnect;
extern _zmq_send;
extern _zmq_recv;
extern zmq_test;
extern zmq_special;
extern zmq_special2;
extern zmq_special3;


extern _EAGAIN;                       EAGAIN = _EAGAIN();
extern _ENOTSUP;                      ENOTSUP = _ENOTSUP();
extern _EFSM;                         EFSM = _EFSM();
extern _ETERM;                        ETERM = _ETERM();
extern _ENOTSOCK;                     ENOTSOCK = _ENOTSOCK();
extern _EINTR;                        EINTR = _EINTR();
extern _EINVAL;                       EINVAL = _EINVAL();

extern _ZMQ_IO_THREADS;               ZMQ_IO_THREADS = _ZMQ_IO_THREADS();
extern _ZMQ_MAX_SOCKETS;              ZMQ_MAX_SOCKETS = _ZMQ_MAX_SOCKETS();
extern _ZMQ_PAIR;                     ZMQ_PAIR = _ZMQ_PAIR();
extern _ZMQ_PUB;                      ZMQ_PUB = _ZMQ_PUB();
extern _ZMQ_SUB;                      ZMQ_SUB = _ZMQ_SUB();
extern _ZMQ_REQ;                      ZMQ_REQ = _ZMQ_REQ();
extern _ZMQ_REP;                      ZMQ_REP = _ZMQ_REP();
extern _ZMQ_DEALER;                   ZMQ_DEALER = _ZMQ_DEALER();
extern _ZMQ_ROUTER;                   ZMQ_ROUTER = _ZMQ_ROUTER();
extern _ZMQ_PULL;                     ZMQ_PULL = _ZMQ_PULL();
extern _ZMQ_PUSH;                     ZMQ_PUSH = _ZMQ_PUSH();
extern _ZMQ_XPUB;                     ZMQ_XPUB = _ZMQ_XPUB();
extern _ZMQ_XSUB;                     ZMQ_XSUB = _ZMQ_XSUB();
extern _ZMQ_AFFINITY;                 ZMQ_AFFINITY = _ZMQ_AFFINITY();
extern _ZMQ_IDENTITY;                 ZMQ_IDENTITY = _ZMQ_IDENTITY();
extern _ZMQ_SUBSCRIBE;                ZMQ_SUBSCRIBE = _ZMQ_SUBSCRIBE();
extern _ZMQ_UNSUBSCRIBE;              ZMQ_UNSUBSCRIBE = _ZMQ_UNSUBSCRIBE();
extern _ZMQ_RATE;                     ZMQ_RATE = _ZMQ_RATE();
extern _ZMQ_RECOVERY_IVL;             ZMQ_RECOVERY_IVL = _ZMQ_RECOVERY_IVL();
extern _ZMQ_SNDBUF;                   ZMQ_SNDBUF = _ZMQ_SNDBUF();
extern _ZMQ_RCVBUF;                   ZMQ_RCVBUF = _ZMQ_RCVBUF();
extern _ZMQ_RCVMORE;                  ZMQ_RCVMORE = _ZMQ_RCVMORE();
extern _ZMQ_FD;                       ZMQ_FD = _ZMQ_FD();
extern _ZMQ_EVENTS;                   ZMQ_EVENTS = _ZMQ_EVENTS();
extern _ZMQ_TYPE;                     ZMQ_TYPE = _ZMQ_TYPE();
extern _ZMQ_LINGER;                   ZMQ_LINGER = _ZMQ_LINGER();
extern _ZMQ_RECONNECT_IVL;            ZMQ_RECONNECT_IVL = _ZMQ_RECONNECT_IVL();
extern _ZMQ_BACKLOG;                  ZMQ_BACKLOG = _ZMQ_BACKLOG();
extern _ZMQ_RECONNECT_IVL_MAX;        ZMQ_RECONNECT_IVL_MAX = _ZMQ_RECONNECT_IVL_MAX();
extern _ZMQ_MAXMSGSIZE;               ZMQ_MAXMSGSIZE = _ZMQ_MAXMSGSIZE();
extern _ZMQ_SNDHWM;                   ZMQ_SNDHWM = _ZMQ_SNDHWM();
extern _ZMQ_RCVHWM;                   ZMQ_RCVHWM = _ZMQ_RCVHWM();
extern _ZMQ_MULTICAST_HOPS;           ZMQ_MULTICAST_HOPS = _ZMQ_MULTICAST_HOPS();
extern _ZMQ_RCVTIMEO;                 ZMQ_RCVTIMEO = _ZMQ_RCVTIMEO();
extern _ZMQ_SNDTIMEO;                 ZMQ_SNDTIMEO = _ZMQ_SNDTIMEO();
extern _ZMQ_IPV4ONLY;                 ZMQ_IPV4ONLY = _ZMQ_IPV4ONLY();
extern _ZMQ_LAST_ENDPOINT;            ZMQ_LAST_ENDPOINT = _ZMQ_LAST_ENDPOINT();
extern _ZMQ_ROUTER_MANDATORY;         ZMQ_ROUTER_MANDATORY = _ZMQ_ROUTER_MANDATORY();
extern _ZMQ_TCP_KEEPALIVE;            ZMQ_TCP_KEEPALIVE = _ZMQ_TCP_KEEPALIVE();
extern _ZMQ_TCP_KEEPALIVE_CNT;        ZMQ_TCP_KEEPALIVE_CNT = _ZMQ_TCP_KEEPALIVE_CNT();
extern _ZMQ_TCP_KEEPALIVE_IDLE;       ZMQ_TCP_KEEPALIVE_IDLE = _ZMQ_TCP_KEEPALIVE_IDLE();
extern _ZMQ_TCP_KEEPALIVE_INTVL;      ZMQ_TCP_KEEPALIVE_INTVL = _ZMQ_TCP_KEEPALIVE_INTVL();
extern _ZMQ_TCP_ACCEPT_FILTER;        ZMQ_TCP_ACCEPT_FILTER = _ZMQ_TCP_ACCEPT_FILTER();
extern _ZMQ_DELAY_ATTACH_ON_CONNECT;  ZMQ_DELAY_ATTACH_ON_CONNECT = _ZMQ_DELAY_ATTACH_ON_CONNECT();
extern _ZMQ_XPUB_VERBOSE;             ZMQ_XPUB_VERBOSE = _ZMQ_XPUB_VERBOSE();
extern _ZMQ_MORE;                     ZMQ_MORE = _ZMQ_MORE();
extern _ZMQ_DONTWAIT;                 ZMQ_DONTWAIT = _ZMQ_DONTWAIT();
extern _ZMQ_SNDMORE;                  ZMQ_SNDMORE = _ZMQ_SNDMORE();
extern _ZMQ_EVENT_CONNECTED;          ZMQ_EVENT_CONNECTED = _ZMQ_EVENT_CONNECTED();
extern _ZMQ_EVENT_CONNECT_DELAYED;    ZMQ_EVENT_CONNECT_DELAYED = _ZMQ_EVENT_CONNECT_DELAYED();
extern _ZMQ_EVENT_CONNECT_RETRIED;    ZMQ_EVENT_CONNECT_RETRIED = _ZMQ_EVENT_CONNECT_RETRIED();
extern _ZMQ_EVENT_LISTENING;          ZMQ_EVENT_LISTENING = _ZMQ_EVENT_LISTENING();
extern _ZMQ_EVENT_BIND_FAILED;        ZMQ_EVENT_BIND_FAILED = _ZMQ_EVENT_BIND_FAILED();
extern _ZMQ_EVENT_ACCEPTED;           ZMQ_EVENT_ACCEPTED = _ZMQ_EVENT_ACCEPTED();
extern _ZMQ_EVENT_ACCEPT_FAILED;      ZMQ_EVENT_ACCEPT_FAILED = _ZMQ_EVENT_ACCEPT_FAILED();
extern _ZMQ_EVENT_CLOSED;             ZMQ_EVENT_CLOSED = _ZMQ_EVENT_CLOSED();
extern _ZMQ_EVENT_CLOSE_FAILED;       ZMQ_EVENT_CLOSE_FAILED = _ZMQ_EVENT_CLOSE_FAILED();
extern _ZMQ_EVENT_DISCONNECTED;       ZMQ_EVENT_DISCONNECTED = _ZMQ_EVENT_DISCONNECTED();
extern _ZMQ_POLLIN;                   ZMQ_POLLIN = _ZMQ_POLLIN();
extern _ZMQ_POLLOUT;                  ZMQ_POLLOUT = _ZMQ_POLLOUT();
extern _ZMQ_POLLERR;                  ZMQ_POLLERR = _ZMQ_POLLERR();
