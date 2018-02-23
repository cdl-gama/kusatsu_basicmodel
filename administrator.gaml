/**
* Name: administrator
* Author: mrks
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model administrator

/* Insert your model definition here */
import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"


species administrator {
	
	int agent_num;
	int loop_count <-0;
	bool mem <- true;
	point setnum <- {0.0,0.0};
	float ave_ave_traveltime; 
	float count <- 0.0;
	int current_generation <- 0; //その時生成する交通量
	int generation_amount <- nb_car; //これまでに生成してきた交通量 / 一時間
	
			
			
//交通量はきだし
//	reflex save_trf_vol when: time = 7200{
//	
//	
//		container data <- ["node_id","trf_vol"];
//		save data to: "graph.csv" type: "csv" rewrite: false;
//		
//		loop i from: 0 to: length(intersection)-1{
//			
//			if(length(intersection[i].roads_in) > 2 or length(intersection[i].roads_out) > 2){
//			data <-  [i,intersection[i].trf_vol];
//			save data to: "trf_vol.csv" type: "csv" rewrite: false;
//			}
//		}
//	}



	reflex throw_the_dice when: current_hour = time_to_thorw+1{
		
		
	
		
		loop i from: 0 to: nb_car*0.1-1{ 
			agent_num <- rnd(nb_car-1);
		ask car[agent_num]{
				self.route_changed <- true;
				write(self);
			}	
		}
		

		loop i from: 0 to: length(road)-1{ 
			if(road[i].flow != 0){
			road[i].ave_traveltime <- road[i].sum_traveltime / road[i].flow;
			}
			if(road[i].highway = "trunk" or road[i].highway = "primary"){
			ave_ave_traveltime <- ave_ave_traveltime + road[i].ave_traveltime;
			count <- count + 1.0;
			}
			road[i].sum_traveltime <- 1.0;
			road[i].flow <- 1;
		}
		
		ave_ave_traveltime <- ave_ave_traveltime / count;
		setnum <- {length(car),ave_ave_traveltime};
		
		general_cost_map <- road as_map (each::(each.ave_traveltime));	
		
		time_to_thorw <- time_to_thorw + 3600;	
	}
	
	
}