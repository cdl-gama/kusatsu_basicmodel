/**
* Name: scheduledbus
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/







model bus


import "./initialize.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"
import "./vehicle.gaml"



/* Insert your model definition here */

global{
	
	file busstops_csvfile <- csv_file("../includes/bus_target/busstops.csv", true);
	file minakusa_pana_time_csvfile <- csv_file("../includes/bus_time/minakusa_pana_time.csv",true);
	file minakusa_kasa_time_csvfile <- csv_file("../includes/bus_time/minakusa_kasa_time.csv",true);
	file minakusa_kaga_time_csvfile <- csv_file("../includes/bus_time/minakusa_kaga_time.csv",true);
	file ritsumei_pana_time_csvfile <- csv_file("../includes/bus_time/ritsumei_pana_time.csv",true);
	file ritsumei_kasa_time_csvfile <- csv_file("../includes/bus_time/ritsumei_kasa_time.csv",true);
	file ritsumei_kaga_time_csvfile <- csv_file("../includes/bus_time/ritsumei_kaga_time.csv",true);
	file minakusa_shuttle_time_csvfile <- csv_file("../includes/bus_time/minakusa_shuttle.csv",true);
	file ritsumei_shuttle_time_csvfile <- csv_file("../includes/bus_time/ritsumei_shuttle.csv",true);
	
	file path_file1 <- csv_file("../includes/bus_route/pana_path1.csv" ,true);
	file path_file2 <- csv_file("../includes/bus_route/kagayaki_path1.csv" ,true);
	file targets_file1 <- csv_file("../includes/bus_target/pana_targets1.csv",true);
	file targets_file2 <- csv_file("../includes/bus_target/kagayaki_targets1.csv",true);
	file path_file3 <- csv_file("../includes/bus_route/kasayama_path1.csv" ,true);
	file targets_file3 <- csv_file("../includes/bus_target/kasayama_targets1.csv",true);
	file path_file4 <- csv_file("../includes/bus_route/pana_path2.csv" ,true);
	file targets_file4 <- csv_file("../includes/bus_target/pana_targets2.csv",true);
	file path_file5 <- csv_file("../includes/bus_route/kagayaki_path2.csv" ,true);
	file targets_file5 <- csv_file("../includes/bus_target/kagayaki_targets2.csv",true);
	file path_file6 <- csv_file("../includes/bus_route/kasayama_path2.csv" ,true);
	file targets_file6 <- csv_file("../includes/bus_target/kasayama_targets2.csv",true);
	
		
	matrix bus_stops <- matrix(busstops_csvfile);

	matrix minakusa_pana_time <- matrix(minakusa_pana_time_csvfile);
	matrix minakusa_kasa_time <- matrix(minakusa_kasa_time_csvfile);
	matrix minakusa_kaga_time <- matrix(minakusa_kaga_time_csvfile);
	matrix ritsumei_pana_time <- matrix(ritsumei_pana_time_csvfile);
	matrix ritsumei_kasa_time <- matrix(ritsumei_kasa_time_csvfile);
	matrix ritsumei_kaga_time <- matrix(ritsumei_kaga_time_csvfile);
	matrix minakusa_shuttle_time <- matrix(minakusa_shuttle_time_csvfile);
	matrix ritsumei_shuttle_time <- matrix(ritsumei_shuttle_time_csvfile);
	
	
	float distance_to_busstop <- 15#m;
	float distance_to_people <- 5#m;
	int nb_bus <- 0;
	int nb_people <- 1;
	 
	 
	int j <- 0;
	int k <- 0;
	int l <- 0;
    int m <- 0;
    int n <- 0;
    int o <- 0;
    int p <- 0;
    int q <- 0;
    int r <- 0;
    int s <- 0;
	
	map pana_route;
	
}



species bus_to_BKC parent:vehicle {  //バスエージェント
	
	rgb bus_color <- #red;
	intersection target ;
	intersection bus_start;
	intersection start;
	float travel_time;
	int m ;
	path mem_path;
	point mem_current_target;
	point mem_final_target;
	agent mem_current_road;
	list<point> mem_targets;
	
	string ovjective;
	int riding_count;	
	float bus_length <- 8.0#m;
	float joint_bus_length <- 15#m;
	
	reflex shuttle when:ovjective="shuttle"{
		
		do driving_action;
		
	}
	
	
	reflex drive when:ovjective="drive"{
		
		do driving_action;
		
		ask busstop1 at_distance(distance_to_busstop){
			
			if(self.waiting_count >= 1 and myself.riding_count <= 20){
				myself.ovjective <- "people_on_busstop";
			}
			
		}
		
	}
	
	
	
	reflex stop_on_busstop when:ovjective="people_on_busstop"{
		
		ask busstop1 at_distance(distance_to_busstop) {
			self.ovjective <- "give";
		}
		
		
		
		
	}

	/*reflex drive_to_goal when:ovjective="drive_to_goal"{
		do driving_action;
    }*/
	
	
	reflex goal_point when:final_target=nil{
				
		
		if(current_road != nil){
				//road(current_road).all_agents <- road(current_road).all_agents - self;
				//remove self from: list(road(current_road).agents_on[0][0]);
				road(current_road).all_agents <- road(current_road).all_agents - self;
				remove self from: list(road(current_road).agents_on[0][0]);
				
			}
			do die;  
			}
	
	
	aspect def{
		draw circle(20) color:#yellow;
	}
	
	
	/*aspect icon {
		point loc <- calcul_loc();
				draw bus_img size: vehicle_length at: loc rotate: heading + 90 ;
	}
	* 
	*/
	
	aspect car3D {
		if (current_road) != nil {
			point loc <- calcul_loc();
			draw box(vehicle_length, 1,1) at: loc rotate:  heading color: bus_color;
			draw triangle(0.5) depth: 1.5 at: loc rotate:  heading + 90 color: bus_color;	
		}
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
	
}


species people {  // 乗客エージェント
	
	string ovjective;
	
	reflex wake_up when: ovjective = "start"{  //busstopで人が発生
	ask busstop1 at_distance(distance_to_busstop) {
		self.waiting_count <- self.waiting_count + 1;
		myself.ovjective <- "wait";
		}
	}
	
	reflex wait when:ovjective="wait"{
		
	}
	
	reflex riding when: ovjective = "die"{
		
		
		ask busstop1 at_distance(distance_to_people) {
			self.waiting_count <- self.waiting_count - 1;
			if(self.waiting_count = 0){
				ask bus_to_BKC {
			self.ovjective <- "drive";
			myself.ovjective <- "mu";
			}
		
		}
	}
	do die;
	
	}
	//	waiting_count <- waiting_count + 1;
		
	
	aspect pep{
		draw circle(4) color:#white;
	}
	
}

species node_targets {
	aspect taro {
		draw square(5) color: #black;
	}
}

species pana_node_turn {
	aspect taro {
		draw square(5) color: #black;
	}
}

species kasayama_node {
	aspect taro {
		draw square(5) color: #black;
	}
}

species kasayama_node2 {
	aspect taro {
		draw square(5) color: #black;
	}
}

species kagayaki_node {
	aspect taro {
		draw square(5) color: #black;
	}
}

species kagayaki_node_turn {
	aspect taro {
		draw square(5) color: #black;
	}
}




species busstop1 {  //バス停エージェント
	
	string ovjective;
	int waiting_count;
	
	reflex mu when:ovjective="mu"{
		
	}
	
	reflex riding_number when:ovjective="give"{
		
	ask bus_to_BKC at_distance(distance_to_busstop){
			self.riding_count <- self.riding_count + myself.waiting_count;
			
		}
	
	ask people at_distance(distance_to_busstop){
			self.ovjective <- "die";
		}

	}
	aspect bef{
		draw circle(10) color:#blue;
	}
	
}


species make_bus{    //バスを生成させるためのエージェント

	init{    
		loop i from: 0 to: bus_stops.rows-1{
			
			create busstop1 {      //バス停エージェントの生成
			location <- to_GAMA_CRS({float(bus_stops[0, i]), float(bus_stops[1, i])});
			ovjective <- "mu";
			waiting_count <- 0;
			}
		}
	}
    
    
    reflex make_bus1{
    	
 			//みなくさからしゃとる
 	if(time = int(minakusa_shuttle_time[2,r])){
 		
		r <- r + 1 ;
		
		create bus_to_BKC number:1{
			right_side_driving <- false;
			vehicle_length <- bus_length;
			max_speed <- 100#km /#h;
			ovjective <- "shuttle";
			
			location <- point((intersection(8763)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			
		matrix path_matrix <- matrix(path_file2);
		//write(path_matrix);
		list path_list;
		
		
		loop i from: 0 to: path_matrix.rows -1 {
			//write(path_matrix[0,i]);
			path_list <- path_list + road[int(path_matrix[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		//write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix <- matrix(targets_file2);
		//write(targets_matrix);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix.rows-1 {
			
			create kagayaki_node number:1 {
				location <- ({float(targets_matrix[0,i]),float(targets_matrix[1,i]),float(targets_matrix[2,i])});
				//write(location);
			}
			
			
			targets_list <- targets_list + point(kagayaki_node[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; //[point(node_targets[0]),point(node_targets[1])];
		//write(bus_targets);
		targets <- bus_targets;
		current_target <- point(kagayaki_node[0]);
		final_target <- point(kagayaki_node[98]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}
		}   	
    
 			   
    		//りつめいからしゃとる
    		if(current_hour = int(ritsumei_shuttle_time[0,s]) and current_hour = int(ritsumei_shuttle_time[1,s])){
			s <- s+1 ;
			
		create bus_to_BKC number:1{
			right_side_driving <- false;
			max_speed <- 100#km /#h;
			vehicle_length <- bus_length;
			ovjective <- "drive";
			
			location <- point((intersection(6849)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			
		matrix path_matrix6 <- matrix(path_file6);
		write(path_matrix6);
		list path_list;
		
		
		loop i from: 0 to: path_matrix6.rows -1 {
			write(path_matrix6[0,i]);
			path_list <- path_list + road[int(path_matrix6[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix6[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix6 <- matrix(targets_file6);
		write(targets_matrix6);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix6.rows-1 {
			
			create kasayama_node2 number:1 {
				location <- ({float(targets_matrix6[0,i]),float(targets_matrix6[1,i]),float(targets_matrix6[2,i])});
				write(location);
			}
			
			
			targets_list <- targets_list + point(kasayama_node2[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; //[point(kasayama_node[0]),point(kasayama_node[1])];
		write(bus_targets);
		targets <- bus_targets;
		current_target <- point(kasayama_node2[0]);
		final_target <- point(kasayama_node2[91]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}	
		}	
    
    
    
			//みなくさからパナ東
			if(current_hour =int(minakusa_pana_time[1,j]) and current_hour = int(minakusa_pana_time[2,j])){
			j <- j+1;
			
			
		loop i from: 0 to:bus_stops.rows-1{
			create people number:nb_people{
				location <-  to_GAMA_CRS({float(bus_stops[0, i]), float(bus_stops[1, i])});
				ovjective <- "start";
			}
		
		}
		create bus_to_BKC number:1{
			right_side_driving <- false;
			vehicle_length <- bus_length;
			max_speed <- 70#km /#h;
			ovjective <- "drive";
			
			location <- point((intersection(8763)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			matrix path_matrix <- matrix(path_file1);
		//write(path_matrix);
		list path_list;
		
		
		loop i from: 0 to: path_matrix.rows -1 {
			//write(path_matrix[0,i]);
			path_list <- path_list + road[int(path_matrix[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		//write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix <- matrix(targets_file1);
		//write(targets_matrix);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix.rows-1 {
			
			create node_targets number:1 {
				location <- ({float(targets_matrix[0,i]),float(targets_matrix[1,i]),float(targets_matrix[2,i])});
				//write(location);
			}
			
			
			targets_list <- targets_list + point(node_targets[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; //[point(node_targets[0]),point(node_targets[1])];
		//write(bus_targets);
		targets <- bus_targets;
		current_target <- point(node_targets[0]);
		final_target <- point(node_targets[56]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}
		}
	
	
	
	//みなくさからかがやき
	if(current_hour = int(minakusa_kaga_time[0,k]) and current_hour = int(minakusa_kaga_time[1,k])){
		k <- k + 1 ;
		loop i from: 0 to:bus_stops.rows-1{
			create people number:nb_people{
				location <-  to_GAMA_CRS({float(bus_stops[0, i]), float(bus_stops[1, i])});
				ovjective <- "start";
			}
		
		}
		create bus_to_BKC number:1{
			right_side_driving <- false;
			vehicle_length <- bus_length;
			speed <- 40#km /#h;
			ovjective <- "drive";
			
			location <- point((intersection(8763)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			
		matrix path_matrix <- matrix(path_file2);
		//write(path_matrix);
		list path_list;
		
		
		loop i from: 0 to: path_matrix.rows -1 {
			//write(path_matrix[0,i]);
			path_list <- path_list + road[int(path_matrix[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		//write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix <- matrix(targets_file2);
		//write(targets_matrix);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix.rows-1 {
			
			create kagayaki_node number:1 {
				location <- ({float(targets_matrix[0,i]),float(targets_matrix[1,i]),float(targets_matrix[2,i])});
				//write(location);
			}
			
			
			targets_list <- targets_list + point(kagayaki_node[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; //[point(node_targets[0]),point(node_targets[1])];
		//write(bus_targets);
		targets <- bus_targets;
		current_target <- point(kagayaki_node[0]);
		final_target <- point(kagayaki_node[98]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}
		}
		
	
	//みなくさからパナ西
	if(current_hour = int(minakusa_kasa_time[0,l]) and current_hour = int(minakusa_kasa_time[1,l])){
		l <- l+1; 
		loop i from: 0 to:bus_stops.rows-1{
			create people number:nb_people{
				location <-  to_GAMA_CRS({float(bus_stops[0, i]), float(bus_stops[1, i])});
				ovjective <- "start";
			}
		}
		create bus_to_BKC number:1{
			right_side_driving <- false;
			speed <- 40#km /#h;
			vehicle_length <- bus_length;
			ovjective <- "drive";
			
			location <- point((intersection(8763)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			
		matrix path_matrix3 <- matrix(path_file3);
		//write(path_matrix3);
		list path_list;
		
		
		loop i from: 0 to: path_matrix3.rows -1 {
			//write(path_matrix3[0,i]);
			path_list <- path_list + road[int(path_matrix3[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		//write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix3[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix3 <- matrix(targets_file3);
		//write(targets_matrix3);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix3.rows-1 {
			
			create kasayama_node number:1 {
				location <- ({float(targets_matrix3[0,i]),float(targets_matrix3[1,i]),float(targets_matrix3[2,i])});
				//write(location);
			}
			
			
			targets_list <- targets_list + point(kasayama_node[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; //[point(kasayama_node[0]),point(kasayama_node[1])];
		//write(bus_targets);
		targets <- bus_targets;
		current_target <- point(kasayama_node[0]);
		final_target <- point(kasayama_node[91]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}
		}
		
		//りつめいからパナ東
		if(current_hour = int(ritsumei_pana_time[0,o]) and current_hour = int(ritsumei_pana_time[1,o])){
			o <- o+1;
					loop i from: 0 to:bus_stops.rows-1{
			create people number:nb_people{
				location <-  to_GAMA_CRS({float(bus_stops[0, i]), float(bus_stops[1, i])});
				ovjective <- "start";
			}
		
		}
		create bus_to_BKC number:1{
			right_side_driving <- false;
			vehicle_length <- bus_length;
			speed <- 40#km /#h;
			ovjective <- "drive";
			
			location <- point((intersection(6849)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			
		matrix path_matrix4 <- matrix(path_file4);
		write(path_matrix4);
		list path_list;
		
		
		loop i from: 0 to: path_matrix4.rows -1 {
			write(path_matrix4[0,i]);
			path_list <- path_list + road[int(path_matrix4[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix4[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix4 <- matrix(targets_file4);
		write(targets_matrix4);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix4.rows-1 {
			
			create pana_node_turn number:1 {
				location <- ({float(targets_matrix4[0,i]),float(targets_matrix4[1,i]),float(targets_matrix4[2,i])});
				write(location);
			}
			
			
			targets_list <- targets_list + point(pana_node_turn[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; //[point(kasayama_node[0]),point(kasayama_node[1])];
		write(bus_targets);
		targets <- bus_targets;
		current_target <- point(pana_node_turn[0]);
		final_target <- point(pana_node_turn[91]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}
			
			
			
			}
		
		
		//りつめいからかさやま
		if(current_hour = int(ritsumei_kasa_time[0,m]) and current_hour = int(ritsumei_kasa_time[1,m])){
			m <- m+1 ;
			loop i from: 0 to:bus_stops.rows-1{
			create people number:nb_people{
				location <-  to_GAMA_CRS({float(bus_stops[0, i]), float(bus_stops[1, i])});
				ovjective <- "start";
			}
		
		}
		create bus_to_BKC number:1{
			right_side_driving <- false;
			vehicle_length <- bus_length;
			max_speed <- 60#km /#h;
			ovjective <- "drive";
			
			location <- point((intersection(6849)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			
		matrix path_matrix6 <- matrix(path_file6);
		write(path_matrix6);
		list path_list;
		
		
		loop i from: 0 to: path_matrix6.rows -1 {
			write(path_matrix6[0,i]);
			path_list <- path_list + road[int(path_matrix6[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix6[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix6 <- matrix(targets_file6);
		write(targets_matrix6);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix6.rows-1 {
			
			create kasayama_node2 number:1 {
				location <- ({float(targets_matrix6[0,i]),float(targets_matrix6[1,i]),float(targets_matrix6[2,i])});
				write(location);
			}
			
			
			targets_list <- targets_list + point(kasayama_node2[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; //[point(kasayama_node[0]),point(kasayama_node[1])];
		write(bus_targets);
		targets <- bus_targets;
		current_target <- point(kasayama_node2[0]);
		final_target <- point(kasayama_node2[91]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}	
		}
			
			
		//りつめいからかがやき
		if(current_hour = int(ritsumei_kaga_time[0,n]) and current_hour = int(ritsumei_kaga_time[1,n])){
			n <- n+1 ;
			loop i from: 0 to:bus_stops.rows-1{
			create people number:nb_people{
				location <-  to_GAMA_CRS({float(bus_stops[0, i]), float(bus_stops[1, i])});
				ovjective <- "start";
			}
		
		}
		
		write("a");
		create bus_to_BKC number:1{
			right_side_driving <- false;
			vehicle_length <- bus_length;
			speed <- 40#km /#h;
			ovjective <- "drive";
			
			location <- point((intersection(6849)));
			//location <- point((intersection(8780)));
			//current_target <- point(intersection(23171));
			//target <- intersection(889);
			//final_target <- point((intersection(889)));
		
		
		//上記処理で書き出したファイルに記述されているcurrent_pathを読み込み，移動エージェントのcurrent_pathに代入	
			
		matrix path_matrix5 <- matrix(path_file5);
		write(path_matrix5);
		list path_list;
		
		
		loop i from: 0 to: path_matrix5.rows -1 {
			write(path_matrix5[0,i]);
			path_list <- path_list + road[int(path_matrix5[0,i])];			
		}
		
		
		path bus_path <- path_list as path;
		write(bus_path);
		current_path <- bus_path;
		current_road <- road[int(path_matrix5[0,0])];
		
			
		
			//上記処理で書き出したcsvを読み込んでtargetsに入れる処理
			
		matrix targets_matrix5 <- matrix(targets_file5);
		write(targets_matrix5);
		list<point> targets_list;
		
		
		loop i from: 0 to: targets_matrix5.rows-1 {
			
			create kagayaki_node_turn number:1 {
				location <- ({float(targets_matrix5[0,i]),float(targets_matrix5[1,i]),float(targets_matrix5[2,i])});
				write(location);
			}
			
			
			targets_list <- targets_list + point(kagayaki_node_turn[i]);
			//write(targets_list);
		}
		
		list<point> bus_targets <- targets_list; 
		write(bus_targets);
		targets <- bus_targets;
		current_target <- point(kagayaki_node_turn[0]);
		final_target <- point(kagayaki_node_turn[91]);
			
			
			
			road_network <- road_network with_weights pana_route;
			
			//current_path <- compute_path(graph:road_network,target:target);
		
			mem_path <- current_path;
			mem_current_road <- current_road;
			mem_current_target <- current_target;
			mem_targets <- targets;
			mem_final_target <- final_target;
			
			//save [current_path,current_road,current_target,targets] to: "minakusa_pana_path.csv" type:"csv" ; 
			
			segment_index_on_road <- 0;
			
			add self to: list(road(current_road).agents_on[0][0]);
			road(current_road).all_agents <- road(current_road).all_agents + self;
			
			}	
		}
		
		}//make_bus1の閉
    
    	
   }