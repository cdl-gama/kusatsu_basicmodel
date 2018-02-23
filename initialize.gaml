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


global{


	file shape_file_road1  <-file("../includes/kusatsucity_basicmapdata/37/roads37e.shp");
	file shape_file_road2  <-file("../includes/kusatsucity_basicmapdata/47/roads47e.shp");
	file shape_file_road_joint <- file("../includes/kusatsucity_basicmapdata/3747/roads3747i.shp");
	
	file shape_file_node1  <-file("../includes/kusatsucity_basicmapdata/37/nodes37t.shp");
	file shape_file_node2  <-file("../includes/kusatsucity_basicmapdata/47/nodes47.shp");
	file shape_file_node_joint <- file("../includes/kusatsucity_basicmapdata/3747/nodes3747t.shp");
	
	file shape_file_buildings <-file("../includes/kusatsucity_basicmapdata/3747/buildings3747.shp");
	
	geometry shape <- envelope(shape_file_road_joint);
	
	int nb_car <- 200;
	int nb_bus <- 0;
	int time_to_set_offset <- 1;
	
	intersection starting_point;
	
	graph road_network;

	map general_speed_map;
	map general_cost_map;

	
	float current_hour update: (time / #sec);
	float update_hour <- 0.0;
	float time_to_thorw <- 3600.0;	
	float sig_split parameter: "signal split" category: "signal sgent" min: 0.1 max: 1.0 init:0.5 step: 0.1;

	list<intersection> traffic_signals;

	int trip_generation <- nb_car;


	bool priority_offset <- true; //優先オフセットを実行するための変数

	file car_shape_empty  <- file('../icons/vehicles/normal_red.png');
	
	
	init{
		
		//道路エージェントの生成
		create road from: shape_file_road_joint{
			lanes <- 2;
			maxspeed <- 100.0;
			shape <- polyline(self.shape.points);
			
			//反対車線側の道路エージェントの生成
			create road{
		    			lanes <- max([2, int (myself.lanes / 2.0)]);
						shape <- polyline(reverse(myself.shape.points));
						shape <- polygon(reverse(myself.shape.points));
						maxspeed <- 100.0;
						geom_display  <- myself.geom_display;
						linked_road <- myself;
						myself.linked_road <- self;
			}
		
			geom_display <- shape +  (2 * lanes);
		}
		
		//交差点エージェントの生成
			create intersection from: shape_file_node_joint with:[highway::(string(read("signaltype")))]{
			
			if(highway != nil){
				is_traffic_signal <- true;
			}
		
		}
		starting_point <- one_of(intersection where each.is_traffic_signal);
		traffic_signals <- intersection where each.is_traffic_signal;
		
		
		general_speed_map <- road as_map (each::(each.shape.perimeter / (each.maxspeed)));
		road_network <-  as_driving_graph(road, intersection);
		
		
		loop i from: 0 to: length(intersection)-1{
		if(length(intersection[i].roads_in) = 0 and length(intersection[i].roads_out) = 0){
				intersection[i].not_node <-true;
			}
		}
		
		ask intersection{
			if(not_node){
				do die;
				}
		}
		

//道路ネットワークの書き出し		
//		container data <- ["road_id","source_node","target_node"];
//		save data to: "graph.csv" type: "csv" rewrite: false;
//		
//		loop i from: 0 to: length(road)-1{
//			data <-  [i,int(road[i].source_node),int(road[i].target_node)];
//			save data to: "graph.csv" type: "csv" rewrite: false;
//		}
		

		//建物エージェントの作成		
		create building from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type="Industrial" {
				color <- #blue ;
			}
		}		
		
		
		//普通自動車エージェントの生成		
		create car number: nb_car { 
			speed <- 60 #km /#h ;
			vehicle_length <- 10.0 #m;
			right_side_driving <- true;
			proba_lane_change_up <- 0.1 + (rnd(500) / 500);
			proba_lane_change_down <- 0.5+ (rnd(500) / 500);
			security_distance_coeff <-(1.5 - rnd(1000) / 1000);  
			proba_respect_priorities <- 0.1;
			proba_respect_stops <- [0.0];
			proba_block_node <- 0.0;
			proba_use_linked_road <- 0.0;
			max_acceleration <- 0.5 + rnd(500) / 1000;
			speed_coeff <- 1.2 - (rnd(400) / 1000);
			d <- one_of(intersection where (each.not_node = false)); 
			target <- d;
			o <- one_of(intersection where (each.not_node = false)); 
			location <- any_location_in(d);
			current_path <- compute_path(graph: road_network, target: o);
			mem_return_path <- current_path;
			mem_return_current_road <- current_road;
			mem_return_current_target <- current_target;
			mem_return_targets <- targets ;
			mem_return_final_target <- final_target;
			
			if(current_road != nil){
			road(current_road).all_agents <- road(current_road).all_agents - self;
				remove self from: list(road(current_road).agents_on[0][0]);
				remove self from: list(road(current_road).agents_on[1][0]);
			}
			
			current_road <- nil;
			current_path <- nil;
			current_target <- nil;
			targets <- nil;
			final_target <- nil;
		
			
			location <- any_location_in(o);
			current_path <- compute_path(graph: road_network, target: target);
			mem_going_path <- current_path;
			mem_going_current_road <- current_road;
			mem_going_current_target <- current_target;
			mem_going_targets <- targets ;
			mem_going_final_target <- final_target;
			
		}
    }	
    }	
    
    
    
   experiment traffic_simulation type: gui {
	
	parameter "nb_cars: " var: nb_car  min: 0 max: 1000 category: "car" ;
	parameter "nb_buses: " var: nb_bus category: "bus" ;
	
	output {
		display city_display type: opengl{
			species road aspect: geom refresh: false;
			species intersection aspect: geom3D;
			species building aspect: base ;
			species car aspect: icon;
		
		}
	}
	}
	
	


/* Insert your model definition here */

