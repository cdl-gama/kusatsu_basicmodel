/**
* Name: vehicle
* Author: nishiura
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model vehicle

/* Insert your model definition here */


import "./initialize.gaml"
import "./car.gaml"
import "./road.gaml"
import "./building.gaml"
import "./intersection.gaml"
import "./administrator.gaml"

global{
	
	
}

species vehicle skills:[advanced_driving]{
	bool checked;
	
	init{
		speed <- 60#km/#h;	
		checked <- false;   //信号停止のための変数
		
	
	}
	
	action driving_action{    //信号機が青ならば進む
		if(checked = false){
			do drive;
		}
	}
	
	
	
	
	
	
	
}