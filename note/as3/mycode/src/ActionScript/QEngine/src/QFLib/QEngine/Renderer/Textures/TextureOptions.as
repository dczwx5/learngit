/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Textures
{
    import QFLib.QEngine.Renderer.Device.RenderDeviceManager;

    /** The TextureOptions class specifies options for loading textures with the 'Texture.fromData'
     *  method. */
    public class TextureOptions
    {
        public function TextureOptions( scale : Number = 1.0, mipMapping : Boolean = false,
                                        format : String = "compressedAlpha" )
        {
            mScale = scale;
            mFormat = format;
            mMipMapping = mipMapping;
        }

        private var mScale : Number;
        private var mFormat : String;
        private var mMipMapping : Boolean;
        private var mOptimizeForRenderToTexture : Boolean = false;
        private var mOnReady : Function = null;
        private var mRepeat : Boolean = false;

        /** The scale factor, which influences width and height properties. If you pass '-1',
         *  the current global content scale factor will be used. */
        public function get scale() : Number
        {
            return mScale;
        }

        public function set scale( value : Number ) : void
        {
            mScale = value > 0 ? value : RenderDeviceManager.getInstance().current.contentScaleFactor;
        }

        /** The <code>Context3DTextureFormat</code> of the underlying texture data. */
        public function get format() : String
        {
            return mFormat;
        }

        public function set format( value : String ) : void
        {
            mFormat = value;
        }

        /** Indicates if the texture contains mip maps. */
        public function get mipMapping() : Boolean
        {
            return mMipMapping;
        }

        public function set mipMapping( value : Boolean ) : void
        {
            mMipMapping = value;
        }

        /** Indicates if the texture will be used as render target. */
        public function get optimizeForRenderToTexture() : Boolean
        {
            return mOptimizeForRenderToTexture;
        }

        public function set optimizeForRenderToTexture( value : Boolean ) : void
        {
            mOptimizeForRenderToTexture = value;
        }

        /** Indicates if the texture should repeat like a wallpaper or stretch the outermost pixels.
         *  Note: this only works in textures with sidelengths that are powers of two and
         *  that are not loaded from a texture atlas (i.e. no subtextures). @default false */
        public function get repeat() : Boolean
        {
            return mRepeat;
        }

        public function set repeat( value : Boolean ) : void
        {
            mRepeat = value;
        }

        /** A callback that is used only for ATF textures; if it is set, the ATF data will be
         *  decoded asynchronously. The texture can only be used when the callback has been
         *  executed. This property is ignored for all other texture types (they are ready
         *  immediately when the 'Texture.from...' method returns, anyway).
         *
         *  <p>This is the expected function definition:
         *  <code>function(texture:Texture):void;</code></p>
         */
        public function get onReady() : Function
        {
            return mOnReady;
        }

        public function set onReady( value : Function ) : void
        {
            mOnReady = value;
        }
    }
}