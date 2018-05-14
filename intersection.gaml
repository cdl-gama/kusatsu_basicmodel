/**
* Name: intersection
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model intersection

/* Insert your model definition here */

import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"



global{
		list<intersection> traffic_signals;
		int time_to_set_offset <- 1;
	    float sig_split parameter: "signal split" category: "signal sgent" min: 0.1 max: 1.0 init:0.5 step: 0.1;
		bool priority_offset <- true; //優先オフセットを実行するための変数
		file shape_file_node_joint <- file("../includes/ver5/nodes3747t.shp");
	
	
}

species intersection_make{  //交差点エージェントを生成するためのエージェント
	init{
		loop i from: 0 to: 7{
			create area_location {
				location <- area_data[i];
				area_name <- area_name_data[i];
			}
		} 
		
		create intersection from: shape_file_node_joint with:[highway::(string(read("signaltype")))]{
			
			
			ask area_location at_distance(2#km){
			myself.area_name <- self.area_name;	
			}
		}
		
		write("intersection");
		starting_point <- one_of(intersection where each.is_traffic_signal);
		traffic_signals <- intersection where each.is_traffic_signal;
		general_speed_map <- road as_map (each::(each.shape.perimeter / (each.maxspeed)));
		road_network <-  as_driving_graph(road, intersection);   //道路と交差点を結びつけて道路ネットワークを生成
		
		//道路と繋がりのない交差点エージェントを削除		
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
		
		do die;
	}
}

species intersection skills: [skill_road_node] {
	bool is_traffic_signal;
	bool not_node <- false;
	bool have_trunk <- false;
	string type;
	string highway;
	string end;
	int cycle <- 60; 
	float split <- 0.5; 
	int counter;
	int offset <- 0;
	bool is_blue <- true;
	int phase_time <- int(cycle*split) ;
	list<road> current_shows ; 
	list<intersection> adjoin_node;
	string mode <- "independence";
	list<agent> c1; 
	agent c2; 
	int trf_vol; //交差点の交通量
	float l1 <- 0.001; //第一現示の飽和度
	float l2 <- 0.001; //第二現示の飽和度
	float l; //交差点の飽和度(l1 + l2)
	int L <- 5; //損失時間
	string area_name;
	
	
	
	init{
		write(name);
		if(highway != nil){
				is_traffic_signal <- true;
			}
		if(is_traffic_signal = true){  //信号機と隣接する道路情報の保持
				write("true");
		//4差路交差点の場合
			if (length(roads_in) = 4) {
				if(is_blue){		
					current_shows <- [road(roads_in[0]),road(roads_in[2])];	
						
						if((road(roads_in[0]).highway = "trunk" or road(roads_in[2]).highway = "trunk")){
						split <- split - 0.2;
						write(self);
						have_trunk <- true;
						if(split > 1){
							split <- 0.9;
						}
					}
					
								
				}else{
					current_shows <- [road(roads_in[1]),road(roads_in[3])]; 
					
						if( (road(roads_in[1]).highway = "trunk" or road(roads_in[3]).highway = "trunk")){
						split <- split + 0.2;
						have_trunk <- true;
						write(self);
						if(split < 0){
							split <- 0.1;
						}
					}
				}		
				
			}
			
		//三叉路交差点の場合
			if (length(roads_in) = 3) {		
				if(is_blue){
					current_shows <- [road(roads_in[0])];	
						if((road(roads_in[0]).highway = "trunk")){
							split <- split - 0.2;
							have_trunk <- true;
							write(self);
						if(split > 1){
							split <- 0.9;
						}	
				}		
				}else{
					current_shows <- [road(roads_in[1]),road(roads_in[2])]; 
	
						if((road(roads_in[1]).highway = "trunk" or road(roads_in[3]).highway = "trunk")){
							split <- split + 0.2;
							have_trunk <- true;
							write(self);
							if(split < 0){
								split <- 0.1;
						}
					}
				}
			}
		}
				
	}
	

//オフセット設定（広域信号制御の際に使用）
//	reflex set_offset when:time = time_to_set_offset and is_traffic_signal{
//		starting_point.mode <- "start";
//		loop i from: 0 to: length(starting_point.adjoin_node)-1 {
//			starting_point.adjoin_node[i].offset <- 0;
//		}	
//	}


//サイクル長とスプリットを決定するためのメソッド(信号制御の際に使用)交通工学参照
//	reflex cal_cyc_spl when: time = 3600 and is_traffic_signal = true{
//			if (length(roads_in) = 4) {
//						
//					l1 <- max([road(roads_in[0]).flow/1800,road(roads_in[2]).flow/1800,0.001]);							
//					l2 <- max([road(roads_in[1]).flow/1800,road(roads_in[3]).flow/1800,0.001]); 				
//			}
//			
//			if (length(roads_in) = 3) {		
//				
//					l1 <- max([road(roads_in[0]).flow/1800,0.001]);				
//					l2 <- max([road(roads_in[1]).flow/1800,road(roads_in[2]).flow/1800,0.001]) ; 
//			}
//			
//			l <- (l1 + l2) ;
//			
//				cycle <- int((1.5*L+5)/(1-l)) + 30;
//				split <- 1 - (((cycle-L)*(l1/l))/cycle) with_precision 4;
//				
//				if(split > 0.75){
//					split <- 0.75;
//				}else if(split < 0.25){
//					split <- 0.25;
//				}
//		}

//起点モード（広域信号制御の際に使用）
//	reflex set_adjoinnode when: time = 0{
//		
//		if(length(self.roads_out) >1){
//			loop i from: 0 to: length(self.roads_out) - 1 {
//				self.adjoin_node <- self.adjoin_node + [intersection(road(roads_out[i]).target_node)] where each.is_traffic_signal;
//			}
//		}
//	}
	

//現示の初期化
	
		
	//現示の切り替え
	reflex start when: counter >= phase_time and is_traffic_signal{
		
			counter <- 0;
			
		if(length(c1) != 0){
			loop i to:0 from: length(c1)-1{				
				
				
				//追加　西浦 4/27
				vehicle(c1[i]).checked <- false;
				
			//注意//
			//普通車以外の自動車を信号制御の対象とする場合
			//信号制御の対象とするエージェントのspeicesに「checked」の変数をbool型で追加
			//以下のif文を追加この位置に追加
			//		if(contains(信号制御の対象とするエージェントの型名,c1[i])){
			//			信号制御の対象とするエージェントの型名(c1[i]).checked <- false;
			//		}
			if(contains(vehicle,c1[i])){
				vehicle(c1[i]).checked <- false;
				}
			}
		}
			c1 <- nil;	
			if (length(roads_in) = 4) {
				if(is_blue){		
					current_shows <- [road(roads_in[0]),road(roads_in[2])];
					phase_time <- int(cycle*split);	
				}else{
					current_shows <- [road(roads_in[1]),road(roads_in[3])];				
					phase_time <- int(cycle*(1-split));	
				}
			}
			if (length(roads_in) = 3) {		
				if(is_blue){
					current_shows <- [road(roads_in[0])];			
					phase_time <- int(cycle*split);			
				}else{
					current_shows <- [road(roads_in[1]),road(roads_in[2])];
					phase_time <- int(cycle*(1-split));	 
				}
			}
			is_blue <- !is_blue;
	} 
	
	//四差路用信号制御処理
	reflex stop4 when:is_traffic_signal and length(roads_in) = 4
	{
		
		counter <- counter + 1;
				
		if(length(current_shows) != 0){
			if(length(current_shows[0].all_agents) != 0 ){
				
					loop i to:0 from: length(current_shows[0].all_agents)-1{
									
						if(contains(agents_at_distance(10.0),current_shows[0].all_agents[i]) and !contains(c1,current_shows[0].all_agents[i])){
							add current_shows[0].all_agents[i] to: c1;
							
							//以下１文追加　西浦4/27
							vehicle(current_shows[0].all_agents[i]).checked <- true;
							
							//注意//
							//普通車以外の自動車を信号制御の対象とする場合
							//信号制御の対象とするエージェントのspeicesに「checked」の変数をbool型で追加
							//以下のif文を追加この位置に追加
							//		if(contains(信号制御の対象とするエージェント,current_shows[0].all_agents[i])){
							//			信号制御の対象とするエージェント(current_shows[0].all_agents[i]).checked <- true;
							//		}
							
							
							if(contains(vehicle,current_shows[0].all_agents[i])){
								vehicle(current_shows[0].all_agents[i]).checked <- true;
							}
						}
					}
			}			
			
			if(length(current_shows[1].all_agents) != 0 ){
				write(vehicle);
				write(car);
					loop i to:0 from: length(current_shows[1].all_agents)-1{
									
						if(contains(agents_at_distance(10.0),current_shows[1].all_agents[i]) and !contains(c1,current_shows[1].all_agents[i])){
							add current_shows[1].all_agents[i] to: c1;
					
					
							vehicle(current_shows[1].all_agents[i]).checked <- true;
						
							//注意//
							//普通車以外の自動車を信号制御の対象とする場合
							//信号制御の対象とするエージェントのspeicesに「checked」の変数をbool型で追加
							//以下のif文を追加この位置に追加
							//		if(contains(信号制御の対象とするエージェント,current_shows[0].all_agents[i])){
							//			信号制御の対象とするエージェント(current_shows[0].all_agents[i]).checked <- true;
							//		}
			
							if(contains(vehicle,current_shows[1].all_agents[i])){
								vehicle(current_shows[1].all_agents[i]).checked <- true;
								write(name);
							}
						}
					}
				}
			}
		}
		
		
		
	//三差路用信号制御処理		
	reflex stop3 when:is_traffic_signal and  length(roads_in) =  3{
		
		counter <- counter + 1;
			
		//現示の道路に車がいない時の処理
		if(length(current_shows) != 0){
			
			if(length(current_shows[0].all_agents) != 0 ){
				
				loop i to:0 from: length(current_shows[0].all_agents)-1{
									
						if(contains(agents_at_distance(10.0),current_shows[0].all_agents[i]) and !contains(c1,current_shows[0].all_agents[i])){
							add current_shows[0].all_agents[i] to: c1;
					
					
					//以下１文追加　西浦4/27
							vehicle(current_shows[0].all_agents[i]).checked <- true;
							
							
							//注意//
							//普通車以外の自動車を信号制御の対象とする場合
							//信号制御の対象とするエージェントのspeicesに「checked」の変数をbool型で追加
							//以下のif文を追加この位置に追加
							//		if(contains(信号制御の対象とするエージェント,current_shows[0].all_agents[i])){
							//			信号制御の対象とするエージェント(current_shows[0].all_agents[i]).checked <- true;
							//		}
										
						if(contains(vehicle,current_shows[0].all_agents[i])){
							vehicle(current_shows[0].all_agents[i]).checked <- true;
						}
					}
				}
			}
			
			//現示の道路が二本以上の時
			if(length(current_shows) > 1){
				if(length(current_shows[1].all_agents) != 0 ){
					loop i to:0 from: length(current_shows[1].all_agents)-1{
									
						if(contains(agents_at_distance(10.0),current_shows[1].all_agents[i]) and !contains(c1,current_shows[1].all_agents[i])){
							add current_shows[1].all_agents[i] to: c1;


								vehicle(current_shows[1].all_agents[i]).checked <- true;

					
							//注意//
							//普通車以外の自動車を信号制御の対象とする場合
							//信号制御の対象とするエージェントのspeicesに「checked」の変数をbool型で追加
							//以下のif文を追加この位置に追加
							//		if(contains(信号制御の対象とするエージェント,current_shows[0].all_agents[i])){
							//			信号制御の対象とするエージェント(current_shows[0].all_agents[i]).checked <- true;
							//		}
					
		
							if(contains(vehicle,current_shows[1].all_agents[i])){
								vehicle(current_shows[1].all_agents[i]).checked <- true;
							}
						}
					}
				}
			}
		}
	}
	
	
	aspect geom3D {
		if (is_traffic_signal) {	
			//draw box(10,10,10) color:rgb("black");
			draw sphere(10) at: {location.x,location.y,12} color: is_blue ? #green : #red;
		}
	}
}


