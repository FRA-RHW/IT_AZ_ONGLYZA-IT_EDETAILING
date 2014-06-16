/*
   CCAPI.js 
   Author: SKW
   Version: 1.0
   Modified: 09/30/2010
   Copyright: ExploriaSPS, LLC.
	
   This javascript file holds the definition for all ESP system communication and utility functions.
*/


/*
   Method that handles a call from ESP with the passed content
   communication xml request string and returns any appropriate
   content communication xml response.
*/
var HandleESPCCAPICall = function(requestXml)
{
	//alert("HandleESPCCAPICall requestXml=" + requestXml);
	// Parse parameters
	var callData = CCAPI.ParseCallParameters( requestXml );

	// Handle the call
	switch (callData.functionName)
	{
	case CCAPI.SYS_pollCall:
		// System is polling content for any waiting calls
		var espCall = CCAPI.CallToESPQueue.shift();
		if ( espCall )
		{
			//alert("pollCall" + espCall.XmlRequest);
			// There is a call to ESP waiting to be processed
			return espCall.XmlRequest;
		}
		break;
	case CCAPI.SYS_returnCall:

		//alert("callData=" + callData);
	
		// System is returning a result to a waiting call
		var callback = callData.arguments[0].ToValue();
		var result = callData.arguments[1].ToValue();
		
		// Split out the callback data into the callID and the method to call
		var arr = callback.split(":", 2);
		var callID = arr[0];
		callback = arr[1];	
		
		if ( callback )
		{
			// Build the proper string to call the callback method
			// passing the callID and the result
			var cb = callback + "(" + callID + ", ";
			if ( typeof result == 'string' )
				cb = cb + JSONEnquote( result );
			else
				cb = cb + result;
			cb = cb + ")";
			// Call the callback method passing the callID and the result
			eval( cb );	
		}
		break;
	case CCAPI.EVT_slideLoad:
		if ( typeof EVT_slideLoad == 'function' )
		{
			var mode = callData.arguments[0].ToValue();
			var data = callData.arguments[1].ToValue();
			EVT_slideLoad( mode, data );
		}
		break;
	case CCAPI.EVT_slideStart:
		if ( typeof EVT_slideStart == 'function' )
		{
			EVT_slideStart();
		}
		break;
	case CCAPI.EVT_slideEnd:
		// Default to OK to end now with no delay
		var delay = -1;
		if ( typeof EVT_slideEnd == 'function' )
		{
			delay = EVT_slideEnd();
		}

		// Create a return CCAPI argument
		var argReturn = new CCAPIArgument( delay );

		// Convert the return argument to an xml string
		var responseXml = argReturn.ToStringForCallCCFunction();

		return responseXml;
		break;
	}
};

/*
   Content Communication API class that handles communication between
   host ESP application and the html/javascript content.
*/
function CCAPI()
{
	/* Content Communication API Events sent from ESP to the content */
	CCAPI.EVT_querySAS 			= "EVT_querySAS";
	CCAPI.EVT_queryPrintDescription 	= "EVT_queryPrintDescription";
	CCAPI.EVT_print 			= "EVT_print";
	CCAPI.EVT_slideLoad 			= "EVT_slideLoad";
	CCAPI.EVT_slideUpdate 			= "EVT_slideUpdate";
	CCAPI.EVT_slideStart 			= "EVT_slideStart";
	CCAPI.EVT_slideEnd 			= "EVT_slideEnd";
	
	/* Content Communication API ESP System Events sent from ESP to the content */
	CCAPI.SYS_pollCall			= "SYS_pollCall";
	CCAPI.SYS_returnCall			= "SYS_returnCall";

	/* Content Communication API Messages sent from the content to ESP */
	CCAPI.NAV_restartPresentation 		= "NAV_restartPresentation";
	CCAPI.NAV_endPresentation 		= "NAV_endPresentation";
	CCAPI.NAV_resetPresentation 		= "NAV_resetPresentation";
	CCAPI.NAV_getSlideProperty 		= "NAV_getSlideProperty";
	CCAPI.NAV_setSlideProperty 		= "NAV_setSlideProperty";
	CCAPI.NAV_resetSlideOrder 		= "NAV_resetSlideOrder";
	CCAPI.NAV_goToSlide 			= "NAV_goToSlide";
	CCAPI.NAV_goToSlideTest 		= "NAV_goToSlideTest";
	CCAPI.NAV_goToHiddenSlide 		= "NAV_goToHiddenSlide";
	CCAPI.NAV_goToHiddenSlideTest 		= "NAV_goToHiddenSlideTest";
	CCAPI.NAV_goNext 			= "NAV_goNext";
	CCAPI.NAV_goNextTest 			= "NAV_goNextTest";
	CCAPI.NAV_goBack 			= "NAV_goBack";
	CCAPI.NAV_goBackTest 			= "NAV_goBackTest";
	CCAPI.NAV_goToGroup 			= "NAV_goToGroup";
	CCAPI.NAV_goToGroupTest 		= "NAV_goToGroupTest";
	CCAPI.NAV_pushHistory 			= "NAV_pushHistory";
	CCAPI.NAV_popHistory 			= "NAV_popHistory";
	CCAPI.NAV_nextHistory 			= "NAV_nextHistory";
	CCAPI.NAV_backHistory 			= "NAV_backHistory";
	CCAPI.NAV_clearHistory 			= "NAV_clearHistory";
	CCAPI.NAV_currentHistory 		= "NAV_currentHistory";
	CCAPI.NAV_arriveMethod 			= "NAV_arriveMethod";
	CCAPI.NAV_enableToolbarHotArea 		= "NAV_enableToolbarHotArea";
	CCAPI.NAV_showToolbar 			= "NAV_showToolbar";
	CCAPI.DB_get 				= "DB_get";
	CCAPI.DB_set 				= "DB_set";
	CCAPI.TRK_get 				= "TRK_get";
	CCAPI.TRK_set 				= "TRK_set";
	CCAPI.INFO_get 				= "INFO_get";
	
	// The modes within which a slide can be loaded
	CCAPI.PREVIEW				= 1;
	CCAPI.DETAIL				= 2;
	CCAPI.NOASSOC				= 3;
	
	// The environment types within which a slide can be loaded
	CCAPI.LOCAL				= 1;
	CCAPI.WEB				= 2;
	
	// The user types for which a slide can be loaded
	CCAPI.DOCTOR				= 1;
	CCAPI.REP				= 2;
	CCAPI.THIRDPARTY			= 3;
	
	// The detail types within which a slide can be loaded
	CCAPI.EDETAIL				= 1;
	CCAPI.REMOTEDETAIL			= 2;
	CCAPI.INPERSON				= 3;
	
	// The slide properties
	CCAPI.TYPE				= 1;
	CCAPI.BRANDED				= 2;
	CCAPI.BACKGROUNDCOLOR			= 3;
	CCAPI.TEXTCOLOR				= 4;
	CCAPI.TEXT				= 5;
	CCAPI.ENABLED				= 6;
	CCAPI.GROUPINDEX			= 7;
	CCAPI.GROUPRESET			= 8;
	CCAPI.PRINTABLE				= 9;
	
	// The scope qualifiers
	CCAPI.SCOPETHIS				= 1;
	CCAPI.SCOPEALL				= 2;
	
	// The info properties
	//CCAPI.DOCTOR				= 1; // THIS IS ALREADY DEFINED UNDER USER TYPES
	//CCAPI.REP				= 2; // THIS IS ALREADY DEFINED UNDER USER TYPES
	CCAPI.NUMSLIDES				= 3;
	CCAPI.CURRENTSLIDEINDEX			= 4;
	CCAPI.TOOLBARHOTAREA			= 5;
	CCAPI.TOOLBARRECT			= 6;
	CCAPI.RIGHTHANDED			= 7;
	CCAPI.HIGHLIGHTTIME			= 8;
	CCAPI.LOCALBOOKMARKS			= 9;
	CCAPI.POLICIES				= 10;
	CCAPI.ZOOMRANGE				= 11;
	CCAPI.DEFAULTCURSOR			= 12;
	
	// The cursors
	CCAPI.HANDCURSOR			= 1;
	CCAPI.ZOOMCURSOR			= 2;

	/* Enumeration of Content Communication API Argument Types */
	CCAPI.ArgumentType = {Undefined:0, String:1, Number:2, Array:3, BooleanTrue:4, BooleanFalse:5, Object:6};

	/* Counter that holds the next ESP Call ID - it just counts up from 1 */
	CCAPI.NextESPCallID = 1;
	
	/* Queue of waiting calls to host ESP application */
	CCAPI.CallToESPQueue = new Array();

}

/*
   Static method that takes a content communication xml request string and
   returns a call data object.
	requestXml:	Xml string.
	
	returns:	CallData object { functionName:"", arguments:{CCAPIArgument, ..} }.	
*/
CCAPI.ParseCallParameters = function(requestXml)
{
	var callData = new Object();

	// Load the XML
	var xmlDoc;
	if (window.DOMParser)
	{
		parser=new DOMParser();
		xmlDoc=parser.parseFromString(requestXml,"text/xml");
	}
	else // Internet Explorer
	{
		xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		xmlDoc.async="false";
		xmlDoc.loadXML(requestXml);
	}

	// Get the function name
	var invokeNode = xmlDoc;
		
	if (invokeNode.nodeType == 9) // Document node
	{
		// Get the first child
		invokeNode = invokeNode.firstChild;
	}
	callData.functionName = invokeNode.attributes.getNamedItem("name").value;
	
	// Get the arguments
	//var argsNode = invokeNode.selectSingleNode("arguments");
	var argsNode = invokeNode.firstChild;

	if ( argsNode )
	{
		var args = new Array();

		for ( var i=0; i<argsNode.childNodes.length; i++ )
		{
			args[i] = new CCAPIArgument( argsNode.childNodes[i] );
		}

		callData.arguments = args;
	}

	return callData;
}

/*
   Static method that takes a content communication xml return string and
   returns a CCAPIArgument.
	requestXml:	Xml string.
	
	returns:	CCAPIArgument.
*/
CCAPI.ParseCallReturnValue = function(returnedXml)
{
	// Load the XML
	if (window.DOMParser)
	{
		parser=new DOMParser();
		xmlDoc=parser.parseFromString(returnedXml,"text/xml");
		xmlDoc.setProperty("SelectionLanguage","XPath");
	}
	else // Internet Explorer
	{
		xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		xmlDoc.async="false";
		xmlDoc.loadXML(returnedXml);
	}

	// Get the argument
	var arg = new CCAPIArgument( xmlDoc );

	return arg;
}

/*
   Static method that calls an ESP function with the passed arguments
   and returns a unique ESPCallID.
   
	functionName:	String name of the function called.
	callback:	String that will be eval(callback) passing the ESPCallID and return value.
	args:		Any additional arguments should come here.
	
	returns:	ESPCallID which is a unique identifier for the call.
*/
CCAPI.CallESPFunction = function(functionName, callback, args)
{
	// Object to hold the waiting call to be made to the host ESP application
	var espCall = new Object();

	// Generate a new call ID for this call
	CCAPI.NextESPCallID = CCAPI.NextESPCallID + 1;
	var callID = CCAPI.NextESPCallID;

	// Make up the xml for calling an ESP content communication function
	var xml = "<invoke name=\"" + functionName + "\"";	
	xml = xml + " callback=\"" + callID + ":" + callback + "\"";
	xml = xml + " returntype=\"xml\">";
	
	// Build the xml for the arguments to pass through ESP content communication function
	if ( args )
	{
		xml = xml + "<arguments>";
		for ( var i=2; i<arguments.length; i++ )
		{
			// This should just be an argument to be passed to the
			// host ESP application.
			var ccArg = new CCAPIArgument( arguments[i] );
			xml = xml + ccArg.ToStringForCallCCFunction();
		}
		xml = xml + "</arguments>";
	}	
	xml = xml + "</invoke>";
	
	// Save the actual xml call string to be passed to the host ESP application
	espCall.XmlRequest = xml;
	
	// Push the call into the queue so ESP can call in to process it
	CCAPI.CallToESPQueue.push( espCall );
	
	// Return the ID for this call
	return callID;
}

/*
   Method to navigate to a specified slide.
   
	slideId:	String slide identifier (GUID) of slide to link to.
*/
function goToSlide( slideId )
{
	var callID = CCAPI.CallESPFunction(CCAPI.NAV_goToSlide, "myCallback", slideId);
    	trace( "goToSlide callID=" + callID );
    	trace( "goToSlide SlideID=" + slideId );
		//alert(slideId);
}

/*
   Default trace method for debugging in browser.
   
	s:	String to output to trace.
*/
function trace(s) {
  try { console.log(s) } catch (e) { 
  //alert(s); 
  }
};

// Create an instance of the Content Communication API class so it will be initialized
ccapi = new CCAPI();