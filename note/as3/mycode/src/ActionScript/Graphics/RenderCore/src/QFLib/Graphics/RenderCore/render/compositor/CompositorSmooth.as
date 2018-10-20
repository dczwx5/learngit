////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2016/12/12.
 */
package QFLib.Graphics.RenderCore.render.compositor
{

    import QFLib.Graphics.RenderCore.render.ICompositor;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.material.MSmooth;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.GetNextPowerOfTwo;

    public class CompositorSmooth extends CompositorBase implements ICompositor
    {
        public static const Name : String = "Smooth";

        private var mMaterial : MSmooth = new MSmooth ();
        private var mUVOffsets : Vector.<Number> = new <Number>[ 1.0, 0.0, 1.0, 4.0 ];

        private var mTextureW : int = 2048;
        private var mTextureH : int = 1024;
        private var mCurrentDownSampler : int = 1;
        private var mStep : Number = 0.0;

        public function CompositorSmooth ()
        {
            super ();
        }

        public override function dispose () : void
        {
            mMaterial.dispose ();
            super.dispose ();
        }

        [Inline] public override function get name () : String
        {
            return Name;
        }

        [Inline] public override function get material () : IMaterial
        {
            return mMaterial;
        }

        public override function get textureWidth() : int
        {
            return 512;
//            mTextureW = GetNextPowerOfTwo ( Starling.current.stage.stageWidth ) / mCurrentDownSampler;
//            mTextureW = mTextureW > 2048 ? 2048 : mTextureW;
//
//            return mTextureW;
        }

        public override function get textureHeight() : int
        {
            return 256;
//            mTextureH = GetNextPowerOfTwo ( Starling.current.stage.stageHeight ) / mCurrentDownSampler;
//            mTextureH = mTextureH > 2048 ? 2048 : mTextureH;
//
//            return mTextureH;
        }

        public override function set gradualChangeTime ( value : Number ) : void
        {
            super.gradualChangeTime = value;
            mStep = 3 / value;
        }

        public override function set preRenderTarget ( preTarget : Texture ) : void
        {
            super.preRenderTarget = preTarget;
            mMaterial.mainTexture = mPreTexture;
            mMaterial.pma = mPreTexture.premultipliedAlpha;
            mUVOffsets[ 0 ] = 1.0 / mPreTexture.width;
            mUVOffsets[ 2 ] = 1.0 / mPreTexture.height;
            mMaterial.uvOffsets = mUVOffsets;
        }

        public override function update ( deltaTime : Number ) : void
        {
            if ( !mEnable ) return;
            super.update ( deltaTime );

            var val : Number = 0.0;
            if ( mDelayDisable )
            {
                val = mCurrentDownSampler - Math.floor( mCurrentTime / mStep );
                mCurrentDownSampler = val <= 1 ? 1 : val;
            }
            else if ( mEnable && mGradualChangeTime > 0.0 )
            {
                val = mCurrentDownSampler + Math.floor( mCurrentTime / mStep );
                mCurrentDownSampler = val > 2 ? 2 : val;
            }
            else
            {
                mCurrentDownSampler = 2;
            }
        }
    }
}
