/*
   ESPFeedback.js 
   Author: SKW
   Version: 1.0
   Modified: 10/01/2010
   Copyright: ExploriaSPS, LLC.
	
   This javascript file holds the definition for the ESP Feedback class.
   This class is used to make feedback tracking calls from the content to the host ESP application.
*/

/*
   If there is no indexOf prototype in the host browser then define one.
*/
if (!Array.prototype.indexOf)
{
  Array.prototype.indexOf = function(elt /*, from*/)
  {
    var len = this.length;

    var from = Number(arguments[1]) || 0;
    from = (from < 0)
         ? Math.ceil(from)
         : Math.floor(from);
    if (from < 0)
      from += len;

    for (; from < len; from++)
    {
      if (from in this &&
          this[from] === elt)
        return from;
    }
    return -1;
  };
}

/* 
   ESP Feedback class.
*/
function ESPFeedback(trackId, description, message)
{
	/* Feedback constants */
	ESPFeedback.ACCEPT 	= 0;
	ESPFeedback.NEUTRAL 	= 1;
	ESPFeedback.REJECT 	= 2;
	
	/* The three feedback button parameters 
	0 = Accept, Positive , Very Compelling
	1 = Neutral, Moderately Compelling
	2 = Reject, Not Compelling, Negative
	*/
	ESPFeedback.Answers = [ "Accept", "Neutral", "Reject" ];

	/* Private trackID variable */
	var m_trackID = "FEEDBACK";

	/* Private description variable */
	var m_description = "";

	/* Private message variable that holds the message for this feedback survey question */
	var m_message = "";

	/* Private submitted variable that will be set to true after the feedback is submitted */
	var m_submitted = false;

	// Set the data members based on the passed arguments
	this.SetTrackID( trackId );
	this.SetDescription( description );
	this.SetMessage( message );
}

/*
   Sets the trackId.
*/
ESPFeedback.prototype.SetTrackID = function(trackId)
{
	if ( trackId )
		this.m_trackID = trackId;
}

/*
   Sets the description.
*/
ESPFeedback.prototype.SetDescription = function(description)
{
	if ( description )
		this.m_description = description;
}

/*
   Sets the message.
*/
ESPFeedback.prototype.SetMessage = function(message)
{
	if ( message )
		this.m_message = message;
}

/*
   Returns true if the feedback has been submitted.
*/
ESPFeedback.prototype.IsSubmitted = function()
{
	return this.m_submitted;
}

/*
   Submits an answer for the feedback survey.
	answer:		Answer string.
	
	returns:	True if submitted successfully, false not submitted.	
*/
ESPFeedback.prototype.Submit = function(answer)
{	
	// If the answer index is out of range let caller know we could not submit
	if ( answer < 0 || answer >= ESPFeedback.Answers.length )
		return false;
		
	// Get the track xml to submit
	var xml = this.GetTrackXml( answer );
	
	trace(xml);
	
	var callID = CCAPI.CallESPFunction(CCAPI.TRK_set, "myCallback", this.m_trackID, xml);
	trace('trackID: '+this.m_trackID);
	trace('Message: '+this.m_message);
	this.m_submitted = true;
	
	// Return the callID so caller can identify it in myCallback
	return callID;
}

/*
   Returns the xml string to submit to the host ESP application for the track data.
	answerIndex:	Zero based integer index of the answer.
	
	returns:	Xml string of track data for the passed answer index.	
*/
ESPFeedback.prototype.GetTrackXml = function(answerIndex)
{
	// Create the XML by hand for now
	var xml = "<Track><Answers>";
	xml = xml + "<Answer>" + answerIndex + "</Answer>";
	xml = xml + "</Answers></Track>";
	return xml;
}

//Feedback click function
function Feedback_Click(feedbackName,answer)
{
	
	trace( "Feedback_Click answer=" + answer );
	var res = feedbackName.Submit( answer );
	trace( "feedback.Submit res=" + res );
	
/*	if ( !feedback.IsSubmitted() )
	{
		console.log( "!feedback.IsSubmitted()" );
	}*/
}


// Create an instance of the ESPFeedback class so it will be initialized
espfeedback = new ESPFeedback();
