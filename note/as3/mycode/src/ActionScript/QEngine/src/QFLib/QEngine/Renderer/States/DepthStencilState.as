/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/6.
 */
package QFLib.QEngine.Renderer.States
{
    import QFLib.Interface.IDisposable;

    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DStencilAction;

    public class DepthStencilState implements IDisposable
    {
        public function DepthStencilState()
        {}
        /**
         * depth and stencil state
         */
        public var depthTestFunc : String = Context3DCompareMode.ALWAYS;
        public var enableDepthTest : Boolean = true;
        public var enableDepthWrite : Boolean = true;
        public var stencilTestAction : String = Context3DStencilAction.ZERO;
        public var enableStencilTest : Boolean = false;

        public function dispose() : void
        {
            depthTestFunc = null;
            stencilTestAction = null;
        }

        [Inline]
        final public function copy( other : DepthStencilState ) : void
        {
            this.depthTestFunc = other.depthTestFunc;
            this.enableDepthTest = other.enableDepthTest;
            this.stencilTestAction = other.stencilTestAction;
        }
    }
}
