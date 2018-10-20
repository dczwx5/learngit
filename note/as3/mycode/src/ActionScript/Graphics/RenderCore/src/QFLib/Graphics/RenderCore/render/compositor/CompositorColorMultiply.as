//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/11/16.
 */
package QFLib.Graphics.RenderCore.render.compositor {

import QFLib.Graphics.RenderCore.render.IMaterial;
import QFLib.Graphics.RenderCore.render.material.MColorMultiply;
import QFLib.Graphics.RenderCore.starling.textures.Texture;

public class CompositorColorMultiply extends CompositorBase
{
    public static const Name:String = "ColorMultiply";
    protected var mMaterial:MColorMultiply = new MColorMultiply();

    public function CompositorColorMultiply( color : Vector.<Number> )
    {
        super();

        mMaterial.multiplyColor = color;
    }

    override public function get name():String
    {
        return Name;
    }

    override public function get material():IMaterial
    {
        return mMaterial;
    }

    override public function get textureWidth() : int
    {
        return 2048;
    }

    override public function get textureHeight() : int
    {
        return 1024;
    }

    override public function set preRenderTarget(preTarget:Texture):void
    {
        super.preRenderTarget = preTarget;
        mMaterial.mainTexture = mPreTexture;
        mMaterial.pma = mPreTexture.premultipliedAlpha;
    }

    public function set colorMultiply(value:Vector.<Number>):void
    {
        mMaterial.multiplyColor = value;
    }
}
}
