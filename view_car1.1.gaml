/**
* Name: viewcar11
* Author: cent1
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model viewcar11

/* Insert your model definition here */

import "./view_road.gaml"
import "./view_building.gaml"
import "./view_intersection.gaml"

global{
	file car_icon <- file("../icons/car.png");  //車の画像データ
	file car_location <- (csv_file("../results/car_location.csv"));  //logデータの読み込み
	matrix loc <- matrix(car_location);   //読み込んだlogデータを配列として保持	
}

species car_make{  //車を生成するエージェント
	
	int j <- 0;
	
	reflex make{
		loop i  from:j to:loc.rows{        //配列の最後までループする
			j <- j + 1;
			
			if(float(loc[0,i])=0.0){  //1サイクル分のデータが終わったら0.0が入っている
				break;
				
			}
			create car{
				location <- {float(loc[0,i]),float(loc[1,i]),3.0};   //配列から位置データを取り入れる
				heading <- int(loc[2,i]);     //方向のデータ
				//car_color <- rgb(loc[3,i]);
			}
		
		}
	}
}

species car {  //車エージェント
	int x <-0;
	int heading; //車の向き
	rgb car_color;
	
	aspect icon{    //車を画像で表示
		draw car_icon size:3#m rotate:heading;
	}
	
	aspect box{  
		draw box(3,1,1) at: location rotate:heading color:car_color;
	}
	
	
	
	reflex delete_car{   //1サイクル後に消滅する
		if(x=1){
		do die;
		
		}
		x <- x +1;
	}
	
}