// JavaScript Document

var span=document.getElementById("mask");
var logo=document.getElementById("logo");
var  test=new Dragdealer('test', {vertical:true, 
//steps:5, snap:true, 
slide:false,speed:70,
horizontal:false, animationCallback: function(x, y){
	
	if(y>0 && y<0.125){setLogo(1)}
		else if(y>0.125 && y<0.375){setLogo(1)}
		else if(y>0.375 && y<0.625){setLogo(2)}
		else if(y>0.625 && y<0.875){setLogo(2)}
		else if(y>0.875){setLogo(3)}

	span.style.top="-"+(256*(y*0.79))+"px"
	logo.style.top=(256*(y*0.79))-20+"px"
	
	
	},callback:function(x,y){
		
	
			if(y>0 && y<0.125){test.setValue(0,0)}
		else if(y>0.125 && y<0.375){test.setValue(0,0.25)}
		else if(y>0.375 && y<0.625){test.setValue(0,0.5)}
		else if(y>0.625 && y<0.875){test.setValue(0,0.75)}
		else if(y>0.875){test.setValue(0,1)}
		
		
		
		}});
		
function setLogo(index){
	
	if(index==1)logo.style["background-position"]="0px 0px"
	if(index==2)logo.style["background-position"]="0px -106px"
	if(index==3)logo.style["background-position"]="0px -212px"
	
	}

