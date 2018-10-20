//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by David on 2016/9/18.
 */
package QFLib.Graphics.FX
{

    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;

    public interface IFXModify
    {
        function get theObject () : CBaseObject;

        function get renderableObject () : DisplayObject;

        function get material () : IMaterial;

        //set tint color
        function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void;

        //reset tint color
        function resetColor () : void;

        function _notifyAttached ( object : Object ) : void;

        function _notifyDetached ( object : Object ) : void;
    }
}
