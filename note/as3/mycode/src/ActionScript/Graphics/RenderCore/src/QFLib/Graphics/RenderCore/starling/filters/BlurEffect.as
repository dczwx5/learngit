//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Graphics.RenderCore.starling.filters
{
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MGaussianBlur;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Math.CMath;

    public class BlurEffect extends FilterEffect
    {
        public static const Name : String = "GaussianBlur";

        private static var sWeightsHelper : Vector.<Number> = new Vector.<Number> ( 5 );


        public function BlurEffect ( pFilter : ObjectFilter, params : Array )
        {
            super ( pFilter );
            m_Material = new MGaussianBlur ();

            mIsHorizontal = params[ 0 ];
            if ( params.length > 1 )
            {
                this.useGlow = params[ 1 ];
            }

            mCenterWeightAndOffsets[ 1 ] = mIsHorizontal ? 1.0 : 0.0;
            mCenterWeightAndOffsets[ 2 ] = mIsHorizontal ? 0.0 : 1.0;
        }

        override public function dispose () : void
        {
            super.dispose ();

            mCenterWeightAndOffsets.length = 0;
            mCenterWeightAndOffsets = null;
            mBlurWeights.length = 0;
            mBlurWeights = null;
        }

        [Inline] override public function get name () : String { return Name; }

        override public function render ( pOnwer : DisplayObject, support : RenderSupport, alpha : Number, pInTexture : Texture ) : Boolean
        {
            if ( super.render ( pOnwer, support, alpha, pInTexture ) )
            {
                computeGaussianWeight ();
                computeUVExpand ( pInTexture.width, pInTexture.height );

                var pInstance : Starling = Starling.current;
                pInstance.addToRender ( getRenderCommand () );

                return true;
            }

            return false;
        }

        override public function postRender ( support : RenderSupport, pCamera : ICamera ) : void
        {
            super.postRender ( support, pCamera );
        }

        public function set sampler ( value : int ) : void
        {
            if ( mSampler == value ) return;

            mSampler = value;
            mSamplerDirty = true;
        }

        public function set sigma ( value : Number ) : void
        {
            if( Math.abs( mSigma - value ) > CMath.EPSILON )
            {
                mSigma = value;
                mSigmaDirty = true;
            }
        }

        [Inline] public function set useGlow ( value : Boolean ) : void
        {
            if ( value )
            {
                mCenterWeightAndOffsets[ 3 ] = 0.0;   //mCenterWeightAndOffsets[3] store blur color factor
                mGlowColor[ 3 ] = 1.0;              //mGlowColor[3] store glow factor
            }
            else
            {
                mCenterWeightAndOffsets[ 3 ] = 1.0;   //mCenterWeightAndOffsets[3] store blur color factor
                mGlowColor[ 3 ] = 0.0;              //mGlowColor[3] store glow factor
            }
        }

        [Inline] public function setGlowColor ( red : Number, green : Number, blue : Number ) : void
        {
            mGlowColor[ 0 ] = red;
            mGlowColor[ 1 ] = green;
            mGlowColor[ 2 ] = blue;
        }

        [Inline] public function setGlowSize ( size : Number ) : void
        {
            mGlowSize = size;
            mGlowSizeDirty = true;
        }

        [Inline] public function setGlowStrenthen ( strenthen : Number ) : void { mGlowStrenthen = strenthen; }

        override protected function getRenderCommand () : RenderCommand
        {
            var matGaussianBlur : MGaussianBlur = m_Material as MGaussianBlur;
            matGaussianBlur.mainTexture = m_pInTexture;
            matGaussianBlur.pma = m_pInTexture.premultipliedAlpha;
            matGaussianBlur.centerWeightAndOffsets = mCenterWeightAndOffsets;
            matGaussianBlur.uvExpand = mUVExpand;
            matGaussianBlur.weights = mBlurWeights;
            matGaussianBlur.glowColor = mGlowColor;
            matGaussianBlur.glowStrenthen = mGlowStrenthen;

            return super.getRenderCommand ();
        }

        override protected function destroyMaterial () : void
        {
            var gaussianBlurMat : MGaussianBlur = m_Material as MGaussianBlur;
            if ( gaussianBlurMat != null )
            {
                gaussianBlurMat.dispose ();
                gaussianBlurMat = null;
            }
        }

        private function computeGaussianWeight () : void
        {
            if( !mSigmaDirty && !mSamplerDirty ) return;

            sWeightsHelper[ 0 ] = 1.0;
            sWeightsHelper[ 1 ] = sWeightsHelper[ 2 ] = sWeightsHelper[ 3 ] = sWeightsHelper[ 4 ] = 0.0;

            var twoSigmaSqure : Number = 2 * mSigma * mSigma;
            var invDPISigmaSqrt : Number = 1 / Math.sqrt( CMath.PI * twoSigmaSqure );
            var invTwoSigmaSqure : Number = -1 / twoSigmaSqure;

            var sumWeight : Number = 0.0;
            for ( var i : int = 0; i <= mSampler; i++ )
            {
                sWeightsHelper[ i ] = invDPISigmaSqrt * Math.exp( i * i * invTwoSigmaSqure );

                sumWeight += sWeightsHelper[ i ];
                if ( i > 0 && i <= mSampler )
                    sumWeight += sWeightsHelper[ i ];
            }

            for ( i = 0; i <= mSampler; i++ )
            {
                sWeightsHelper[ i ] /= sumWeight;

                if ( i > 0 )
                    mBlurWeights[ i - 1 ] = sWeightsHelper[ i ];
                else
                    mCenterWeightAndOffsets[ 0 ] = sWeightsHelper[ 0 ];
            }

            mSigmaDirty = mSamplerDirty = false;
        }

        private function computeUVExpand ( textureW : Number, textureH : Number ) : void
        {
            var textureSizeDirty : Boolean = textureW != mTextureW || textureH != mTextureH;
            if ( !textureSizeDirty && !mGlowSizeDirty ) return;
            mTextureW = textureW;
            mTextureH = textureH;

            var pixelW : Number = 1.0 / textureW;
            var pixelH : Number = 1.0 / textureH;

            if ( mIsHorizontal )
            {
                var offsetX : Number = mGlowSize * pixelW;
                mUVExpand [ 0 ] = offsetX;
                mUVExpand [ 1 ] = 2 * offsetX;
                mUVExpand [ 2 ] = 3 * offsetX;
                mUVExpand [ 3 ] = 4 * offsetX;
            }
            else
            {
                var offsetY : Number = mGlowSize * pixelH;
                mUVExpand [ 0 ] = offsetY;
                mUVExpand [ 1 ] = 2 * offsetY;
                mUVExpand [ 2 ] = 3 * offsetY;
                mUVExpand [ 3 ] = 4 * offsetY;
            }

            mGlowSizeDirty = false;
        }


        private var mBlurWeights : Vector.<Number> = new <Number>[ 0.0, 0.0, 0.0, 0.0 ];
        private var mCenterWeightAndOffsets : Vector.<Number> = new <Number>[ 1.0, 1.0, 0.0, 1.0 ];
        private var mUVExpand : Vector.<Number> = new <Number>[ 0.01, 0.02, 0.03, 0.04 ];
        private var mGlowColor : Vector.<Number> = new <Number>[ 1.0, 1.0, 1.0, 0.0 ];
        private var mGlowStrenthen : Number = 0.0;

        private var mSampler : int = 3;
        private var mSigma : Number = 2.0;
        private var mTextureW : Number = 0.0;
        private var mTextureH : Number = 0.0;
        private var mGlowSize : Number = 1.0;

        private var mIsHorizontal : Boolean = true;
        private var mSigmaDirty : Boolean = true;
        private var mSamplerDirty : Boolean = true;
        private var mGlowSizeDirty : Boolean = true;
    }
}
