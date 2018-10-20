//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/5
//----------------------------------------------------------------------------------------------------------------------

package QFLib.DashBoard
{

    //
    //
    //
    public interface IConsoleCommand
    {
        function get name() : String;
        function get description() : String;
        function get label() : String;
        function onCommand( args : Array ) : Boolean;
    }

}
