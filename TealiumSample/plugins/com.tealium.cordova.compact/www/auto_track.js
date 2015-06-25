var AutoTrack =  {
	init: function() {
		var track_inputs = {
			input: {
               attr: {
                    type: ["button",
                           "submit",
                           "checkbox",
                           "radio"]
               }
			},
            button: {
               attr: {
               
               }
            }
		
		};
               
		var track_elements = {
			href: {
				
			},
			img: {
				
			}
		};
               
		function add_tracking(objects){
			objects.each(function(){
				
			});
			
		}
    },
    successCallback: function(){
        console.log("tealium auto_track successful");
    },
    errorCallback: function(){
        console.log("tealium auto_track fail");
    }
	
 	 	
}

module.exports = AutoTrack;