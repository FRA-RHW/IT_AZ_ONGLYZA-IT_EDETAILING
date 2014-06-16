/*
   ESPButton.js 
   Author: SKW
   Version: 1.0
   Modified: 11/09/2010
   Copyright: ExploriaSPS, LLC.
	
   This javascript file holds the definition for the ESP Button class.
   This class is used to make button tracking calls from the content to the host ESP application.
*/

/* 
   ESP Button class.
*/
function ESPButton(trackId, description)
{
	/* Private trackID variable */
	var m_trackID = "BUTTON";

	/* Private description variable */
	var m_description = "";

	/* Private submitted variable that will be set to true after the button is submitted */
	var m_submitted = false;

	// Set the data members based on the passed arguments
	this.SetTrackID( trackId );
	this.SetDescription( description );
}

/*
   Sets the trackId.
*/
ESPButton.prototype.SetTrackID = function(trackId)
{
	if ( trackId )
		this.m_trackID = trackId;
}

/*
   Sets the description.
*/
ESPButton.prototype.SetDescription = function(description)
{
	if ( description )
		this.m_description = description;
}

/*
   Returns true if the button has been submitted.
*/
ESPButton.prototype.IsSubmitted = function()
{
	return this.m_submitted;
}

/*
   Submits tracking that this button was clicked.
	
	returns:	True if submitted successfully, false not submitted.	
*/
ESPButton.prototype.Submit = function()
{		
	var callID = CCAPI.CallESPFunction(CCAPI.TRK_set, "myCallback", this.m_trackID);
	
	trace("Button with trackID: "+this.m_trackID+" has been submitted");
	
	this.m_submitted = true;
	
	// Return the callID so caller can identify it in myCallback
	return callID;
}

/*
   Button Click function: Pass in the name of the button you want to track
*/
function Button_Click(e)
{
	//trace("Button_Click");
	var res = e.Submit();
	trace( "Submit res=" + res);
	
	//Place above code in if statment below if you want to only submit once	
/*	if ( !e.IsSubmitted() )
	{	
	//	console.log("!"+ e+".IsSubmitted()");
	}*/
}


// Create an instance of the ESPButton class so it will be initialized
espbutton = new ESPButton();
