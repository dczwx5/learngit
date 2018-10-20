/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/7.
 */
package QFLib.QEngine.Renderer.Textures
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Renderer.States.SampleState;

    import flash.display3D.textures.TextureBase;

    public class TextureSlot implements IDisposable
    {
        public function TextureSlot()
        {}
        public var curSampleState : SampleState = null;
        public var newSampleState : SampleState = new SampleState();
        public var texture : TextureBase;

        public function dispose() : void
        {
            curSampleState.dispose();
            curSampleState = null;

            texture = null;
        }
    }
}
