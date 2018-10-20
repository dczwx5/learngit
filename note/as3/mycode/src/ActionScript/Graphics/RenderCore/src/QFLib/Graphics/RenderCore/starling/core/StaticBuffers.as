//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/8/31.
 */
package QFLib.Graphics.RenderCore.starling.core
{

    import flash.display3D.Context3DBufferUsage;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;

    public class StaticBuffers
    {
        private var _fxStaticIndexBuffer : IndexBuffer3D = null;
        private var _imgStaticIndexBufer : IndexBuffer3D = null;
        private var _fxStaticVertexBuffer : VertexBuffer3D = null;
        private var _imgStaticVertexBuffer : VertexBuffer3D = null;

        static public function getInstance () : StaticBuffers
        {
            return SingletonHolder.instance ();
        }

        function StaticBuffers()
        {
            Starling.addContext3DCreateCallback( this, onContextCreated );
        }

        public function dispose () : void
        {
            Starling.removeContext3DCreateCallback( this, onContextCreated );
            destroyBuffers ();
        }

        public function get fxStaticIndexBuffer () : IndexBuffer3D
        {
            if ( _fxStaticIndexBuffer == null )
            {
                var indices : Vector.<uint> = Vector.<uint> ( [ 0, 1, 2, 0, 2, 3 ] );
                var pStarling : Starling = Starling.current;
                _fxStaticIndexBuffer = pStarling.createIndexBuffer ( 6 );
                pStarling.uploadIndexBufferData ( _fxStaticIndexBuffer, indices, 0, 6 );
            }
            return _fxStaticIndexBuffer;
        }

        public function get imgStaticIndexBuffer () : IndexBuffer3D
        {
            if ( _imgStaticIndexBufer == null )
            {
                var indices : Vector.<uint> = Vector.<uint> ( [ 0, 1, 2, 1, 3, 2 ] );
                var pStarling : Starling = Starling.current;
                _imgStaticIndexBufer = pStarling.createIndexBuffer ( 6 );
                pStarling.uploadIndexBufferData ( _imgStaticIndexBufer, indices, 0, 6 );
            }

            return _imgStaticIndexBufer;
        }

        public function get fxStaticVertexBuffer () : VertexBuffer3D
        {
            if ( _fxStaticVertexBuffer == null )
            {
                var pStarling : Starling = Starling.current;
                _fxStaticVertexBuffer = pStarling.createVertexBuffer ( 4, 8, Context3DBufferUsage.DYNAMIC_DRAW );
            }
            return _fxStaticVertexBuffer;
        }

        public function get imgStaticVertexBuffer () : VertexBuffer3D
        {
            if ( _imgStaticVertexBuffer == null )
            {
                var pStarling : Starling = Starling.current;
                _imgStaticVertexBuffer = pStarling.createVertexBuffer ( 4, 8, Context3DBufferUsage.DYNAMIC_DRAW );
            }
            return _imgStaticVertexBuffer;
        }

        private function destroyBuffers () : void
        {
            var pStarling : Starling = Starling.current;
            pStarling.destroyIndexBuffer ( _fxStaticIndexBuffer );
            _fxStaticIndexBuffer = null;

            pStarling.destroyIndexBuffer ( _imgStaticIndexBufer );
            _imgStaticIndexBufer = null;

            pStarling.destroyVertexBuffer ( _fxStaticVertexBuffer );
            _fxStaticVertexBuffer = null;

            pStarling.destroyVertexBuffer ( _imgStaticVertexBuffer );
            _imgStaticVertexBuffer = null;
        }

        private function onContextCreated ( event : Object ) : void
        {
            destroyBuffers ();
        }
    }
}

import QFLib.Graphics.RenderCore.starling.core.StaticBuffers;

class SingletonHolder
{
    private static var _instance : StaticBuffers = new StaticBuffers ();

    public static function instance () : StaticBuffers { return _instance; }
}

