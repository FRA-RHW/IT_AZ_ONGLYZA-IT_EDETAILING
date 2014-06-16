
var packageSlide="88CA13D5-6BD3-FC0E-C843-201308033317";
var ref_index = [
   // [],

	[9], //1
    [2], //2    
	[3], //3 
	[12], //7	
	[13], //8
	[13], //8
	[13], //8
	[4,5], //4 
	[6], //5
	[3,4,5,11,7,8], //6
	[5] //7 per slide 4.2
	
]

var eventType;

var boxReference;
var textReference;
var refList;
var $btnReference;
var $container;

function initReference(){
    
		var BoxRef  = "<div id='btnRef' on"+eventType+"='javascript:toggleReferences()'></div><div id='boxReferences'><div id='boxReferencesContents'><div class='topRef'><span>Références:</span></div><div class='centralRef'><div id='TextRef' class='TextRef'><ol id='refList' class='olRef'></ol></div></div><div class='bottomRef'></div></div></div>"; 
		
		$container.append(BoxRef);
		
		$btnReference=$("#btnRef");
		textReference=document.getElementById("TextRef");
   		boxReference=document.getElementById("boxReferences");
   		refList=document.getElementById("refList");
		insertReference(numSlide)
		
}
var refIsOpen=false;
var refIsAnim=false;


function insertReference(_numSlide){
	
	var BoxRef="";
	
	for(var i in ref_index[_numSlide])  BoxRef +=  references["ref" + ref_index[_numSlide][i]].body;
		
	refList.innerHTML=BoxRef;
	
	}



function toggleReferences(){
	
	if(refIsAnim) return;
	refIsAnim=true;
	if(refIsOpen){closeReferences()}else{openReferences()}
	}
	
function openReferences(){
	//console.log(refW)
	if (refW==undefined)  refW=1;
	var refWidth;
	switch(refW){
		case 1: refWidth=-402; textReference.className=""; break;
		case 2: refWidth=-702; textReference.className="two-col"; break;
		case 3: refWidth=-902; textReference.className="three-col"; break;
		}
	$btnReference.addClass("on");  anim.transform(boxReference,{delay:0,duration:1000,transform:"translate3d("+ refWidth +"px,0,0)"},function(){refIsAnim=false; refIsOpen=true;}); }
	
	
function closeReferences(){ anim.transform(boxReference,{delay:0,duration:1000,transform:"translate3d(0,0,0)"},function(){refIsAnim=false; refIsOpen=false; $btnReference.removeClass("on");});}

var references = {
    "ref2": {
        "body": "<li value='2'>DeFronzo RA et al. The efficacy and safety of saxagliptin when added to metformin therapy in patients with inadequately controlled type 2 diabetes with metformin alone. Diabetes Care 2009; 32: 1649-55.</li>"
    },
	"ref3": {
        "body": "<li value='3'>Cook W., et al. Post hoc analysis of 5 pooled phase 3, randomized, double-blind, placebo controlled, 24-week studies including 2 monotherapy studies and 1 add-on therapy study with each of the following, metformin, glyburide or a thiazolidinedione. Postgraduate Medicine 2013.</li>"
    },
	
	"ref4": {
        "body": "<li value='4'>Göke B et al. Saxagliptin is non-inferior to glipizide in patients with type 2 diabetes mellitus inadequately controlled on metformin alone: a 52-week randomised controlled trial. Int J Clin Pract 2010:64:1619-31. Data from a Phase IIIb, 52-week, international, multicenter, randomised, parallel-group, active-controlled, double-blind, noninferiority trial (n=858) to evaluate the efficacy and safety of saxagliptin 5mg added to metformin versus glipizide added to metformin in adult patients with Type 2 diabetes who had inadequate glycaemic control (HbA1c >6.5% and ≤10.0%) on metformin alone. (Glipizide dose could be up-titrated as needed from 5 to 20 mg. Mean final glipizide total daily dose was 14.7 mg⁄day. More than two-thirds of patients in the glipizide plus metformin group underwent two or more dose titrations. Metformin dose 1500-3000 mg HbA1c efficacy based on per protocol analysis (n=586), safety analyses based on patients who received at least one dose of study drug (n=858).</li>"
    }
	,
	"ref5": {
        "body": "<li value='5'>Göke B et al. Saxagliptin vs. glipizide as add-on therapy in patients with type 2 diabetes mellitus inadequately controlled on metformin alone: long-term (52-week) extension of a 52-week randomised controlled trial. Int J Clin Pract 2013. Data from a randomised study of saxagliptin 5 mg versus glipizide titrated from 5 to 20 mg/day. Patients were aged 18 years with HbA1c >6.5% to 10% and had been taking a stable dose of metformin monotherapy 1500 mg/day for at least 8 weeks before enrolment. Patients continued open-label metformin 1500-3000 mg/day (metformin doses were based on dose at study enrolment) for the duration of the study. At the end of the 52-week short-term phase, patients continued in a 52-week extensionreceiving the same double-blind treatment. Objectives of the extension were long-term safety, tolerability and efcacy of saxagliptin versus glipizide added to metformin after 104 weeks of treatment. Other endpoints included change from baseline HbA1c from week 24 to week 104 and change from baseline fasting plasma glucose.</li>"
    },
	
	"ref6": {
        "body": "<li value='6'>Latest version SMPC Onglyza<sup style='color:#FFFFFF;'>®</sup>.</li><div style='color:#FFFFFF;'>* Met inbegrip van saxagliptine als add-on<br>combinatietherapie met metformine en<br>initiële combinatietherapie met metformine<br><br>** Alleen in de initiële combinatietherapie<br><br>*** Er was geen statistisch significant verschil<br>vergeleken met placebo. De incidentie van<br>bevestigde hypoglykemieën was ‘Soms’<br>voor Onglyza 5 mg (0,8%) en placebo (0,7%)<br><br>**** Alle meldingen van perifeer oedeem als<br>bijwerking waren mild tot matig ernstig<br>van aard en geen enkele resulteerde in<br>het stopzetten van de studiemedicatie</div>"
    },
	
	
	"ref7": {
        "body": "<li value='7'>Upreti et al., Bioequivalence of Saxagliptin/Metformin Immediate Release (Ir) Fixed-Dose Combination Tablets and Single Component Saxagliptin and Metformin IR tablets in Healthy Subjects, Clin. Drug. Investig. 2013 ;33 : 365-374.</li>"
    },
	
	"ref8": {
        "body": "<li value='8'>Latest version SMPC Komboglyze<sup style='color:#FFFFFF;'>®</sup>.</li>"
    },
	
	"ref9": {
        "body": "<li value='9'>Perk J. et al., European Guidelines On Cardiovascaular Disease Prevention in Clinical Practice (Version 2012). Eur Heart J Le patient typique 2012; 33 (13) : 1635-1701</li>"
    }
	,
	
	"ref10": {
        "body": "<li value='10'>Data on File. SAXA 038. Bristol-Myers Squibb Company/AstraZeneca.</li>"
    },
	
	"ref11": {
        "body": "<li value='6'>Latest version SMPC Onglyza<sup style='color:#FFFFFF;'>®</sup>.</li>"
    },
	
	"ref12": {
        "body": "<li value='1'>Scirica BM, Bhatt DL, Braunwald E, et al; for the SAVOR-TIMI 53 Steering Committee and Investigators,  <em style='color:#FFFFFF;'>N Engl J Med</em>. 2013; doi: 10.1056/NEJMoa 1307684.</li>"
    }
	,
	
	"ref13": {
        "body": "<li value='1'>Scirica BM, Bhatt DL, Braunwald E, et al; for the SAVOR-TIMI 53 Steering Committee and Investigators, <em style='color:#FFFFFF;'>N Engl J Med</em>. 2013; doi: 10.1056/NEJMoa 1307684."
    }
	
	
	
	

	
	
};


function initPackageBtn(){
	
	$container.append("<div id='S_Top' on"+eventType+"='javascript:goToPackage()'></div>");
	
	}
	
function initLogo(){
	
	$container.append("<div id='logoBottom'></div>");
	
	}
	
function goToPackage(){
	

	 goToSlide(packageSlide);
	
	
	}	

window.onload = function (){
	
	if(!RunningUnderExploria()) {eventType="click"} else {eventType="touchstart"}
	
	$container=$("#screen-container");
		BlockElasticScroll();
	
		StartPage();
		nav.configure();
		nav.swiping();
	
}

function BlockElasticScroll(){
	var body = document.getElementsByTagName("body")[0];
	body.ontouchmove = this.BlockElasticScrollHandler;
	body.onmousemove = this.BlockElasticScrollHandler;
}

function BlockElasticScrollHandler(e){
	e.preventDefault();
	return false;
}

function RunningUnderExploria(){
	var underExploria = navigator.userAgent.indexOf("iPad") != -1 ;
	return underExploria;
}

function StartPage(){
	SetWebkitParameters();

	
}

function SetWebkitParameters(){
	document.documentElement.style.webkitTouchCallout = "none";
	document.documentElement.style.webkitTapHighlightColor = "rgba(0,0,0,0)";
}



var anim={
	
	defaultValues:{delay:"0",duration:"500"},
	
	fadeIn: function(_options){
		
		_options.properties={opacity:1}
		anim.transform(_options);
		
		},
		
	fadeOut: function(_options){
		
		_options.properties={opacity:0}
		anim.transform(_options);
		
		},
	
	fadeInClass: function(_options){
		
		var myelems=document.getElementsByClassName(_options.cssClass);
		
		for (var i=0; i<myelems.length; i++){		
			anim.fadeIn({element:myelems[i],delay:(_options.delay*i),duration:_options.duration})	
			}
		
		},	
		
		
	fadeOutClass: function(_options){
		
		var myelems=document.getElementsByClassName(_options.cssClass);
		
		for (var i=0; i<myelems.length; i++){		
			anim.fadeOut({element:myelems[i],delay:(_options.delay*i),duration:_options.duration})	
			}
		
		},	
		
	scale: function(_options){
		
		_options.transform="scale3d("+_options.factor+","+_options.factor+","+_options.factor+")";
		anim.transform(_options);
		},	
		
	expandX: function(_options){
		
		_options.properties={width:_options.x+"px"};
		anim.transform(_options);
		},	
		
	translateX: function(_options){
		
		_options.transform="translate3d("+_options.x+"px,0,0)";
		anim.transform(_options);
		},	
		
	translateY: function(_options){
		
		_options.transform="translate3d(0,"+_options.y+"px,0)";
		anim.transform(_options);
		},	
		
		
	transform: function(_options){
		try{
			
			//console.log(_options.element.id)
			
		if ((_options.element==undefined ) ) return;
		
		if (_options.delay==undefined) _options.delay=anim.defaultValues.delay;
		if (_options.duration==undefined) _options.duration=anim.defaultValues.duration;
		
		var element=_options.element;
		
		if(typeof(_options.element)=="string") element=anim.$(_options.element);
		
		
		if(_options.delay!=undefined){element.style["-webkit-transition-delay"]=_options.delay+"ms"}else{element.style["-webkit-transition-delay"]=anim.defaultValues.delay+"ms"}
		if(_options.duration!=undefined){element.style["-webkit-transition-duration"]=_options.duration+"ms"}else{element.style["-webkit-transition-duration"]=anim.defaultValues.duration+"ms"}
		
		
		element.style["-webkit-transition-property"]="all";
	
		if(_options.transform!=undefined ) { element.style["-webkit-transform"]=_options.transform; }
		
		if(_options.properties!=undefined){
			
				var prop;
				for (prop in _options.properties) element.style[prop]=_options.properties[prop];
				
			}
		
		
		if(typeof(_options.callback)=='function'){
			
		var transEnd = function(event) 
		{
			element.removeEventListener("webkitTransitionEnd",transEnd);
			_options.callback(element);
				
		};
	
			element.addEventListener( 'webkitTransitionEnd', transEnd, false );
			
			
			}
			
		}catch(err){console.log(err)}
		
		},

$:function(e)
	{
		if(typeof(e) == 'string')
		{
			
			var arr=document.getElementsByClassName(e)
			if(arr.length>0){return arr}else {return document.getElementById(e);}
				
		}
		return e;
	}
	
	}


function rotate(el){
	var myel=document.getElementById(el);
	myel.style.webkitTransitionDuration='500ms';
	myel.style.webkitTransform="rotateY(180deg)";
	//animGraph2();
}
		
				
function rotateBack(el){
	var myel=document.getElementById(el);
	myel.style.webkitTransitionDuration='500ms';
	myel.style.webkitTransform="rotateY(0deg)";
	//resetAnim();
}	 

var rotate_fun1 = {
	content: null,
	
	page1: null,
	page2: null,
	init1: function(){
		this.page1 = document.getElementById('anim1');
		this.page2 = document.getElementById('anim1b');
		this.content = document.getElementById('box_rot_1');
		this.page2.style['-webkit-transform'] = "rotateY(180deg)";
	},
	
	startRotate1: function(){
		console.log("start!");
		var interval = setInterval(function(){$('#anim1').css('z-index','30');clearInterval(interval)}, 100);
		this.content.style['-webkit-transform'] = "rotateY(180deg)";
	},
	
	endRotate1: function(){
		console.log("end");

		this.content.style['-webkit-transform'] = "rotateY(0deg)";
	}
}

var rotate_fun2 = {
	content: null,
	
	page1: null,
	page2: null,
	init2: function(){
		this.page1 = document.getElementById('anim2');
		this.page2 = document.getElementById('anim2b');
		this.content = document.getElementById('box_rot_2');
		this.page2.style['-webkit-transform'] = "rotateY(180deg)";
	},
	
	startRotate2: function(){
		console.log("start!");
		var interval = setInterval(function(){$('#anim2').css('z-index','30');clearInterval(interval)}, 100);
		this.content.style['-webkit-transform'] = "rotateY(180deg)";
	},
	
	endRotate2: function(){
		console.log("end");

		this.content.style['-webkit-transform'] = "rotateY(0deg)";
	}
}

var rotate_fun3 = {
	content: null,
	
	page1: null,
	page2: null,
	init3: function(){
		this.page1 = document.getElementById('anim3');
		this.page2 = document.getElementById('anim3b');
		this.content = document.getElementById('box_rot_3');
		this.page2.style['-webkit-transform'] = "rotateY(180deg)";
	},
	
	startRotate3: function(){
		console.log("start!");
		var interval = setInterval(function(){$('#anim3').css('z-index','30');clearInterval(interval)}, 100);
		this.content.style['-webkit-transform'] = "rotateY(180deg)";
	},
	
	endRotate3: function(){
		console.log("end");

		this.content.style['-webkit-transform'] = "rotateY(0deg)";
	}
}
