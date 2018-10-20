/**
 * Created by david on 2016/11/30.
 */
package QFLib.Graphics.RenderCore.render.compositor
{
    import QFLib.Graphics.RenderCore.render.ICompositor;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.material.MGaussianBlur;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Math.CMath;

    public class CompositorGaussianBlur extends CompositorBase implements ICompositor
    {
        public static const Name : String = "GaussianBlur";

        private static var sUVExpandHelper : Vector.<Number> = new Vector.<Number> ( 4 );
        private static var sWeightsHelper : Vector.<Number> = new Vector.<Number> ( 5 );

        private var mBlurWeights : Vector.<Number> = new <Number>[ 0.0, 0.0, 0.0, 0.0 ];
        private var mCenterWeightAndOffsets : Vector.<Number> = new <Number>[ 1.0, 1.0, 0.0, 1.0 ];

        private var mMaterial : MGaussianBlur = new MGaussianBlur ();
        private var mSampler : int = 3;
        private var mSigma : Number = 1.5;

        private var mTextureW : int = 2048;
        private var mTextureH : int = 1024;

        private var mIsHorizontal : Boolean = true;
        private var mSigmaDirty : Boolean = true;
        private var mTextureWHDirty : Boolean = true;
        private var mSamplerDirty : Boolean = true;

        public function CompositorGaussianBlur ( horizontal : Boolean )
        {
            super ();

            mIsHorizontal = horizontal;

            mCenterWeightAndOffsets[ 1 ] = mIsHorizontal ? 1.0 : 0.0;
            mCenterWeightAndOffsets[ 2 ] = mIsHorizontal ? 0.0 : 1.0;
        }

        override public function dispose () : void
        {
            mMaterial.dispose();
            super.dispose ();
        }

        override public function get name () : String
        {
            return Name;
        }

        override public function get material () : IMaterial
        {
            return mMaterial;
        }

        override protected function reset () : void
        {
            super.reset ();
//            mBlurWeights [ 0 ] = mBlurWeights [ 1 ] = mBlurWeights [ 2 ] = mBlurWeights [ 3 ] = 0.0;
//            mCenterWeightAndOffsets [ 0 ] = 1.0;

            mSamplerDirty = true;
            mSigmaDirty = true;
        }

        override public function set preRenderTarget ( preTarget : Texture ) : void
        {
            super.preRenderTarget = preTarget;
            mMaterial.mainTexture = mPreTexture;
            mMaterial.pma = mPreTexture.premultipliedAlpha;

            if ( mPreTexture.width != mTextureW || mPreTexture.height != mTextureH )
            {
                mTextureW = mPreTexture.width;
                mTextureH = mPreTexture.height;
                mTextureWHDirty = true;
            }

            computeGaussianWeight ();
            computeUVExpand ();

            mMaterial.uvExpand = sUVExpandHelper;
            mMaterial.weights = mBlurWeights;
            mMaterial.centerWeightAndOffsets = mCenterWeightAndOffsets;
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

        public override function update ( deltaTime : Number ) : void
        {
            if ( !mEnable ) return;
            super.update ( deltaTime );

            var scale : Number = 1.0;
            var val : Number = 0.0;
            var invWeight0 : Number = 1.0 - sWeightsHelper[ 0 ];
            var step : Number = ( deltaTime / mGradualChangeTime );
            var v0 : Number = step * invWeight0;
            if ( mDelayDisable )                                      // gradual change stopping
            {
                val = mCenterWeightAndOffsets[ 0 ] + v0;
                mCenterWeightAndOffsets[ 0 ] = val >= 1.0 ? 1.0 : val;

                for ( var i : int = 0; i < 4; i++ )
                {
                    scale = sWeightsHelper[ i + 1 ] / invWeight0;
                    val = mBlurWeights[ i ] - scale * v0;
                    mBlurWeights[ i ] = val <= 0.0 ? 0.0 : val;
                }
            }
            else if ( mEnable && mGradualChangeTime > 0 )            //gradual change playing
            {
                val = mCenterWeightAndOffsets[ 0 ] - v0;
                mCenterWeightAndOffsets[ 0 ] = val <= sWeightsHelper[ 0 ] ? sWeightsHelper[ 0 ] : val;

                for ( i = 0; i < 4; i++ )
                {
                    scale = sWeightsHelper[ i + 1 ] / invWeight0;
                    val = mBlurWeights[ i ] + scale * v0;
                    mBlurWeights[ i ] = val >= sWeightsHelper[ i + 1 ] ? sWeightsHelper[ i + 1 ] : val;
                }
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

                if ( mGradualChangeTime <= 0 )
                {
                    if( i > 0 )
                        mBlurWeights[ i - 1 ] = sWeightsHelper[ i ];
                    else
                        mCenterWeightAndOffsets[ 0 ] = sWeightsHelper[ 0 ];
                }
            }

            mSigmaDirty = mSamplerDirty = false;
        }

        private function computeUVExpand () : void
        {
            if( !mTextureWHDirty ) return;

            var pixelW : Number = 1 / mTextureW;
            var pixelH : Number = 1 / mTextureH;

            if ( mIsHorizontal )
            {
                var offsetX : Number = pixelW;
                sUVExpandHelper [ 0 ] = offsetX;
                sUVExpandHelper [ 1 ] = 2 * offsetX;
                sUVExpandHelper [ 2 ] = 3 * offsetX;
                sUVExpandHelper [ 3 ] = 4 * offsetX;
            }
            else
            {
                var offsetY : Number = pixelH;
                sUVExpandHelper [ 0 ] = offsetY;
                sUVExpandHelper [ 1 ] = 2 * offsetY;
                sUVExpandHelper [ 2 ] = 3 * offsetY;
                sUVExpandHelper [ 3 ] = 4 * offsetY;
            }

            mTextureWHDirty = false;
        }
    }
}
