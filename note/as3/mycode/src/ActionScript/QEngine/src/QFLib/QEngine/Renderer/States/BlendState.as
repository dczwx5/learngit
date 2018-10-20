/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/6.
 */
package QFLib.QEngine.Renderer.States
{
    import QFLib.Interface.IDisposable;

    import flash.display3D.Context3DBlendFactor;

    public class BlendState implements IDisposable
    {
        public function BlendState()
        {}
        /**
         * blend state
         */
        public var srcBlendFunc : String = Context3DBlendFactor.ONE;
        public var dstBlendFunc : String = Context3DBlendFactor.ZERO;
        public var enableBlend : Boolean = false;

        public function dispose() : void
        {
            srcBlendFunc = null;
            dstBlendFunc = null;
        }

        [Inline]
        final public function copy( other : BlendState ) : void
        {
            this.srcBlendFunc = other.srcBlendFunc;
            this.dstBlendFunc = other.dstBlendFunc;
            this.enableBlend = other.enableBlend;
        }
    }
}
