//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/11/16.
 */
package QFLib.Graphics.RenderCore.render.material {

import QFLib.Graphics.RenderCore.render.IMaterial;
import QFLib.Graphics.RenderCore.render.pass.PColorMultiply;
import QFLib.Graphics.RenderCore.starling.textures.Texture;

public class MColorMultiply extends MaterialBase implements IMaterial
{
    private var _passColorMultiply : PColorMultiply;

    public function MColorMultiply()
    {
        super ( 1 );

        _passColorMultiply = new PColorMultiply();
        _passColorMultiply.enable = true;
        _passes[ 0 ] = _passColorMultiply;
    }

    public function equal ( other : IMaterial ) : Boolean
    {
        if ( other == null ) return false;
        var otherAlias : MColorMultiply = other as MColorMultiply;
        if ( otherAlias == null ) return false;

        return super.innerEqual ( otherAlias );
    }

    override public function reset () : void
    {
        setPassEnable ( _passColorMultiply.name, true, true );
    }

    override public function set mainTexture ( value : Texture ) : void
    {
        super.mainTexture = value;
        _passes[ 0 ].mainTexture = value;
    }

    public function set multiplyColor ( value : Vector.<Number> ) : void
    {
        _passColorMultiply.color = value;
    }

    public function get multiplyColor () : Vector.<Number>
    {
        return _passColorMultiply.color;
    }
}
}
