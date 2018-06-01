/**
* Name: intersection
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model intersection

/* Insert your model definition here */

import "./view_road.gaml"
import "./view_building.gaml"
import "./view_main.gaml"

global{
		list<intersection> traffic_signals;
		int time_to_set_offset <- 1;
	    float sig_split parameter: "signal split" category: "signal agent" min: 0.1 max: 1.0 init:0.5 step: 0.1;
		bool priority_offset <- true; //優先オフセットを実行するための変数
		file shape_file_node_joint <- file("../includes/ver5/nodes3747t.shp");
	
	
}

species intersection_make{  //交差点エージェントを生成するためのエージェント
	init{
		create intersection from: shape_file_node_joint with:[highway::(string(read("signaltype")))]{
			
			
			
		}
		
		write("intersection");
				road_network <-  as_driving_graph(road, intersection);   //道路と交差点を結びつけて道路ネットワークを生成
		
		
		
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
	//point signal_loc;
	
	
	
	
	init{
		write(name);
		if(highway != nil){
				is_traffic_signal <- true;
			}
		if(is_traffic_signal = true){  //信号機と隣接する道路情報の保持
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
	



//現示の初期化
	
		
	//現示の切り替え
	reflex start when: counter >= phase_time and is_traffic_signal{
		
			counter <- 0;
			
		if(length(c1) != 0){
			loop i to:0 from: length(c1)-1{				
				
				
			
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
							
						}
					}
			}			
			
			if(length(current_shows[1].all_agents) != 0 ){

					loop i to:0 from: length(current_shows[1].all_agents)-1{
									
						if(contains(agents_at_distance(10.0),current_shows[1].all_agents[i]) and !contains(c1,current_shows[1].all_agents[i])){
							add current_shows[1].all_agents[i] to: c1;
					
					
							
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
					
					
					}
				}
			}
			
			//現示の道路が二本以上の時
			if(length(current_shows) > 1){
				if(length(current_shows[1].all_agents) != 0 ){
					loop i to:0 from: length(current_shows[1].all_agents)-1{
									
						if(contains(agents_at_distance(10.0),current_shows[1].all_agents[i]) and !contains(c1,current_shows[1].all_agents[i])){
							add current_shows[1].all_agents[i] to: c1;


							
						}
					}
				}
			}
		}
	}
	
	
	point signal_loc_re(int x){
		float dx0;
		float dy0;
		float dx1;
		float dy1;
		float a0;
		float a1;
		
		if(x = 0 or x = 2){
			dx0 <-location.x - road(roads_in[0]).location.x;
			dy0 <-location.y - road(roads_in[0]).location.y;
			if(dx0 != 0){
		a0 <- dy0/dx0;
		if(x = 0){	
			return point(location.x + 3.0#m,location.y + (3.0#m*a0));
		}else if(x = 2){
			return point(location.x - 3.0#m,location.y - (3.0#m*a0));
		}
		}else{
			if(x = 0){	
			return point(location.x ,location.y + (3.0#m));
		}else if(x = 2){
			return point(location.x ,location.y - (3.0#m));
		}
		}
		
		}
		if(x=1 or x = 3){
		dx1 <-location.x - road(roads_in[1]).location.x;
		dy1 <-location.y - road(roads_in[1]).location.y;
		if(dx1 != 0){
		a1 <- dy1/dx1;
		if(x =1){
			return point(location.x -(3.0#m),location.y - 3.0#m*a1);			
		}else if(x = 3){			
			return point(location.x +(3.0#m),location.y + 3.0#m*a1);
		}
		
		}else{
			if(x =1){
			return point(location.x -(3.0#m),location.y);			
		}else if(x = 3){			
			return point(location.x +(3.0#m),location.y);
		}
		
			
	}
}	

}
	
	
	aspect geom3D {
		if (is_traffic_signal) {	
			//draw box(10,10,10) color:rgb("black");
			//draw sphere(10) at: {location.x,location.y,12} color: is_blue ? #green : #red;
			if(length(roads_in) =  4){
				draw sphere(2#m) at: signal_loc_re(0) color: is_blue ? #green : #red;
				draw sphere(2#m) at: signal_loc_re(1) color: is_blue ? #red : #green;
				draw sphere(2#m) at: signal_loc_re(2) color: is_blue ? #green : #red;
				draw sphere(2#m) at: signal_loc_re(3) color: is_blue ? #red : #green;
			}else if(length(roads_in) =  3){
				draw sphere(2#m) at: signal_loc_re(0) color: is_blue ? #green : #red;
				draw sphere(2#m) at: signal_loc_re(1) color: is_blue ? #red : #green;
				draw sphere(2#m) at: signal_loc_re(2) color: is_blue ? #green : #red;
			}
		}
	}
}


