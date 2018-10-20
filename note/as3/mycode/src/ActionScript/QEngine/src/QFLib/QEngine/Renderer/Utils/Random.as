/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Utils
{
    public class Random
    {
        private static const MAX_UINT : uint = 0xFFFFFFFF;
        private static const MAX_RATIO : Number = 1.0 / MAX_UINT;

        public function Random( seed : uint ) : void
        {
            this.seed = seed;
        }

        public var seed : uint;

        [Inline]
        final public function next() : Number
        {
            return nextUInt() * MAX_RATIO;
        }

        [Inline]
        final public function nextUInt() : uint
        {
            seed ^= (seed << 21);
            seed ^= (seed >> 35);
            seed ^= (seed << 4);
            return seed;
        }
    }
}