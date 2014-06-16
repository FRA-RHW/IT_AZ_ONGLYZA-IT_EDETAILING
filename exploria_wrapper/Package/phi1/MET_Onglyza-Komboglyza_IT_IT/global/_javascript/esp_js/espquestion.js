/*
   ESPQuestion.js 
   Author: MJR
   Version: 1.0
   Modified: 02/21/2011
   Copyright: ExploriaSPS, LLC.
	
   This javascript file holds the definition for the ESPQuestion class.
   This class is used to make survey tracking calls from the content to the host ESP application.
*/

/* 
   ESP Question class.
*/
function ESPQuestion(trackId, description, message)
{
	/* Private submitted variable that will be set to true after the survey is submitted */
	var m_submitted = false;

	// Set the data members based on the passed arguments
	this.SetTrackID( trackId );
}

/*
   Sets the trackId.
*/
ESPQuestion.prototype.SetTrackID = function(trackId)
{
	if ( trackId )
		this.m_trackID = trackId;
}

/*
   Sets the description.
*/
ESPQuestion.prototype.SetDescription = function(description)
{
	if ( description )
		this.m_description = description;
}

/*
   Sets the message.
*/
ESPQuestion.prototype.SetMessage = function(message)
{
	if ( message )
		this.m_message = message;
}


/*
   Returns true if the survey has been submitted.
*/
ESPQuestion.prototype.IsSubmitted = function()
{
	return this.m_submitted;
}


/*
   Submits an answer or array of answers for the survey.
	answer:		Answer as integer, array of integers, or string depending on survey type
	
	returns:	CallID of CCAPI request, used to identify response in myCallback	
*/
ESPQuestion.prototype.Submit = function(answers)
{
	// Get the track xml to submit
	var xml = this.GetTrackXml( answers );
	
	trace(xml);
	
	var callID = CCAPI.CallESPFunction(CCAPI.TRK_set, "myCallback", this.m_trackID, xml);
	
	this.m_submitted = true;
	
	// Return the callID so caller can identify it in myCallback
	return callID;
}


/*
   Returns the xml string to submit to the host ESP application for the track data.
	answers:	single integer, array of integers, or string depending on survey type
	
	returns:	Xml string of track data for the passed answer index.	
*/
ESPQuestion.prototype.GetTrackXml = function(answers)
{
	// Create the XML by hand for now
	var xml = "<Track><Answers>";


	if (typeof answers == "object")		/* array of integers */
	{
		for (idx = 0; idx < answers.length; idx++)
			xml = xml + "<Answer>" + answers[idx] + "</Answer>";
	}
	else
	{
		xml = xml + "<Answer>" + answers + "</Answer>";   /* single integer or string */
	}

	xml = xml + "</Answers></Track>";
	return xml;
}

function Question_Submit( q, answers)
{
	q.Submit(answers);	
	trace("submitted: "+q +" - "+answers);
}

// Create an instance of the ESPQuestion class so it will be initialized
espquestion = new ESPQuestion();
