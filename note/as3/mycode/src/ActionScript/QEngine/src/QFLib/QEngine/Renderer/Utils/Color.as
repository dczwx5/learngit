/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Utils
{
    import QFLib.QEngine.Errors.AbstractClassError;

    /** A utility class containing predefined colors and methods converting between different
     *  color representations. */
    public class Color
    {
        public static const WHITE : uint = 0xffffff;
        public static const SILVER : uint = 0xc0c0c0;
        public static const GRAY : uint = 0x808080;
        public static const BLACK : uint = 0x000000;
        public static const RED : uint = 0xff0000;
        public static const MAROON : uint = 0x800000;
        public static const YELLOW : uint = 0xffff00;
        public static const OLIVE : uint = 0x808000;
        public static const LIME : uint = 0x00ff00;
        public static const GREEN : uint = 0x008000;
        public static const AQUA : uint = 0x00ffff;
        public static const TEAL : uint = 0x008080;
        public static const BLUE : uint = 0x0000ff;
        public static const NAVY : uint = 0x000080;
        public static const FUCHSIA : uint = 0xff00ff;
        public static const PURPLE : uint = 0x800080;
        public static const ORANGE : uint = 0xFFA500;
        public static const GOLD : uint = 0xFFD700;

        /** Returns the alpha part of an ARGB color (0 - 255). */
        public static function getAlpha( color : uint ) : int
        {
            return (color >> 24) & 0xff;
        }

        /** Returns the red part of an (A)RGB color (0 - 255). */
        public static function getRed( color : uint ) : int
        {
            return (color >> 16) & 0xff;
        }

        /** Returns the green part of an (A)RGB color (0 - 255). */
        public static function getGreen( color : uint ) : int
        {
            return (color >> 8) & 0xff;
        }

        /** Returns the blue part of an (A)RGB color (0 - 255). */
        public static function getBlue( color : uint ) : int
        {
            return color & 0xff;
        }

        /** Creates an RGB color, stored in an unsigned integer. Channels are expected
         *  in the range 0 - 255. */
        public static function rgb( red : int, green : int, blue : int ) : uint
        {
            return (red << 16) | (green << 8) | blue;
        }

        /** Creates an ARGB color, stored in an unsigned integer. Channels are expected
         *  in the range 0 - 255. */
        public static function argb( alpha : int, red : int, green : int, blue : int ) : uint
        {
            return (alpha << 24) | (red << 16) | (green << 8) | blue;
        }

        public static function rgba( red : int, green : int, blue : int, alpha : int ) : uint
        {
            return (red << 24) | (green << 16) | (blue << 8) | alpha;
        }

        /** @private */
        public function Color()
        {
            throw new AbstractClassError();
        }
    }
}