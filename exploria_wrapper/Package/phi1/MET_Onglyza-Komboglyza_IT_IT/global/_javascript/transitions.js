var transitions = {
	fadeIn: function(obj, delay, duration){
		var elem = document.getElementById(obj).style;
		elem["-webkit-transition-property"] = "all";
		elem["-webkit-transition-delay"] = delay+"ms";
		elem["-webkit-transition-duration"] = duration+"ms";
		elem.opacity = 1;
	},
	
	fadeOut: function(obj, delay, duration){
		var elem = document.getElementById(obj).style;
		elem["-webkit-transition-property"] = "all";
		elem["-webkit-transition-delay"] = delay+"ms";
		elem["-webkit-transition-duration"] = duration+"ms";
		elem.opacity = 0;
	},
	
	fadeTo: function(obj, alpha, delay, duration){
		var elem = document.getElementById(obj).style;
		elem["-webkit-transition-property"] = "all";
		elem["-webkit-transition-delay"] = delay+"ms";
		elem["-webkit-transition-duration"] = duration+"ms";
		elem.opacity = alpha;
	},
	
	expandBox: function(obj, _width, _height, delay, duration){
		var elem = document.getElementById(obj).style;
		elem["-webkit-transition-property"] = "all";
		elem["-webkit-transition-delay"] = delay+"ms";
		elem["-webkit-transition-duration"] = duration+"ms";
		if(_width>=0)elem.width = _width+"px";
		if(_height>=0)elem.height = _height+"px";
	},
	
	moveBoxTo: function(obj, _x, _y, delay, duration){
		var elem = document.getElementById(obj).style;
		elem["-webkit-transition-property"] = "all";
		elem["-webkit-transition-delay"] = delay+"ms";
		elem["-webkit-transition-duration"] = duration+"ms";
		if(_x!=null)elem.left = _x+"px";
		if(_y!=null)elem.top = _y+"px";
	}
}