/**
* Name: viewmain
* Author: agent
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model viewmain

/* Insert your model definition here */


import "./view_road.gaml"
import "./view_building.gaml"
import "./view_intersection.gaml"
import "./view_car1.1.gaml"

global{
	
	init{
		create road_make number:1;   //道路を生成するエージェントの生成
		create intersection_make number:1;   		//交差点を生成するエージェントの生成
		create building from: shape_file_buildings  ;//建物エージェントの作成		
		
		create car_make number:1;   //車を生成するエージェントの生成
		
	}

}

experiment viewer_icon type:gui{
	output {
		display city_display type: opengl{
			species road aspect: geom refresh: false;
			species intersection aspect: geom3D;
			species building aspect: base refresh: false;
			species car aspect:icon ;		
		}
	}
}