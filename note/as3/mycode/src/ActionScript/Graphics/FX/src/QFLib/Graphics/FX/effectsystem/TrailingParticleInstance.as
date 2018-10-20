package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Foundation.CLoopList;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Math.CVector2;

    import flash.display3D.Context3DBufferUsage;

    import flash.geom.Matrix;

    public class TrailingParticleInstance extends BaseEffectInstance
    {
        private static const MAX_NODE_COUNT : int = 128;

        private var _loopList : CLoopList;
        private var _interval : Number;

        public function TrailingParticleInstance ()
        {
            _vertices = new VertexData ( 0 );
            _indices = new Vector.<uint> ();
            _loopList = new CLoopList ( MAX_NODE_COUNT );
        }

        public override function dispose () : void
        {
            _loopList.dispose ();
            _loopList = null;

            super.dispose ();
        }

        protected override function _loadFromObject ( data : Object ) : void
        {
            if ( checkObject ( data, "interval" ) )
            {
                _interval = data.interval;
            }
        }

        override protected function _destroyBuffers() : void
        {
            _destroyVertextBufferEx ();
            _destroyIndexBufferEx ();
        }

        protected override function _reset () : void
        {
            super._reset ();
            _loopList.clear ();
        }

        protected override function _updateMesh () : void
        {
            var trailNodes : CLoopList = _loopList;

            var nodeCount : int = trailNodes.count;
            if ( nodeCount <= 1 )
                return;

            _usedNumVertices = nodeCount * 2;
            if ( _usedNumVertices > _vertices.numVertices )
            {
                _vertices.numVertices = _usedNumVertices * 2;
                _vertexBufDirty = true;
            }

            var numIndices : int = (nodeCount - 1) * 6;
            _usedNumTriangles = (nodeCount - 1) * 2;
            if ( numIndices > _indices.length )
            {
                _indices.fixed = false;
                _indices.length = numIndices * 2;
                _indices.fixed = true;
                _indexBufDirty = true;
            }

            var verticesRawData : Vector.<Number> = _vertices.rawData;
            var node : TrailNode;
            for ( var i : int = 0, n : int = nodeCount - 1; i < n; ++i )
            {
                //从尾巴开始
                var index : int = n - i;
                var vIndex : int = i * 16;
                node = trailNodes.getObject ( index ) as TrailNode;

                var width : Number = node.width * 0.5;
                var tangent : CVector2;
                var dir : CVector2;
                var p0 : CVector2, p1 : CVector2;

                p0 = node.position;
                p1 = (trailNodes.getObject ( index - 1 ) as TrailNode).position;

                dir = p0.sub(p1);
                dir.normalize ();
                tangent.setValueXY( -dir.y, dir.x);

                var rightDown : CVector2, rightUp : CVector2, leftDown : CVector2, leftUp : CVector2;
                var pc1 : CVector2, pc2 : CVector2, pc3 : CVector2, pc4 : CVector2;

                rightDown = dir.add(tangent);
                rightUp = dir.sub(tangent);
                leftDown = rightUp.mulValue(-1);
                leftUp = rightDown.mulValue(-1);

                rightDown.addOn(p0);
                pc1 = rightDown;
                leftUp.addOn(p0);
                pc2 = leftUp;
                rightUp.addOn(p0);
                pc3 = rightUp;
                rightDown.addOn(p0);
                pc4 = rightDown;

                //vertex position
                verticesRawData[ vIndex ] = pc1.x;
                verticesRawData[ vIndex + 1 ] = pc1.y;

                verticesRawData[ vIndex + 8 ] = pc2.x;
                verticesRawData[ vIndex + 9 ] = pc2.y;

                verticesRawData[ vIndex + 16 ] = pc3.x;
                verticesRawData[ vIndex + 17 ] = pc3.y;

                verticesRawData[ vIndex + 24 ] = pc4.x;
                verticesRawData[ vIndex + 25 ] = pc4.y;

                //vertex color
                var color : uint = node.color;
                var red : Number = ( ( color >> 24 ) & 0xff ) / 255.0;
                var green : Number = ( ( color >> 16 ) & 0xff ) / 255.0;
                var blue : Number = ( ( color >> 8 ) & 0xff ) / 255.0;
                var alpha : Number = ( color & 0xff ) / 255.0;
                verticesRawData[ vIndex + 2 ] = verticesRawData[ vIndex + 10 ] = verticesRawData[ vIndex + 18 ] = verticesRawData[ vIndex + 26 ] = red;
                verticesRawData[ vIndex + 3 ] = verticesRawData[ vIndex + 11 ] = verticesRawData[ vIndex + 19 ] = verticesRawData[ vIndex + 27 ] = green;
                verticesRawData[ vIndex + 4 ] = verticesRawData[ vIndex + 12 ] = verticesRawData[ vIndex + 20 ] = verticesRawData[ vIndex + 28 ] = blue;
                verticesRawData[ vIndex + 5 ] = verticesRawData[ vIndex + 13 ] = verticesRawData[ vIndex + 21 ] = verticesRawData[ vIndex + 29 ] = alpha;

                //vertex uv
                _setUV ( verticesRawData, index + 6 );

                //index
                var iIndex : int = i * 6;
                _indices[ iIndex + 0 ] = vIndex + 0;
                _indices[ iIndex + 1 ] = vIndex + 1;
                _indices[ iIndex + 2 ] = vIndex + 3;
                _indices[ iIndex + 3 ] = vIndex + 3;
                _indices[ iIndex + 4 ] = vIndex + 2;
                _indices[ iIndex + 5 ] = vIndex + 1;
            }
        }

        protected override function _update ( deltaTime : Number ) : void
        {
            super._update( deltaTime );
            _currentLife += deltaTime;

            var pos : CVector2 = sVector2DHelper0;
            pos.x = worldTransform.tx;
            pos.y = worldTransform.ty;
            _addNode ( pos );

            var newHeadIndex : int = 0;
            var node : TrailNode;
            for ( newHeadIndex = _loopList.count - 1; newHeadIndex >= 0; )
            {
                node = _loopList.getObject ( newHeadIndex ) as TrailNode;
                node.life -= deltaTime;

                if ( node.life <= 0 )
                    break;
                else
                    --newHeadIndex;
            }

            if ( newHeadIndex >= 0 )
                _loopList.pop ( newHeadIndex + 1 );

            var segment : int = _loopList.count - 1;

            var i : int = 0;
            var n : int = segment + 1;
            var factor : Number;
            var matrix : Matrix = this.worldTransform;
            var widthScaler : Number = Math.sqrt ( matrix.a * matrix.a + matrix.b * matrix.b );
            for ( ; i < n; ++i )
            {
                factor = 1.0 - i * 1.0 / segment;

                node = _loopList.getObject ( i ) as TrailNode;
                node.color = _keyFrame.getColor ( factor );
                node.width = _keyFrame.getSize ( factor ).y * widthScaler;
            }
        }

        override protected function _render ( support : RenderSupport, alpha : Number ) : void
        {
            var pTex : Texture = _material.texture;
            if ( pTex == null || !pTex.uploaded || pTex.base == null )
                return;

            _updateMesh ();
            _syncBuffersEx ();

            var rcmd : RenderCommand = RenderCommand.assign ( worldTransform );
            rcmd.geometry = this;
            rcmd.material = _material.concreteMaterial;
            Starling.current.addToRender ( rcmd );
        }

        private function _addNode ( pos : CVector2 ) : void
        {
            var forcePush : Boolean = _loopList.count < 1;
            var node : TrailNode;

            if ( !forcePush )
            {
                node = _loopList.getObject ( _loopList.count - 1 ) as TrailNode;
                if ( _currentLife >= _interval )
                {
                    _currentLife = 0.0;
                    forcePush = true;
                }
                else
                {
                    node.position.set ( pos );
                    node.life = _life;
                }
            }

            if ( forcePush )
            {
                node = new TrailNode ();
                node.position.set ( pos );
                node.life = _life;
                _loopList.push ( node );
            }

        }

        private function _setUV ( verticesRawData : Vector.<Number>, index : int ) : void
        {
            var offset : int = _material.getUVOffsetByIndexInUVList ();
            var uvList : Vector.<Number> = _material.uvList;
            verticesRawData[ index ] = uvList[ offset ];
            verticesRawData[ index + 1 ] = uvList[ offset + 1 ];

            verticesRawData[ index + 8 ] = uvList[ offset + 2 ];
            verticesRawData[ index + 9 ] = uvList[ offset + 3 ];

            verticesRawData[ index + 16 ] = uvList[ offset + 4 ];
            verticesRawData[ index + 17 ] = uvList[ offset + 5 ];

            verticesRawData[ index + 24 ] = uvList[ offset + 6 ];
            verticesRawData[ index + 25 ] = uvList[ offset + 7 ];
        }
    }
}
