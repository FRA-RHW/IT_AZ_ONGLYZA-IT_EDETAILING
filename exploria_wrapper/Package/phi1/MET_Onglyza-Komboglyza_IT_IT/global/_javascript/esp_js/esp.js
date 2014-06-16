
function EVT_slideLoad(mode, data)
{
	//alert("EVT_slideLoad" + mode + data);
	//output("EVT_slideLoad" + mode + data);
	/*trace("EVT_slideLoad" + mode + data);

	var s = "";

	for (var k in data)
	{
		s = s + "data." + k + " = " + data[k] + " ";
	}
	//alert(s);
	//output(s);
	trace(s);*/
}

function EVT_slideStart()
{
	StartPage();
}

function EVT_slideEnd()
{
	//alert("EVT_slideEnd");
	//output("EVT_slideEnd");
	trace("EVT_slideEnd");
}
