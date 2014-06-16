// JavaScript Document

 var video = document.getElementById("videoid");
$(document).ready(function(){

   
   

    $('#btn-video').bind("click",function(){
        $('#zoom').fadeIn(function(){
            video.play();
        });

    });

    $('#btnCloseZoom').bind("click",function(){
        $('#zoom').fadeOut(function(){
            video.currentTime=0;
            video.pause();
        });
    });


    $('#btn-play').bind("click",function(){
       video.play();
    });
	
    $('#btn-pause').bind("click",function(){
        video.pause();
    });

    $('#btn-stop').bind("click",function(){
        video.currentTime=0;
        video.pause();
    });

  
    var delaytime=300;

});