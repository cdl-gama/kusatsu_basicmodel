/**
* Name: initialize
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model initialize


import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"
import "./bus.gaml"
import "./taxi.gaml"


global{
	bool save_car_log <- false;
	float step <-  0.05 #minutes;
	map general_speed_map;
	map general_cost_map;
	float current_hour update: (time / #sec);
	float update_hour <- 0.0;
	float time_to_thorw <- 3600.0;	
	int current_hour2 update: (cycle / (3600/step)) mod 24;    //現在の時間
	int current_time update: (cycle / (60/step)) mod 60;
	//file bus_img <- file('../icons/bus_blue.png');                                     //iconデータがないためコメントアウト
	
	
	init{
		write("init_start");
		//道路エージェントの生成
		create road_make number:1;
		
		
		//交差点エージェントの生成
		create intersection_make number:1;
		write("intersection");
		
		
		//建物エージェントの作成		
		create building from: shape_file_buildings with: [type::string(read ("NATURE"))] ;
				
		
		//普通自動車エージェントの生成		
		create car number: nb_car ;
		
		
			
		//タクシーのためのエージェント作成		
		
		//create taxi_manager number:1;
		//create taxi number: taxi_number ;
		//create make_passenger number:1;
		
		
		
		//バスのためのエージェント作成
		create make_bus number:1;
		
		}
		
		reflex save when:save_car_log = true{   //車のlogデータ書き出し
			save [0.0,0.0,0] to:"../results2/car_location.csv" type:"csv" rewrite: false;  			
		}
	}
  
    
    
    
   experiment traffic_simulation_icon type: gui {
		parameter "save_car_log" var:save_car_log;
	
	output {
		display city_display type: opengl{
			species road aspect: geom refresh: false;
			species intersection aspect: geom3D;
			species building aspect: base ;
			species car aspect: icon;
	//		species taxi aspect: circle;
	//		species passenger aspect: circle;
	//		species bus_to_BKC aspect: car3D;
		}
	 }	
	}
	
	experiment traffic_simulation_box type: gui {
		parameter "save_car_log" var:save_car_log;
	
	output {
		display city_display type: opengl{
			species road aspect: geom refresh: false;
			species intersection aspect: geom3D;
			species building aspect: base ;
			species car aspect:car3D;
	//		species taxi aspect: circle;
	//		species passenger aspect: circle;
	//		species bus_to_BKC aspect: car3D;
		}
	 }	
	}
	

/* Insert your model definition here */

