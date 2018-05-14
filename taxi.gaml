/**
* Name: taxi
* Author: nisiura
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model taxi

import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"
import "./vehicle.gaml"


/* Insert your model definition here */

global{
	int taxi_number <- 1;
	int passenger_number <- 500; //１時間に発生する乗客数
	float create_rate <- float(passenger_number/(60*60/step));
	int amount_of_passenger <- 0 ;  //乗客の合計人数
	int now_passenger_num <- 0;   //現在の乗客数
	float waiting_time;  //乗客の待ち時間の合計
	float taxi_length <- 3.0#m;
	float taxi_search_distance <- 100#m;
	
}



species taxi parent:vehicle{		     //タクシーエージェント
	bool carrying;
	bool pas_pass;
	int staying_counter;
	string ovjective;        //今の状況を表す
	point desti;
	float pay_time;
	intersection target_nd;
	bool continue <- true;
	intersection first_location;
	intersection target_node;
	string driving_area;
	
	init{
			speed <- 50 #km /#h ;
			vehicle_length <- taxi_length;
			right_side_driving <- false;
			proba_lane_change_up <- 0.1 + (rnd(500) / 500);
			proba_lane_change_down <- 0.5+ (rnd(500) / 500);
			ask taxi_manager{
					do choice_target;			
					myself.first_location <- self.target_node;  //targetをランダムに定める. 
					myself.driving_area <- self.current_area;
					
				}
				location <- point(first_location);
			
			
			
			security_distance_coeff <- 4.0;//(1.5 - rnd(1000) / 1000);  
			proba_respect_priorities <- 1.0 - rnd(200/1000);
			//proba_respect_stops <- [0.1];
			proba_block_node <- rnd(3) / 1000;
			proba_use_linked_road <- 0.0;
			max_acceleration <- 0.5 + rnd(500) / 1000;
			speed_coeff <- 1.2 - (rnd(400) / 1000);
			pay_time <- 0.0;
			ovjective <- "empty";
			carrying <- false;	
			pas_pass <- false;
			
			ask taxi_manager{
					do choice_target;			
					myself.target_node <- self.target_node;  //targetをランダムに定める. 
					write(self.target_node);
				}
				
			
				
			current_path <- compute_path(graph: road_network, target: target_node );
			
			
			if(current_path = nil)
			{
				driving_area <- nil;
			}
}
	
	
	reflex go_passenger when: ovjective = "go_pass"{      //乗客の場所に向かっている状況
		do driving_action;
		
		if(location = point(target_nd)){
			write("destination");
		ask passenger at_distance(0){
			write("ask");
		                //乗客の場所に到着すると,targetを乗客の目的地に変更する.
		
			myself.final_target <- myself.desti;
			myself.ovjective <- "riding";              //ovjectiveを変更
			myself.carrying <- true;                  //乗車中とする.→赤色
			self.ovjective <- "die";
			myself.pas_pass<- false;
			myself.current_path <- myself.compute_path(graph:road_network, target: self.target_nd_p);
			
			write("compute");
			
			
			
			}
		} 	
	}
	
	
	
	reflex wander when:ovjective = "empty"{    //空車の時の挙動
	
		do driving_action;          //道路上を目的地に向かって進む
		ask passenger at_distance(taxi_search_distance){     //一定距離に乗客がいる場合,ovjectiveを変更,targetを乗客の場所に変更する.
			if(self.ovjective = "calling"){
				myself.ovjective <- "go_pass";	
				myself.desti <- self.target;
				self.ovjective <- "waiting";          //乗客エージェントのovjectiveをdieにする.
				myself.pas_pass <- true;
				myself.target_nd <- self.stay_nd_p;	
				write(myself.target_nd);
				myself.current_path <- myself.compute_path(graph: road_network, target: myself.target_nd) ;
				write(myself.target_nd);
				
			}
			
		}
		if(distance_to_goal = 0.0 and ovjective = "empty"){                    //空車の状態でtargetに到着した場合はランダムに次のtargetを定める.
			
				ask taxi_manager{
					do choice_target;			
					myself.target_node <- self.target_node;  //targetをランダムに定める. 
					myself.driving_area <- self.current_area;
					}
					
				
			
			
			final_target <- point(target_node);
			current_path <- compute_path(graph: road_network, target: target_node ,on_road: road ,source:intersection);
			if(current_path = nil){
				driving_area <- nil;
				
			}
		}	
	}
		

	
	reflex riding_time when:ovjective = "riding"{     //乗降中（１０秒）
		if(pay_time >= 10){
			ovjective <- "go_target";
			pay_time <- 0.0;
			
			}
			
			pay_time <- pay_time + step;
		
	}
	
	reflex go_target when:ovjective = "go_target"{    //乗客を乗せて目的地に向かっている状況
		do driving_action;
		if(distance_to_goal = 0.0){                     //目的地に到着した場合
			
				
				ask taxi_manager{
					
					do choice_target;			
					myself.target_node <- self.target_node;  //targetをランダムに定める. 
					myself.driving_area <- self.current_area;
					}
					
			
			
			current_path <- compute_path(graph:road_network,target: target_node); 
			ovjective <- "paying";                        //ovjectiveを変更
			//carrying <- false;                          //空車とする.→緑色
			
			
			
		}
	}
	
	reflex pay_time when:ovjective = "paying"{    //乗降中（２０秒）
		if(pay_time >= 20){
			ovjective <-"empty";
			carrying <- false;
			pay_time <-0.0;
		}
		
		pay_time <- pay_time + step;		
	}
	
	point calcul_loc {
		float val <- (road(current_road).lanes - current_lane) + 0.5;
		val <- on_linked_road ? val * - 1 : val;
		if (val = 0) {
			return location; 
		} else {
			return (location - {cos(heading + 90) * val, sin(heading + 90) * val});
		}
	}
	

	aspect circle{
		point loc <- calcul_loc();
		//draw circle(5#m) color:carrying ? #red : (pas_pass ? #orange : #blue);
		draw box(vehicle_length, 1,1) at: loc rotate:  heading color: #orange;
		draw triangle(0.5) depth: 1.5 at: loc rotate:  heading + 90 color: carrying ? #red : (pas_pass ? #orange : #blue);	
	}
}

species make_passenger{    //乗客生成のためのエージェント
	reflex make_agent{
		if flip(create_rate){
			create passenger {          //乗客エージェントを一定確率で生成, locationとtargetはランダムに決定（building）
				stay_nd_p <- one_of(intersection);     //初期値の建物を指定
				target_nd_p <- one_of(intersection);   //taegetの建物を指定
				location <- point(stay_nd_p);
				target <- point(target_nd_p);    
				amount_of_passenger <- amount_of_passenger + 1;
				now_passenger_num <- now_passenger_num + 1;
				ovjective <- "calling";  //乗客の現在の状況（calling or waiting or die）
			}
		}
	}
	
	
}

species passenger {       //乗客エージェント
	point target ;
	string ovjective ;
	intersection stay_nd_p;
	intersection target_nd_p;
	
	reflex wait_time{
		if(ovjective = "waiting" or "calling"){
			waiting_time <- waiting_time + step;
		}		
	}

	reflex die{                   //ovjectiveがdieのエージェント＝タクシーに発見されたエージェントは消滅する
		if(ovjective = "die"){
			now_passenger_num <- now_passenger_num - 1;
			do die;
		}
	}
	
	
	
	aspect circle{
		draw circle(1#m) color: #yellow;
	}
	
}

species area_location{
	string area_name;
	list<point> area_data <- [{5000,3500},{8000,7000},{3600,4800},{3200,6600},{6500,5000},{6500,8000},{5200,1700},{6000,6000}];
	list<string> area_name_data <- ["kasanui","sizu","yamada","oikami","oji","tamagawa","tokiwa","yagura"];
	aspect make{
		
	}
}

species taxi_manager{
	int station_taxi_max <- 10;
	bool exist <- false;
	int wait_pass_num <- 0;
	intersection target_node;
	string current_area;
int station_taxi_num <- 0;

	init{
			//location <- point(one_of(intersection where(each.highway = "station")));
			location <- point(intersection[8780]);
			station_taxi_num <- 0;
			
	
		}
	
	action choice_target{   //目的地選択のためのaction
	//target_node <- one_of(intersection);

	if(flip(0.2)){	
		target_node <- one_of(intersection where((each.area_name = "kasanui")and(each.not_node = false)));
		current_area <- "kasanui";
	}else if(flip(0.25)){
		target_node <- one_of(intersection where((each.area_name = "sizu")and(each.not_node = false)));
		current_area <- "sizu";
	}else if(flip(0.16)){
		target_node <- one_of(intersection where((each.area_name = "yamada")and(each.not_node = false)));
		current_area <- "yamada"; 
	}else if(flip(0.3)){
		target_node <- one_of(intersection where((each.area_name = "oikami")and(each.not_node = false)));
		current_area <- "oikami";
	}else if(flip(0.428)){
		target_node <- one_of(intersection where((each.area_name = "tamagawa")and(each.not_node = false)));
		current_area <- "tamagawa";
	}else if(flip(0.25)){
		target_node <- one_of(intersection where((each.area_name = "oji")and(each.not_node = false)));
		current_area <- "oji";
	}else if(flip(0.67)){
		target_node <- one_of(intersection where((each.area_name = "tokiwa")and(each.not_node = false)));
	}else if(flip(0.9)){
		target_node <- one_of(intersection where((each.area_name = "yagura")and(each.not_node = false)));
	current_area <- "yagura";
		}else{
		target_node <- one_of(intersection );
				current_area <- "other";
		}	
	}
}

