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


document.addEventListener("deviceready", onDeviceReady, false);
document.getElementById("event_button").addEventListener("click", function(){
                                                         tealium.track("link",{"link_id":"testEvent"});
                                                         alert("Event Dispatched");
                                                         });
document.getElementById("view_button").addEventListener("click", function(){
                                                        // View events should normally be tracked through a view change callback, rather than through a button trigger as demonstrated here
                                                        trackView('{"screen_title":"testView"}')
                                                        });
function onDeviceReady() {
    tealium.init({
                 account : "tealiummobile"       // REQUIRED: Your account.
                 , profile : "demo"              // REQUIRED: Profile you wish to use.
                 , environment : "dev"           // REQUIRED: "dev", "qa", or "prod".
                 , disableHTTPS : false          // OPTIONAL: Default is false.
                 , suppressLogs : false           // OPTIONAL: Default is true.
                 , suppressErrors : false        // OPTIONAL: Default is false, effects only Android builds.
                 });
    console.log("onDeviceReady")
}

function trackEvent(){
    // Tealium example with data directly provided in call
    tealium.track("link",{"link_id":"testEvent"});
    alert("Event Dispatched");
}

function trackView(data){
    // Tealium example with custom data passed in as a wrapper argument
    // Custom data must be a dictionary
    data = JSON.parse(data);
    tealium.track("view", data);
    alert("View Dispatched");
}