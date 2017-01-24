/*
 * (C) Copyright 2014 Kurento (http://kurento.org/)
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 */

 /*document.addEventListener("deviceready", onDeviceReady, false);
 function onDeviceReady() {
	 	console.log("***** DEVICE READY ***** ");
		console.log(navigator.device.capture);
		console.log("***** DEVICE READY *****  - Start RunApp()...");
		onRunApp();
 }
*/
var ws = null;
var participants = {};
var name = null;
//function onRunApp()
//{

	//var ws = new WebSocket('wss://' + location.host + '/service');
	ws = new WebSocket('wss://10.0.0.98:8443/service');
	//var participants = {};
	//var name;

	window.onbeforeunload = function() {
		ws.close();
	};

	ws.onmessage = function(message) {
		var parsedMessage = JSON.parse(message.data);
		console.info('Received message: ' + message.data);

		switch (parsedMessage.id) {
		case 'existingParticipants':
			onExistingParticipants(parsedMessage);
			break;
		case 'newParticipantArrived':
			onNewParticipant(parsedMessage);
			break;
		case 'userLeave':
			onParticipantLeft(parsedMessage);
			break;
		case 'receiveVideoAnswer':
			receiveVideoResponse(parsedMessage);
			break;
		case 'iceCandidate':
			participants[parsedMessage.name].rtcPeer.addIceCandidate(parsedMessage.candidate, function (error) {
		        if (error) {
			      console.error("Error adding candidate: " + error);
			      return;
		        }
		    });
		    break;
		case 'notifyChangePage':
			newPageToShow( parsedMessage );
			break;
		case 'prepareNewParticipant':
			prepareNewParticipant( parsedMessage );
			break;
		default:
			console.error('Unrecognized message', parsedMessage);
		}
	}
//}

function register( operation ) {
	name = document.getElementById('name').value;
	var room = document.getElementById('roomName').value;

	document.getElementById('room-header').innerText = 'ROOM ' + room;
	document.getElementById('join').style.display = 'none';
	document.getElementById('room').style.display = 'block';

	var operationId = (operation === 'create') ? 'createRoom' : 'joinRoom';

	var message = {
		id : operationId,
		userName : name,
		roomId : room,
		roomType:1			//Sala libre.
	}
	sendMessage(message);
}

function onNewParticipant(request) {
	receiveVideo(request.name);
}

function receiveVideoResponse(result) {
	participants[result.name].rtcPeer.processAnswer (result.sdpAnswer, function (error) {
		if (error) return console.error (error);
	});
}

function callResponse(message) {
	if (message.response != 'accepted') {
		console.info('Call not accepted by peer. Closing call');
		stop();
	} else {
		webRtcPeer.processAnswer(message.sdpAnswer, function (error) {
			if (error) return console.error (error);
		});
	}
}

function onExistingParticipants(msg) {
	var constraints = {
		audio : true,
		video : {
			mandatory : {
				maxWidth : 320,
				maxFrameRate : 15,
				minFrameRate : 15
			}
		}
	};
	console.log(name + " registered in room " + room);
	var participant = new Participant(name);
	participants[name] = participant;
	var video = participant.getVideoElement();

	var options = {
	      localVideo: video,
	      mediaConstraints: constraints,
	      onicecandidate: participant.onIceCandidate.bind(participant)
	    }
	participant.rtcPeer = new kurentoUtils.WebRtcPeer.WebRtcPeerSendonly(options,
		function (error) {
		  if(error) {
			  return console.error(error);
		  }
		  this.generateOffer (participant.offerToReceiveVideo.bind(participant));
	});

	msg.data.forEach(receiveVideo);
}

function leaveRoom() {
	sendMessage({
		id : 'leaveRoom'
	});

	for ( var key in participants) {
		participants[key].dispose();
	}

	document.getElementById('join').style.display = 'block';
	document.getElementById('room').style.display = 'none';

	ws.close();
}

function receiveVideo(sender) {
	var participant = new Participant(sender);
	participants[sender] = participant;
	var video = participant.getVideoElement();

	var options = {
      remoteVideo: video,
      onicecandidate: participant.onIceCandidate.bind(participant)
    }

	participant.rtcPeer = new kurentoUtils.WebRtcPeer.WebRtcPeerRecvonly(options,
			function (error) {
			  if(error) {
				  return console.error(error);
			  }
			  this.generateOffer (participant.offerToReceiveVideo.bind(participant));
	});
}

function onParticipantLeft(request) {
	console.log('Participant ' + request.name + ' left');
	var participant = participants[request.name];
	participant.dispose();
	delete participants[request.name];
}

function sendMessage(message) {
	var jsonMessage = JSON.stringify(message);
	console.log('Senging message: ' + jsonMessage);
	ws.send(jsonMessage);
}

function newPageToShow( result )
{
	console.log( 'New page to show:', result.action );
	switch( result.action )
	{
		case 'prev':
			tale.prevPage();
			break;
		case 'next':
			tale.nextPage();
			break;
	}

	document.getElementById('taleText').innerHTML=tale.getText();
}

function prepareNewParticipant( result )
{
	document.getElementById('taleNavButtons').style.display = result.showTaleButtons ? 'block' : 'none';
	document.getElementById('taleText').innerHTML=tale.getText();
}

function talePrev()
{
	tale.prevPage();
	document.getElementById('taleText').innerHTML=tale.getText();
	if( Object.keys(participants).lenght > 1 )
	{
		var message = {
			id : 'changePage',
			action : 'prev'
		};
		sendMessage(message);
	}
}

function taleNext()
{
	tale.nextPage();
	document.getElementById('taleText').innerHTML=tale.getText();
	if( Object.keys(participants).length > 1 )
	{
		var message = {
			id : 'changePage',
			action : 'next'
		};
		sendMessage(message);
	}
}
