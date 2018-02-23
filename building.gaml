/**
* Name: building
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model building

import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"


species building {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color: color ;
	}
}


/* Insert your model definition here */

