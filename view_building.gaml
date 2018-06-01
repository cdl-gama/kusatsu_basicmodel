/**
* Name: building
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model building

import "./view_road.gaml"
import "./view_intersection.gaml"
import "./view_main.gaml"


global{
		file shape_file_buildings <-file("../includes/ver5/buildings3747.shp");
	
}

species building {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color: color ;
	}
}


/* Insert your model definition here */

