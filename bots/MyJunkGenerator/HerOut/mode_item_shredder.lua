-------
require( GetScriptDirectory().."/mode_item_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_item.OnStart();
end

function OnEnd()
	mode_generic_item.OnEnd();
end

function GetDesire()
	return mode_generic_item.GetDesire();
end

function Think()
	mode_generic_item.Think();
end

--------
