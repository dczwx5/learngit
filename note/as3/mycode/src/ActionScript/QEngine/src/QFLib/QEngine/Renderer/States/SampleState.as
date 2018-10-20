/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/6.
 */
package QFLib.QEngine.Renderer.States
{
    import QFLib.Interface.IDisposable;

    public class SampleState implements IDisposable
    {
        public function SampleState()
        {}
        public var wrapMode : String;
        public var filter : String;
        public var mipFilter : String;

        public function dispose() : void
        {
            wrapMode = null;
            filter = null;
            mipFilter = null;
        }

        [Inline]
        final public function copy( other : SampleState ) : void
        {
            this.wrapMode = other.wrapMode;
            this.filter = other.filter;
            this.mipFilter = other.mipFilter;
        }
    }
}
