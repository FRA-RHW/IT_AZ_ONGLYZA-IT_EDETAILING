// JavaScript Document

//Nav Object
var nav = {
    config: {
        //local: !RunningUnderExploria(),
		local: true,
		swiping: "ALL",	// valori possibili ALL e SECTION
		swipe_left: true,
		swipe_right:true,
        pdfLocation: '',
		currentSlide: null,
		touch: "touchend"
    },
	
	ObjSlide: function(){
		this.id,
		this.name = "",
		this.sas = "",
		this.type = "",
		this.path = "",
		this.visible = "",
		this.filename,
		this.next,
		this.prev
	},
	
	findSlide: function(nameSlide){
		for(var i = 0;i < nav.allSlide.length;i++){
			if(nav.allSlide[i].name == nameSlide)
				return nav.allSlide[i];
		}
		
		console.log("** ERROR ** Slide not found");
		return null;
	},
	
    slides: {},
	
	swipeSlide:null,
	allSlide:null,
	
	getCurrentSlide: function(callbackID,arg) {
		return arg;
	},
	
	getPresentationConfig: function(callbackID,arg){
		if(arg != undefined)
			return arg;
			else
			return false;
	},
	
	configure: function(){
		
		var thisSlide = numSlide;
		var dataConfig;
		
		var cont = 0;
		nav.swipeSlide = new Array();
		nav.allSlide = new Array();
		
		//controllo qual è il dispositivo e setto la slide corrente
		var ua = navigator.userAgent;
		if(/iPad/i.test(ua)){
			nav.config.touch = "touchend";
		}
		
		var contNum = 0;
		var next = null;
		var prev = null;
		var slidePrev, slideNext;
		for(var i in configSlide){
			var tmpSlide1;
			contNum++;
			
			tmpSlide1 = new nav.ObjSlide();
			tmpSlide1.id = configSlide[i].id;
			tmpSlide1.name = configSlide[i].name;
			tmpSlide1.sas = configSlide[i].sas;
			tmpSlide1.type = configSlide[i].type;
			tmpSlide1.path = configSlide[i].path;
			tmpSlide1.visible = configSlide[i].visible;
			tmpSlide1.filename = configSlide[i].filename;
			tmpSlide1.prev = null;
			tmpSlide1.next = null;
			nav.allSlide.push(tmpSlide1);
		}
		

		switch(nav.config.swiping){
			
			case 'SECTION':	nav.configure_swipe_section();
							break;	
				
				
				
			// nal caso in cui lo swiping e da sezione a sezione	
			case 'ALL': 	nav.configure_swipe_all();
							break;
			default: break;
			
		}
		
		nav.currentSlide = nav.allSlide[thisSlide];
	
		//find track_name
		var slide = nav.currentSlide;
		
		var nameSlide = nav.currentSlide.name;
		console.log("SLIDE: " + nameSlide + "\nSAS: " + slide.sas + " Path: " + slide.path);
		
		
		// CREO IL TRACKING 
		feedback = new ESPFeedback(nameSlide + "_feedback", nameSlide + " Feedback", nameSlide);
		
		var feedStrips = "<div class=\"feedStrips\">";
			feedStrips += "<div id=\"positive\" class=\"btnFeed\" ontouchend=\"Feedback_Click(feedback, ESPFeedback.ACCEPT);\"></div>";
			feedStrips += "<div id=\"neutral\" class=\"btnFeed\" ontouchend=\"Feedback_Click(feedback, ESPFeedback.REJECT);\"></div>";
			feedStrips += "<div id=\"negative\" class=\"btnFeed\" ontouchend=\"Feedback_Click(feedback, ESPFeedback.NEUTRAL);\"></div>";
			feedStrips += "</div>";
			
		$('#container').append(feedStrips);	
		
		
	},
	
	configure_swipe_all:function(){

		var cont = 0;
		var next = null;
		var prev = null;
		var slidePrev, slideNext;
		var contNum = 0;
		
		var swipeSlide = new Array();
		
		for(var c in menu_swiping){
			var tmpSlide1;
			contNum++;
			
			tmpSlide1 = nav.allSlide[menu_swiping[c].id];
			
			cont++;
			
			if(prev != null)	
				prev.next = tmpSlide1;
				
			tmpSlide1.prev = prev;
			tmpSlide1.next = null;
			prev = tmpSlide1;
			
			
			//controllo se esiste un submenu
			if(menu_swiping[c].menu == undefined){}
				else{
				for(var l in menu_swiping[c].menu){
					
					var tmpS = nav.allSlide[menu_swiping[c].menu[l].id];
					if(prev != null)
						prev.next = tmpS;
								
					tmpS.prev = prev;
					tmpS.next = null;
					prev = tmpS;
					cont++;
					
				}	
			}	
			
		}
	
	},
	
	
	configure_swipe_section:function(){
		
		var cont = 0;
		var next = null;
		var prev = null;
		var slidePrev, slideNext;
		var contNum = 0;
		for(var c in menu_swiping){
			var tmpSlide1;
			contNum++;
			
			tmpSlide1 = nav.allSlide[menu_swiping[c].id];
			cont++;
			
			//if(prev != null)	
				//prev.next = tmpSlide1;
				
			tmpSlide1.prev = null;
			tmpSlide1.next = null;
			
			prev = tmpSlide1;
			
			
			//controllo se esiste un submenu
			if(menu_swiping[c].menu == undefined){}
				else{
				for(var l in menu_swiping[c].menu){
					
					var tmpS = nav.allSlide[menu_swiping[c].menu[l].id];
					if(prev != null)
						prev.next = tmpS;
								
					tmpS.prev = prev;
					tmpS.next = null;
					prev = tmpS;
					cont++;
				}	
			}	
			
		}
		
	},
  
  
  
  	disableSwiping: function(str){
		
		switch(str){
			case 'left': nav.config.swipe_left = false;break;
			case 'right': nav.config.swipe_right = false;break;
			case 'left right': nav.config.swipe_left=false;nav.config.swipe_right = false;break;
			default: break;	
			
		}
	},
	
	enableSwiping: function(str){
		switch(str){
			case 'left': nav.config.swipe_left = true;break;
			case 'right': nav.config.swipe_right = true;break;
			case 'left right': nav.config.swipe_left=true;nav.config.swipe_right = true;break;
			default: break;	
			
		}
	},
  
    navSlide: function (slide) {

        goToSlide(slide.sas);
	
		if (nav.config.local) {
			document.location = "../" + slide.path + "/" + slide.filename + '.' + slide.type;
			return;
        }
    },
	
	jumpSlide:function(nameSlide){
		var tmpObjSlide = nav.findSlide(nameSlide);
		nav.navSlide(tmpObjSlide);
	},
	
	goSlide:function(numS){	
		
		goToSlide(nav.allSlide[numS].sas);
		
		if (nav.config.local) {
		  	document.location = "../" + nav.allSlide[numS].path + "/" + nav.allSlide[numS].filename + '.' + nav.allSlide[numS].type;
			return;
        }
		
	},
	
	goToBack: function(){
	
		if(nav.currentSlide.prev == null) return;
		if(nav.currentSlide.prev.type == "pdf") return;

		nav.navSlide(nav.currentSlide.prev);
	},
	
	goToNext: function(){
	
		if(nav.currentSlide.next == null) return;
		if(nav.currentSlide.next.type == "pdf") return;
		
		nav.navSlide(nav.currentSlide.next);

	},

	swiping: function(){
			
			$("body").bind('mousedown touchstart MozTouchDown', touchStart);
			$("body").bind('mouseup touchend MozTouchUp', touchEnd);
			$("body").bind('mousemove touchmove MozTouchMove', touchMove);
			
			var threshold =  300;
			var overrideClass = '.override';
			var preventDefaultEvents = true;
			var myClick = false;
			
			// Private variables for each element
			var originalCoord = [];
			var finalCoord = [];
			var numTouches;
			
			// Screen touched, store the original coordinate
			function touchStart(event){
				
				myClick = true;
				
				var event = event.originalEvent;
				if ($(event.target).parents(overrideClass).length > 0 || $(event.target).hasClass(overrideClass) ) return;				
				originalCoord = [];
				finalCoord = [];
				if(event.type == "touchstart"){
					numTouches = event.touches.length;
				
					for (var i = 0; i < numTouches; i++){
						originalCoord[i] = { x:0, y:0 };
						finalCoord[i] = { x:0, y:0 };
						originalCoord[i].x = event.touches[i].pageX;
						originalCoord[i].y = event.touches[i].pageY;
						finalCoord[i].x = event.touches[i].pageX;
						finalCoord[i].y = event.touches[i].pageY;
					}
				}else if(event.type == "mousedown"){
						numTouches = 1;
						originalCoord[0] = { x:0, y:0 };
						finalCoord[0] = { x:0, y:0 };
						originalCoord[0].x = event.pageX;
						originalCoord[0].y = event.pageY;
						finalCoord[0].x = event.pageX;
						finalCoord[0].y = event.pageY;
				}
			}
			
			// Store coordinates as finger is swiping
			function touchMove(event){
				if(!myClick) return;
				
				var event = event.originalEvent;
				
				//alert('touch move');
				if (preventDefaultEvents)
				{
				    event.preventDefault();
				    //event.stopPropagation();
				}


				if(event.type == "touchmove"){
					// Updated X,Y coordinates
					for (var i = 0; i < numTouches; i++)
					{
						finalCoord[i].x = event.touches[i].pageX;
						finalCoord[i].y = event.touches[i].pageY;
					}
				}else if(event.type == "mousemove"){
						finalCoord[0].x = event.pageX;
						finalCoord[0].y = event.pageY;
				}	
			}
			
			function touchEnd(event){
				
				myClick = false;
				
				var event = event.originalEvent;
				if ($(event.target).parents(overrideClass).length > 0) return;
				var origX = 0;
				var origY = 0;
				var finalX = 0;
				var finalY = 0;
				if(event.type == "touchend"){	
					for (var i = 0; i < numTouches; i++){
							origX += originalCoord[i].x;
							finalX += finalCoord[i].x;
							origY += originalCoord[i].y;
							finalY += finalCoord[i].y;
						}
				}else if(event.type == "mouseup"){
					origX = originalCoord[0].x;
					finalX = finalCoord[0].x;
					origY = originalCoord[0].y;
					finalY = finalCoord[0].y;
				}
				
				
				origX /= numTouches;
				origY /= numTouches;
				finalX /= numTouches;
				finalY /= numTouches;
				
				var width = Math.abs(origX - finalX);
				var height = Math.abs(origY - finalY);
				var distance = Math.sqrt((width * width) + (height * height));
				
				if (width > threshold){

						// horizontal
						if (origX > finalX){
							if(nav.config.swipe_right)
								nav.goToNext();
						}else{
							if(nav.config.swipe_left)
								nav.goToBack();
					}
				}
			}	
	},

	swiping2: function(){
		var firstPage = 0;
		var lastPage = 2;
	
		
		// configuro lo swiping
		scroller = new iScroll('container', { bounce:false, snap:true, momentum:false, hScrollbar:false,vScrollbar:false,checkDOMChanges:false, 
					onScrollEnd: function(){
						var pos = Math.abs($('#scroller').position().left);
						currentPage = pos / 1024;	
						if(currentPage == firstPage){
							
							$('#prevPage').animate({opacity:0}, 100, function(){nav.goToBack();});
							
						
						}else if(currentPage == lastPage){
							$('#nextPage').animate({opacity:0},100,function(){nav.goToNext();});
						}
						
					}
				});
		
		
		var width = 3072;
		if(nav.currentSlide.prev == null){
			$('#prevPage').remove();
			lastPage = 1;
			width -= 1024;
			$('#scroller').css({'width': width + 'px'});
		}else{
				var pathPrev = nav.currentSlide.prev.path;
				$('#prevPage').css({'background': "url('../" + pathPrev + "/thumbs/placeholder.png')"});
				scroller.scrollToPage(1, 0, 0);
			}
			
			
		if(nav.currentSlide.next == null){
			$('#nextPage').remove();
			width -= 1024;
			$('#scroller').css({'width':width + 'px'});
			firstPage = 0;
			scroller.refresh();
		}else{
				var pathNext = nav.currentSlide.next.path;
				$('#nextPage').css({'background': "url('../" + pathNext + "/thumbs/placeholder.png')"});
		}
	},
	
	config_navigator: function(){
		
		var myNavigator = "<div id=\"navigator\">";

			myNavigator += "<div id=\"pageIndicator\">";
			
			for(var i =0;i < nav.swipeSlide.length;i++){
				var tmpSlide = 	nav.swipeSlide[i];
				var classIndicator;
				if(tmpSlide == nav.currentSlide)
					classIndicator = "class=\"pageIndicatorOn\"";
					else
					classIndicator = "class=\"pageIndicatorOff\" id=\"briciola" + i + "\" ontouchend=\"goToSlide('" + tmpSlide.sas + "');\"";
					
				
				myNavigator += "<img "  + classIndicator + " width=\"25\" height=\"22\" src=\"../../global/images/empty.png\" border=\"0\"/>";	
				
			}
			
			
    	myNavigator += "</div>";
		
		
		if(nav.currentSlide.visible != "NO"){
			$('#container').append(myNavigator);
			$('#navigator').css({top: 627});
		}
		
		
		var booNav = false

		$('#btnRef').css({top: 612});
		
		$("body").bind('touchend', function(event){
			if(event.type == "touchend") 
				scroller.enable();
		});	
	}
	
} //End Nav Object