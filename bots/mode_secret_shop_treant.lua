------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_secret_shop_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_secret_shop.OnStart();
end

function OnEnd()
	mode_generic_secret_shop.OnEnd();
end

function GetDesire()
	return mode_generic_secret_shop.GetDesire();
end

function Think()
	mode_generic_secret_shop.Think();
end

--------
