plug_dir,".";
require,"zmq.i";

func hwserver(void)
/* server:
   use zmq.REP
   use bind to "tcp://*:5555"
*/
{
  extern ctx,soc;
  ctx = zmq_ctx_new(); 
  soc = zmq_socket(ctx,ZMQ_REP);
  zmq_bind,soc,"tcp://*:5555"; // could be ipc:///tmp/feeds/0
  do {
    msg = zmq_recv(soc,string,5,0)(1);
    write,format="Client said \"%s\", answering \"World\"\n",msg;
    zmq_send,soc,"World";
    pause,100;
  } while (msg!="quit");
  // so = [];
  // s  = [];
}

func hwclient(msg)
/* client:
   Use zmq.REQ
   Use connect to "tcp://localhost:5555"
*/
{
  extern ctx,soc;
  if (msg==[]) msg="Hello";
  ctx = zmq_ctx_new();
  soc = zmq_socket(ctx,ZMQ_REQ); 
  zmq_connect,soc,"tcp://localhost:5555";
  zmq_send,soc,msg;
  write,format="Sent \"%s\", Server answered \"%s\"\n",msg,zmq_recv(soc,string,5,0)(1);
}


func demo_server(void)
{
  ctx = zmq_ctx_new(); 
  soc = zmq_socket(ctx,ZMQ_REP);
  zmq_bind,soc,"tcp://*:5555"; 

  do {
    msg = zmq_recv(soc,string,5,0);
    write,format="Client said \"%s\", answering \"World\"\n",msg;
    zmq_send,soc,"World";
    pause,1000;
  } while (1);
}

func demo_client(msg)
{
  if (msg==[]) msg="Hello";

  ctx = zmq_ctx_new();
  soc = zmq_socket(ctx,ZMQ_REQ); 
  zmq_connect,soc,"tcp://localhost:5555";

  for (n=1;n<=10;n++) {
    zmq_send,soc,msg;
    write,format="Sent \"%s\", Server answered \"%s\"\n",msg,zmq_recv(soc,string,5,0);
  }
  soc = [];
  ctx = [];
}

func demo_server2(void)
{
  ctx = zmq_ctx_new(); 
  soc = zmq_socket(ctx,ZMQ_REP);
  zmq_bind,soc,"tcp://*:5555"; 

  do {
    msg = zmq_recv(soc,long,10,0);
    msg;
    zmq_send,soc,"World";
    pause,1000;
  } while (1);
}

func demo_client2(msg)
{
  if (msg==[]) msg="Hello";

  ctx = zmq_ctx_new();
  soc = zmq_socket(ctx,ZMQ_REQ); 
  zmq_connect,soc,"tcp://localhost:5555";

  for (n=1;n<=10;n++) {
    zmq_send,soc,indgen(10);
    msg = zmq_recv(soc,string,5,0);
    // write,format="Server answered \"%s\"\n",
    msg;
  }
  soc = [];
  ctx = [];
}

func demo_server3(void)
{
  if (!findfiles("/tmp/feeds")) error,"Have to create /tmp/feeds first";
  write,format="%s\n","Creating context";
  ctx = zmq_ctx_new(); 
  write,format="%s\n","Creating socket";
  soc = zmq_socket(ctx,ZMQ_REP);
  write,format="%s\n","Binding to socket";
  zmq_bind,soc,"ipc:///tmp/feeds/0"; 

  do {
    write,format="%s\n","Receiving/waiting for message";
    msg = zmq_recv(soc,long,10,0);
    // write,format="Client said \"%s\", answering \"World\"\n",strchar(msg);
    // msg;
    write,format="%s\n","Sending 512x512 array";
    zmq_send,soc,float(random([2,512,512]));
  } while (1);
}

func demo_client3(nmax)
{
  window,wait=1;
  if (!nmax) nmax=10;

  write,format="%s\n","Creating context";
  ctx = zmq_ctx_new();
  write,format="%s\n","Creating socket";
  soc = zmq_socket(ctx,ZMQ_REQ); 
  write,format="%s\n","Connecting to socket";
  zmq_connect,soc,"ipc:///tmp/feeds/0";

  for (n=1;n<=nmax;n++) {
    write,format="%s\n","Sending request";
    zmq_send,soc,indgen(10);
    write,format="%s\n","Receiving/waiting for array";
    msg = zmq_recv(soc,float,512*512,0);
    fma; pli,reform(msg,[2,512,512]);
  }
  soc = [];
  ctx = [];
}


func demo_pub(void)
{
  ctx = zmq_ctx_new();
  pub = zmq_socket (ctx, ZMQ_PUB);
  rc  = zmq_bind (pub, "tcp://*:5556");
  rc  = zmq_bind (pub, "ipc://weather.ipc");
  if (rc) error,"Can't bind ipc";

  do {
    //  Get values that will fool the boss
    zipcode     = long(random()*5+10000);
    temperature = long(random()*215 - 80);
    relhumidity = long(random()*50 + 10);
    //  Send message to all subscribers
    update = swrite(format="%05d %d %d", zipcode, temperature, relhumidity);
    if (zipcode==10001) update;
    rc = zmq_send(pub, update);
    pause,10;
  } while (1);
  pub = [];
  ctx = [];
}

func demo_sub(void)
{
  write,"Collecting updates from weather server...";
  ctx = zmq_ctx_new();
  sub = zmq_socket(ctx, ZMQ_SUB);
  rc  = zmq_connect (sub, "tcp://localhost:5556");
  // Subscribe to zipcode, default is NYC, 10001
  rc = zmq_setsockopt (sub, ZMQ_SUBSCRIBE, "10001");
  //  Process 100 updates
  total_temp = 0;
  for (n=1; n<=10; n++) {
    str = zmq_recv(sub,string,20,0)(1);
    str;
    zipcode = temperature = relhumidity = 0n;
    sread,str,format="%d %d %d",zipcode, temperature, relhumidity;
    total_temp += temperature;
  }
  write,format="Average temperature for zipcode '%d' was %dF\n",zipcode,long(total_temp / (n-1));
  sub = [];
  ctx = [];
}

imn = 512;

func demo_pub2(void)
{
  ctx = zmq_ctx_new();
  pub = zmq_socket (ctx, ZMQ_PUB);
  // rc  = zmq_bind (pub, "tcp://*:5556");
  rc  = zmq_bind (pub, "ipc:///tmp/feeds/0");
  // if (rc) error,"Can't bind ipc";

  ar = float(random([2,imn,imn]));
  do {
    rc = zmq_send(pub,ar);
    // pause,1;
  } while (1);
  pub = [];
  ctx = [];
}

func demo_sub2(nmax)
{
  if (!nmax) nmax=100;

  ctx = zmq_ctx_new();
  sub = zmq_socket(ctx, ZMQ_SUB);
  // rc  = zmq_connect (sub, "tcp://localhost:5556");
  rc  = zmq_connect (sub, "ipc:///tmp/feeds/0");
  // Subscribe to zipcode, default is NYC, 10001
  rc = zmq_setsockopt (sub, ZMQ_SUBSCRIBE, []);
  //  Process 100 updates
  for (n=1; n<=nmax; n++) {
    msg = zmq_recv(sub,float,imn*imn,0);
    // fma; pli,reform(msg,[2,imn,imn]);
  }
  sub = [];
  ctx = [];
}

func demo_pub3(void)
{
  ctx = zmq_ctx_new();
  pub = zmq_socket (ctx, ZMQ_PUB);
  rc  = zmq_bind (pub, "ipc:///tmp/feeds/0");

  dim = long([2,imn,imn]);
  ar = float(random(dim));
  do {
    // send a multipart message:
    rc = zmq_send(pub,dim,0);
    // rc = zmq_send(pub,dim,ZMQ_SNDMORE);
    // rc = zmq_send(pub,ar);
  } while (1);
  pub = [];
  ctx = [];
}

func demo_sub3(nmax)
{
  if (!nmax) nmax=100;

  ctx = zmq_ctx_new();
  sub = zmq_socket(ctx, ZMQ_SUB);
  rc  = zmq_connect (sub, "ipc:///tmp/feeds/0");
  rc = zmq_setsockopt (sub, ZMQ_SUBSCRIBE, []);
  //  Process 100 updates
  for (n=1; n<=nmax; n++) {
    // dim = zmq_recv(sub,long,3,ZMQ_RCVMORE);
    dim = zmq_recv(sub,long,3,0);
    dim;
    // ar = zmq_recv(sub,float,dim(2)*dim(3),0);
    // ar = reform(ar,dim);
    // fma; pli,ar;
    pause,50;
  }
  sub = [];
  ctx = [];
}



/* above, display of a nxn (x100):
Time 100 iter.
n     direct  zmq  
32    0.89    1.00 
128   13.17   13.16
512   0.83    1.28 
2048  7.31    5.37 
impressive !

now without reform and display, just to see the pure xfer time:
Time 100 iter.
n    direct  zmq
32   0.002   0.002
128  0.022   0.018
512  0.204   0.220
2048 3.481   4.012
whoaa.
*/