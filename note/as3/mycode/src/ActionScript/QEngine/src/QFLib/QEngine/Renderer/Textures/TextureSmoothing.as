/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Textures
{
    import QFLib.QEngine.Errors.AbstractClassError;

    /** A class that provides constant values for the possible smoothing algorithms of a texture. */
    public class TextureSmoothing
    {
        /** No smoothing, also called "Nearest Neighbor". Pixels will scale up as big rectangles. */
        public static const NONE : String = "none";
        /** Bilinear filtering. Creates smooth transitions between pixels. */
        public static const BILINEAR : String = "bilinear";
        /** Trilinear filtering. Highest quality by taking the next mip map level into account. */
        public static const TRILINEAR : String = "trilinear";

        /** Determines whether a smoothing value is valid. */
        public static function isValid( smoothing : String ) : Boolean
        {
            return smoothing == NONE || smoothing == BILINEAR || smoothing == TRILINEAR;
        }

        /** @private */
        public function TextureSmoothing()
        {
            throw new AbstractClassError();
        }
    }
}