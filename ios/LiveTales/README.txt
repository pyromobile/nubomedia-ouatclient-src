ADAPTACIÓN LIBRERÍA A LA APLICACIÓN
===================================

1. He tenido que añadir como framework embebido BDSClientSDK.framework

Modificaciones en la librería.
------------------------------
1. NBMRoomClient.
   Fichero: Pods/Pods/KurentoToolbox/Room/NBMRoomClient.m
   Cambio: - (NBMRoom *)room
     Se modifica el retorno por return _room ya que produce una llamada recursiva y el consecuente desbordamiento de pila.

   Cambio: - partecipantPublished
     Se cambia la linea actual:
     NSArray *jsonStreams = [NBMRoomClient element:params getStringPropertyWithName:kPartecipantPublishedStreamsParam error:&error];

     por esta (ya que no recibo video remoto):
     NSArray *jsonStreams = [NBMRoomClient element:params getPropertyWithName:kPartecipantPublishedStreamsParam ofClass:[NSArray class] error:&error];

   Cambio: constante kPartecipantSendMessageUserParam = "userroom"
     por kPartecipantSendMessageUserParam = "user"


2. NBMWebRTCPeer.
   Fichero: Pods/Pods/KurentoToolbox/WebRTC/NBMWebRTCPeer.m
   Cambio: initWithDelegate
     Se añade la siguiente línea: _cameraPosition = _mediaConfiguration.cameraPosition;
     ya que da un error de que no detecta la cámara. En el cliente de la librería (ouat) se indica que coja la frontal.


3. NBMJSONRPCClient.
   Fichero: Pods/Pods/KurentoToolbox/JSON-RPC/NBMJSONRPCClient.m
   Cambio: getRequestPackById
     Se añade la siguiente línea: if(!requestId)return nil;

   Cambio: getProcessedResponseByAck
     Se añade la siguiente línea: if(!ack)return nil;



Modificaciones de la librería (20160803)
----------------------------------------
Cuando se manda un mensaje custom, no se recibe respuesta. Solo nos notifica de que se ha enviado y si ha habido error.
Se modifica la librería para pasar la respuesta:

1. NBMRoomClient.
   Fichero: Pods/KurentoToolbox/Classes/Room/NBMRoomClient.m
   Cambio: sendCustomRequest
     Se añade como parámetro en el callback (block) NBMResponse* lo que implica cambiar las interfaces de esta funcion y callbacks.

2. NBMRoomClient.
   Fichero: Pods/KurentoToolbox/Classes/Room/NBMRoomClient.h
   Cambio:
     - (void)sendCustomRequest:(NSDictionary <NSString *, NSString *>*)params completion:(void (^)(NSError *error))block;
     por esto:
     - (void)sendCustomRequest:(NSDictionary <NSString *, NSString *>*)params completion:(void (^)(NBMResponse *response, NSError *error))block;

3. NBMRoomClientDelegate.
   Fichero:Pods/KurentoToolbox/Classes/Room/NBMRoomClientDelegate.h
   Cambio:
     - (void)client:(NBMRoomClient *)client didSentCustomRequest:(NSError *)error;
     por esto:
     - (void)client:(NBMRoomClient *)client didSentCustomRequest:(NSError *)error didResponse:(NBMResponse *)response;

