------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_side_shop_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_side_shop.OnStart();
end

function OnEnd()
	mode_generic_side_shop.OnEnd();
end

function GetDesire()
	return mode_generic_side_shop.GetDesire();
end

function Think()
	mode_generic_side_shop.Think();
end

--------
