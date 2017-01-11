/*
 * See the LICENSE.txt file distributed with this work for
 * licensing and copyright information.
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
// this var acts as a constant to reference the name of the Tealium instance we will create later.
// if you have multiple instances, you will need to pass in a custom instance name for each one, so don't use a constant.
window.tealium_instance = "tealium_main";
// init tealium plugin onDeviceReady
document.addEventListener("deviceready", onDeviceReady, false);
// add a tealium event call (utag.link) to the "Event Button"
document.getElementById("event_button").addEventListener("click", function(){
                                                        // call our custom trackEvent function and pass in some data. not specifying an instance id, so the global constant "tealium_main" will be used
                                                         trackEvent('{"link_id" : "Event Button", "link_name" : "Event Button"}');
                                                         });
// add a tealium view call (utag.view) to the "View Button"
document.getElementById("view_button").addEventListener("click", function(){
                                                        // View events should normally be tracked through a view change callback, rather than through a button trigger as demonstrated here
                                                        // call our custom trackView function and pass in some data, this time explicitly specifying the instance id
                                                        trackView('{"screen_title":"Test Homescreen"}', "tealium_main");
                                                        });

document.getElementById("persist_button").addEventListener("click", function(){
    tealium.addPersistent("persist", "testpersist", window.tealium_instance);
});
document.getElementById("remove_persist_button").addEventListener("click", function(){
    tealium.removePersistent("persist", window.tealium_instance);
});
document.getElementById("volatile_button").addEventListener("click", function(){
    tealium.addVolatile("volatile", "testvolatile", window.tealium_instance);
});
document.getElementById("remove_volatile_button").addEventListener("click", function(){
    tealium.removeVolatile("volatile", window.tealium_instance);
});
document.getElementById("get_volatile").addEventListener("click", function(){
    tealium.getVolatile("volatile", window.tealium_instance, function (val) {
        alert("Volatile data returned: " + "volatile = " + val);    
    });
});

document.getElementById("get_persistent").addEventListener("click", function(){
    tealium.getPersistent("persist", window.tealium_instance, function (val) {
        alert("Persistent data returned: " + "persist = " + val);    
    });
});

function onDeviceReady() {
    // call our custom tealiumInit function
    tealiumInit("services-crouse", "mobile", "dev", "tealium_main");
    console.log("onDeviceReady");
}

function tealiumInit(accountName, profileName, environmentName, instanceName){
        tealium.init({
                 account : accountName       // REQUIRED: Your account.
                 , profile : profileName              // REQUIRED: Profile you wish to use.
                 , environment : environmentName         // REQUIRED: "dev", "qa", or "prod".
                 , instance : instanceName || window.tealium_instance // instance name used to refer to the current tealium instance
                 , isLifecycleEnabled: "true" // explicitly enabling lifecycle tracking. Note string value required, not boolean
                 // , collectDispatchURL:"https://collect.tealiumiq.com/vdata/i.gif?tealium_account=services-crouse&tealium_profile=mobile"
                 , collectDispatchProfile:"demo"
                 });
}

function trackEvent(data, instance){
    // Tealium example with custom data passed in as a wrapper argument
    // Custom data must be a dictionary
    data = JSON.parse(data);
    // this will be a "link" event. Accepts either a custom instance name, or defaults to window.tealium_instance
    tealium.track("link", data, instance || window.tealium_instance);
    // alert("Event Dispatched");
}

function trackView(data, instance){
    // Tealium example with custom data passed in as a wrapper argument
    // Custom data must be a dictionary
    data = JSON.parse(data);
    // this will be a "view" event. Accepts either a custom instance name, or defaults to window.tealium_instance
    tealium.track("view", data, instance || window.tealium_instance);
    // alert("View Dispatched");
}
