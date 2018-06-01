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
import "./administrator.gaml"
import "./vehicle.gaml"


global{
	file shape_file_road_joint <- file("../includes/ver5/roads3747i.shp");
	geometry shape <- envelope(shape_file_road_joint);
	graph road_network;
}

species road_make{  //道路エージェント生成のためのエージェント
	init{
		write("road");
		create road from: shape_file_road_joint with:[road_width::(float(read("fukuin"))#cm),lane_num::(int(read("lanesu"))) ]{ //幅員と車線数の値を読み込む
		//lanes <- max([1,int(lane_num/2)]);
		lanes <- 2;
			maxspeed <- 100.0;
			shape <- polyline(self.shape.points);
			
			//反対車線側の道路エージェントの生成
			create road{
				//lanes <- max([1,int(lane_num/2)]);		
				lanes <- 2;
		    	//lanes <- max([2, int (myself.lanes / 2.0)]);
				shape <- polyline(reverse(myself.shape.points));
				shape <- polygon(reverse(myself.shape.points));
				maxspeed <- 100.0;
				geom_display  <- myself.geom_display;
				linked_road <- myself;
				myself.linked_road <- self;
			}
		//	geom_display <- shape +  (2 * lanes);
		if(lane_num = 1){
			geom_display <-  shape + road_width; 
		}else{
			geom_display <- shape + (lane_num/2*350#cm);
		}
		}
		do die;
	}
}

species road skills: [skill_road] { //道路エージェント
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
	float road_width; //  幅員
	int lane_num;     //車線数
	
	
	
	/* 
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
	
	
	* 
	*/
	aspect geom {    
		draw geom_display  border:  #black  color: #gray ;
	}  
	
}


/* Insert your model definition here */

