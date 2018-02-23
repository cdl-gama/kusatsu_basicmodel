/**
* Name: car
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model car


import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"



species car skills: [advanced_driving] { 
	rgb color <- rnd_color(255);
	bool checked;
	intersection target;
	intersection source_node;
	intersection true_target;
	intersection o;
	intersection d;
	float arrival_time <-1.0;
	float departure_time <-1.0;
	float travel_time <- 1.0;
	bool  route_changed <- false;
	agent temp <- current_road;
	agent previous_road  <- current_road;
	agent  mem_previous_road;
	point mem_going_final_target;
	path mem_going_path;
	point mem_going_current_target;
	agent mem_going_current_road;
	list<point> mem_going_targets;
	building home;
	point mem_return_final_target;
	list<road> return_path_list;
	path mem_return_path;
	point mem_return_current_target;
	agent mem_return_current_road;
	list<point> mem_return_targets;
	point temp_current_target <- current_target;


//交差点の交通量を測る（車が交差点を通るたびに、その交差点の交通量インクリメント）
//	reflex to_node when: temp_current_target != current_target{
//				
//		if(length(intersection(road(previous_road).target_node).roads_in) > 2 or length(intersection(road(previous_road).target_node).roads_out) > 2){
//		intersection(road(previous_road).target_node).trf_vol <- intersection(road(previous_road).target_node).trf_vol + 1;
//		}
//		
//		temp_current_target <- current_target;
//		
//	}
	
	//道路区間ごとの旅行時間を測るための処理
	reflex set_arrivaltime when: current_road != temp {
		travel_time <- time - departure_time;
		departure_time <- time;
		previous_road <- temp;
		temp <- current_road;			
	}
			
	//走りきって死ぬときの処理	
	reflex time_to_die when: self.location = any_location_in(d) and final_target = nil{
		
		if(current_road != nil){
			road(current_road).all_agents <- road(current_road).all_agents - self;
			remove self from: list(road(current_road).agents_on[0][0]);
			remove self from: list(road(current_road).agents_on[1][0]);
		}
		
		
		current_index <- 0;
		current_road <- mem_going_current_road;
		
		if(current_road != nil){
		road(current_road).all_agents <- road(current_road).all_agents + self;
		}
		
		self.location <- o.location;
		current_path <- mem_going_path;
		current_target <- mem_going_current_target;
		targets <- mem_going_targets;
		final_target <- mem_going_final_target;
	}
	
//イテレーションする時に必要なやつ（道路ネットワークの情報を保持しつつ車両エージェントの固定パスを通す）
//	reflex change_route when: self.location = any_location_in(o) and route_changed = true{
//		
//			road_network <- road_network with_weights general_cost_map;
//			
//			location <- any_location_in(d);
//			current_path <- compute_path(graph: road_network, target: o);
//			mem_return_path <- current_path;
//			mem_return_current_road <- current_road;
//			mem_return_current_target <- current_target;
//			mem_return_targets <- targets + final_target;
//			mem_return_final_target <- final_target;
//			
//			location <- any_location_in(o);
//			current_path <- compute_path(graph: road_network, target: target);
//			mem_going_path <- current_path;
//			mem_going_current_road <- current_road;
//			mem_going_current_target <- current_target;
//			mem_going_targets <- targets;
//			mem_going_final_target <- final_target;
//			
//		
//	}
	
	
//パスとターゲットが決まってれば走るよね
	reflex move when: current_path != nil and final_target != nil and checked = false{
		do drive;
	}
	
	aspect car3D {
		if (current_road) != nil {
			point loc <- calcul_loc();
			draw box(vehicle_length, 1,1) at: loc rotate:  heading color: color;
			draw triangle(0.5) depth: 1.5 at: loc rotate:  heading + 90 color: color;	
		}
	} 
	
	aspect icon {
		point loc <- calcul_loc();
			draw car_shape_empty size: vehicle_length   at: loc rotate: heading + 90 ;
	}
	
	point calcul_loc {
		float val <- (road(current_road).lanes - current_lane) + 0.5;
		val <- on_linked_road ? val * - 1 : val;
		if (val = 0) {
			return location; 
		} else {
			return (location + {cos(heading + 90) * val, sin(heading + 90) * val});
		}
	}
} 



/* Insert your model definition here */

