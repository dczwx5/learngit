//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

/**
 * IConfiguration
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IConfiguration {

    function getRaw( key : String, defaultVal : * = undefined ) : *;

    function getInt( key : String, defaultVal : int = 0 ) : int;

    function getString( key : String, defaultVal : String = null ) : String;

    function getBoolean( key : String, defaultValue : Boolean = false ) : Boolean;

    function getNumber( key : String, defaultValue : Number = NaN ) : Number;

    function getXML( key : String, defaultValue : XML = null ) : XML;

    function getJSONObject( key : String, defaultValue : Object = null ) : Object;

    function setConfig( key : String, value : * ) : *;

    function addUpdateListener( func : Function ) : void;

    function removeUpdateListener( func : Function ) : Boolean;

    function addItemUpdateListener( key : String, func : Function ) : void;

    function removeItemUpdateListener( key : String, func : Function = null ) : Boolean;

} // interface IConfiguration
}
