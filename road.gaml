/**
* Name: road
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model road

import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"


species road skills: [skill_road] { 
	string oneway;
	string highway;
	geometry geom_display;
	road riverse;
	int kasayama;
	int kagayaki;
	int pana_east;
	int pana_west;
	list test;
	bool observation_mode <- true; 
	int flow <- 1; 
	list temp1 <- self.all_agents; 
	float sum_traveltime <- 1.0;
	float number <- 1.0;
	float ave_traveltime<-0.0;
	point setnum <- {0.0,0.0};
	road me <- self;
	
	
	reflex when :observation_mode  {
		
				
		if(length(test) > 0){
			loop i from:0 to:length(test)-1{
				if(contains(car,test[i])){
					road(car(test[i]).previous_road).sum_traveltime <- road(car(test[i]).previous_road).sum_traveltime + car(test[i]).travel_time;
				}
			}
		}
			
		test <- all_agents - temp1;
		flow <- flow + length(test);
		temp1 <- self.all_agents;
	}
	
	aspect geom {    
		draw geom_display border:  #gray  color: #gray ;
	}  
}


/* Insert your model definition here */

