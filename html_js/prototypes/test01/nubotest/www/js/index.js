/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener( 'deviceready', this.onDeviceReady, false );
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function()
    {
      console.log("***** DEVICE READY ***** - Scripts loading...");

      navigator.getUserMedia = ( navigator.getUserMedia ||
                       navigator.webkitGetUserMedia ||
                       navigator.mozGetUserMedia ||
                       navigator.msGetUserMedia);
      window.getUserMedia = navigator.getUserMedia.bind(navigator);

      ["bower_components/adapter.js/adapter.js","js/kurento-utils.js", "js/tale.js", "js/conferenceroom.js","js/participant.js"].forEach( function( path ){
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = path;
        script.async = false;
        document.getElementsByTagName("head")[0].appendChild(script);
      });

      console.log("***** DEVICE READY ***** -  Scripts loaded!");
    }
};

app.initialize();
