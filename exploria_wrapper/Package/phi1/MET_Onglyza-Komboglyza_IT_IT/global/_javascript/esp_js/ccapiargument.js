/*
   CCAPIArgument.js 
   Author: SKW
   Version: 1.0
   Modified: 09/28/2010
   Copyright: ExploriaSPS, LLC.
	
   This javascript file holds the definition for the ESP Content Communication API Argument class.
   This class is used to serialize objects between the host ESP application and the content.
*/

/* 
   Returns the class name of the argument or undefined if
   it's not a valid JavaScript object.
*/
var GetObjectClass = function(obj)
{
    if (obj && obj.constructor && obj.constructor.toString) {
        var arr = obj.constructor.toString().match(
            /function\s*(\w+)/);

        if (arr && arr.length == 2) {
            return arr[1];
        }
    }

    return undefined;
};

/* 
   Returns true if the object is an xml object.
*/
var IsXML = function(obj)
{
	var documentElement = (obj ? obj.ownerDocument || obj : 0).documentElement;
	return documentElement ? documentElement.nodeName !== "HTML" : false;
};

/* 
   Returns the inner Text string of an xml object. Undefined if there is none.
*/
var InnerText = function(obj)
{
	var node = obj;

	// If the node is null then return empty string.
	if ( node == null )
		return '';

	// Handle case that this is the Text node
	if ( node.nodeType == 3 ) // Text
		return node.nodeValue;

	// If there are no child nodes return empty string
	if ( node.childNodes == null )
		return '';

	// Search children for first Text node
	for( var i=0; i<node.childNodes.length; i++ )
	{
		var child = node.childNodes[i];
		if ( child.nodeType == 3 ) // Text
			return child.nodeValue;
	}
};

/* 
   Converts a string to a properly JSON enquoted string so it can be eval().
*/
var JSONEnquote = function( s )
{
    if ( s == null || s.length == 0 )
    {
        return "\"\"";
    }
    var c;
    var len = s.length;
    var sb = "";
    var t;

    sb = sb + "\"";
    for ( var i = 0; i < len; i++ )
    {
        c = s.charAt(i);
        if ( ( c == "\\" ) || ( c == "\"" ) || ( c == ">" ) )
        {
            sb = sb + "\\";
            sb = sb + c;
        }
        else if ( c == "\b" )
            sb = sb + "\\b";
        else if ( c == "\t" )
            sb = sb + "\\t";
        else if ( c == "\n" )
            sb = sb + "\\n";
        else if ( c == "\f" )
            sb = sb + "\\f";
        else if ( c == "\r" )
            sb = sb + "\\r";
        else
            sb = sb + c;
    }
    sb = sb + "\"";
    
    return sb;
};

/* 
   Content Communication API Argument class.
*/
function CCAPIArgument(obj) {

	/* Private argument type variable */
	var m_argumentType = CCAPI.ArgumentType.Undefined;

	/* Private argument value variable */
	var m_argumentValue;

	/* Handle the various constructor types */
	switch(typeof obj) {
	case 'number':
		this.SetWithNumber(obj);
		break;
	case 'string':
		this.SetWithString(obj);
		break;
	case 'boolean':
		this.SetWithBoolean(obj);
		break;
	case 'object':
		if (GetObjectClass(obj) == 'Array')
			this.SetWithArray(obj);
		else if (IsXML(obj))
			this.ParseXml(obj);
		else
			this.SetWithObject(obj);
		break;
	default:
		break;
	}
}

/*
   Sets this argument to a number.
*/
CCAPIArgument.prototype.SetWithNumber = function(obj)
{
	this.m_argumentType = CCAPI.ArgumentType.Number;
	this.m_argumentValue = obj;
}

/*
   Sets this argument to a string.
*/
CCAPIArgument.prototype.SetWithString = function(obj)
{
	this.m_argumentType = CCAPI.ArgumentType.String;
	this.m_argumentValue = obj;
}

/*
   Sets this argument to a boolean.
*/
CCAPIArgument.prototype.SetWithBoolean = function(obj)
{
	if ( obj == true )
		this.m_argumentType = CCAPI.ArgumentType.BooleanTrue;
	else
		this.m_argumentType = CCAPI.ArgumentType.BooleanFalse;
	
	this.m_argumentValue = obj;
}

/*
   Sets this argument to an array.
*/
CCAPIArgument.prototype.SetWithArray = function(obj)
{
	this.m_argumentType = CCAPI.ArgumentType.Array;
	this.m_argumentValue = obj;
}

/*
   Sets this argument to an object.
*/
CCAPIArgument.prototype.SetWithObject = function(obj)
{
	this.m_argumentType = CCAPI.ArgumentType.Object;
	this.m_argumentValue = obj;
}

/*
   Sets this argument to a parsed Xml DOM object.
*/
CCAPIArgument.prototype.ParseXml = function(obj)
{
	var node = obj;
	if (node.nodeType == 9) // Document node
	{
		// Get the first child
		node = node.firstChild;
	}

	switch(node.nodeName)
	{
	case 'undefined':
		this.m_argumentType = CCAPI.ArgumentType.Undefined;
		this.m_argumentValue = null;
		break;
	case 'true':
		this.m_argumentType = CCAPI.ArgumentType.BooleanTrue;
		this.m_argumentValue = true;
		break;
	case 'false':
		this.m_argumentType = CCAPI.ArgumentType.BooleanFalse;
		this.m_argumentValue = false;
		break;
	case 'string':
		this.m_argumentType = CCAPI.ArgumentType.String;
		this.m_argumentValue = InnerText(node.firstChild);
		break;
	case 'number':
		this.m_argumentType = CCAPI.ArgumentType.Number;
		this.m_argumentValue = InnerText(node.firstChild);
		break;
	case 'array':
		var ccArray = new Array();
		for ( var i=0; i<node.childNodes.length; i++ )
		{
			// Get the "property" node
			var nodeProperty = node.childNodes[i];

			// Get the actual Property node
			var pNode = nodeProperty.firstChild;

			var arg = new CCAPIArgument( pNode );
			ccArray.push( arg );
			
		}
		this.m_argumentType = CCAPI.ArgumentType.Array;
		this.m_argumentValue = ccArray;
		break;

	case 'object':
		var ccObject = new Object();
		for ( var i=0; i<node.childNodes.length; i++ )
		{
			// Get the "property" node
			var nodeProperty = node.childNodes[i];

			// Get the property node's attribute "id"
			var key = nodeProperty.attributes.getNamedItem("id").value;

			// Get the actual Property node
			var pNode = nodeProperty.firstChild;

			var arg = new CCAPIArgument( pNode );
			ccObject[key] = arg;
			
		}
		this.m_argumentType = CCAPI.ArgumentType.Object;
		this.m_argumentValue = ccObject;
		break;
	default:
		break;
	}
}

/*
   Returns the xml string for this argument to pass to a content
   communication function call.
*/
CCAPIArgument.prototype.ToStringForCallCCFunction = function()
{
	var s = "";

	switch(this.m_argumentType)
	{
	case CCAPI.ArgumentType.Undefined:
		s = "<undefined/>";
		break;
	case CCAPI.ArgumentType.String:
		s = this.m_argumentValue;

		// convert special characters
		// see: http://www.w3schools.com/html/html_entities.asp

		s.replace( "<", "&lt;" );
		s.replace( ">", "&gt;" );
		s.replace( "\"", "&quot;" );
		s.replace( "'", "&apos;" );

		s = "<string>" + s + "</string>";
		break;
	case CCAPI.ArgumentType.Number:
		s = "<number>" + this.m_argumentValue + "</number>";
		break;
	case CCAPI.ArgumentType.BooleanTrue:
		s = "<true/>";
		break;
	case CCAPI.ArgumentType.BooleanFalse:
		s = "<false/>";
		break;
	case CCAPI.ArgumentType.Array:
		s = "<array>";
		for ( var i=0; i<this.m_argumentValue.length; i++ )
		{
			var item = this.m_argumentValue[i];

			s = s.concat("<property id=\"", i, "\">");

			if ( item == undefined || item == null )
				s = s + "<undefined/>";
			else
				s = s + item.ToStringForCallCCFunction();

			s = s + "</property>";
		}
		s = s + "</array>";
		break;
	case CCAPI.ArgumentType.Object:
		s = "<object>";
		for ( var key in this.m_argumentValue )
		{
			var val = this.m_argumentValue[key];

			s = s.concat("<property id=\"", key, "\">");

			if ( val == undefined || val == null )
				s = s + "<undefined/>";
			else
				s = s + val.ToStringForCallCCFunction();

			s = s + "</property>";
		}
		s = s + "</object>";
		break;
	}
	return s;
}

/*
   Returns the actual value object for this argument.
*/
CCAPIArgument.prototype.ToValue = function()
{
	switch(this.m_argumentType)
	{
	case CCAPI.ArgumentType.Array:
		// Convert from CCAPIArgument objects to objects
		var arr = new Array();
		for ( var i=0; i<this.m_argumentValue.length; i++ )
		{
			var item = this.m_argumentValue[i];

			if ( item == undefined || item == null )
				arr.push( item );
			else
				arr.push( item.ToValue() );
		}
		return arr;
		break;
	case CCAPI.ArgumentType.Object:
		// Convert from CCAPIArgument objects to objects
		var obj = new Object();
		for ( var key in this.m_argumentValue )
		{
			var val = this.m_argumentValue[key];

			if ( val == undefined || val == null )
				obj[key] = val;
			else
				obj[key] = val.ToValue();
		}
		return obj;
		break;
	default:
		// Return the value object for all other cases
		return this.m_argumentValue;
		break;
	}
}

