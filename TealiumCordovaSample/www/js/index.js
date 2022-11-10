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

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    // Cordova is now initialized. Have fun!

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');
    
    setupEventListeners()

    initializeTealium()
}

function initializeTealium() {
    if(window.tealium != null) {
        let Environment = tealium.utils.Environment;
        let Collectors = tealium.utils.Collectors;
        let Dispatchers = tealium.utils.Dispatchers;
        let ConsentPolicy = tealium.utils.ConsentPolicy;
        let Expiry = tealium.utils.Expiry;
        
        let config = { 
            account: 'tealiummobile', 
            profile: 'demo', 
            environment: Environment.dev, 
            dispatchers: [
                Dispatchers.Collect, 
                Dispatchers.TagManagement, 
                Dispatchers.RemoteCommands
            ], 
            collectors: [
                Collectors.AppData, 
                Collectors.DeviceData, 
                Collectors.Lifecycle, 
                Collectors.Connectivity
            ], 
            consentLoggingEnabled: true, 
            // consentExpiry: { 
            //     'time': 10,
            //     'unit': 'days' 
            // }, 
            // consentPolicy: ConsentPolicy.gdpr, 
            lifecycleAutotrackingEnabled: true,
            batchingEnabled: false, 
            visitorServiceEnabled: true, 
            useRemoteLibrarySettings: false,
            visitorIdentityKey: "user_identity",
            remoteCommands: createRemoteCommands()
        };

        window.tealium.initialize(config, function(success) {
            console.log("Init was: " + success)
            if(success) {
                enableButtons()
                tealium.setVisitorServiceListener(logVisitorUpdated)
                tealium.setVisitorIdListener(logVisitorIdUpdated)
                tealium.setConsentExpiryListener(logConsentExpired)
                tealium.addRemoteCommand("hello-world", logRemoteCommand)
            }
        })
    } else {
        console.error("window.tealium is null")
    }
}

function getTealiumButtons() {
    return document.getElementsByClassName("tealium");
}

function enableButtons() {
    let buttons = getTealiumButtons()
    for (i in buttons) {
        buttons[i].disabled = false;
    }
}

function disableButtons() {
    let buttons = getTealiumButtons()
    for (i in buttons) {
        buttons[i].disabled = true;
    }
}

function setupEventListeners() {
    let buttons = getTealiumButtons()
    for (i in buttons) {
        buttons[i].onclick = handleClick;
    }

    document.getElementById("trace_id_input").oninput = setTraceId
    document.getElementById("identity_input").oninput = setUserId
}

function handleClick(e) {
    let button = e.target
    let method = button.getAttribute("data-method")
    let paramsJson = button.getAttribute("data-params")
    let callback = button.getAttribute("data-callback")

    let params = JSON.parse(paramsJson) || []
    if (callback) {
        callback = eval(callback)
        params.push(callback)
    }

    console.log("calling = " + method + ", with params = " + paramsJson)
    window.tealium[method] && window.tealium[method].apply(null, params)
}

function setTraceId(e) {
    document.getElementById("join_trace_button").setAttribute("data-params", '["' + e.target.value + '"]')
}

function setUserId(e) {
    document.getElementById("login").setAttribute("data-params", '[{"user_identity": "' + e.target.value + '"}]')
}

function logRemoteCommand(result) {
    console.log("RemoteComand Payload: " + JSON.stringify(result))
}

function logGatherTrackData(result) {
    console.log("Gather Track Data Response: " + JSON.stringify(result))
}

function logVisitorUpdated(visitor) {
    console.log("Visitor Updated " + JSON.stringify(visitor))
}

function logVisitorIdUpdated(visitorId) {
    console.log("Visitor Identity Updated " + JSON.stringify(visitorId))
}

function logConsentExpired() {
    console.log("Consent has expired.")
}

function createRemoteCommands() {
    var commands = [];
    var remoteCommands = window.tealium && 
                            window.tealium.remotecommands;
    if (remoteCommands) {
        var firebase =  remoteCommands.firebase && 
                            remoteCommands.firebase.create()
                                .setPath("firebase.json");
        firebase && commands.push(firebase);
    }

    return commands;
}
