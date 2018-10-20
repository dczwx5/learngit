/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/2/17.
 */
package QFLib.QEngine.Renderer.States
{
    import QFLib.Interface.IDisposable;

    import flash.display3D.Context3DClearMask;
    import flash.display3D.Context3DTriangleFace;

    public class RasterState implements IDisposable
    {
        public function RasterState()
        {}
        /**
         * clear mask
         */
        public var clearMask : int = Context3DClearMask.ALL;
        /**
         * fill mode : only work on air desktop app, air version: 16
         */
        public var fillMode : String = "solid";
        /**
         * culling mode
         */
        public var cullingMode : String = Context3DTriangleFace.NONE;

        public function dispose() : void
        {
            fillMode = null;
            cullingMode = null;
        }

        [Inline]
        final public function copy( other : RasterState ) : void
        {
            this.clearMask = other.clearMask;
            this.fillMode = other.fillMode;
            this.cullingMode = other.cullingMode;
        }
    }
}
