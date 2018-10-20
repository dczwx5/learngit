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

    public class TrailInstance extends BaseEffectInstance
    {
        private static const MAX_NODE_COUNT : int = 128;

        private var _trailNodes : CLoopList;

        public function TrailInstance ()
        {
            _vertices = new VertexData ( 0 );
            _indices = new Vector.<uint> ();
            _trailNodes = new CLoopList ( MAX_NODE_COUNT );
        }

        override public function dispose () : void
        {
            _trailNodes.dispose ();
            _trailNodes = null;

            super.dispose ();
        }

        override protected function _destroyBuffers() : void
        {
            _destroyVertextBufferEx ();
            _destroyIndexBufferEx ();
        }

        protected override function _updateMesh () : void
        {
            var trailNodes : CLoopList = _trailNodes;
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
                var tangent : CVector2 = new CVector2();
                var temp : CVector2;
                var p0 : CVector2, p1 : CVector2, p2 : CVector2;

                if ( i == 0 || index < 1 )
                {
                    p0 = node.position;
                    p1 = (trailNodes.getObject ( index - 1 ) as TrailNode).position;
                    temp = p0.sub(p1);
                    temp.normalize();
                    tangent.setValueXY( -temp.y, temp.x );
                }
                else
                {
                    p0 = (trailNodes.getObject ( index + 1 ) as TrailNode).position;
                    p1 = node.position;
                    p2 = (trailNodes.getObject ( index - 1 ) as TrailNode).position;

                    var dir : CVector2 = p0.sub(p1);
                    dir.normalize();
                    var lastDir : CVector2 = p1.sub(p2);
                    lastDir.normalize();

                    if ( dir.equals ( lastDir ) )
                    { tangent.setValueXY( -dir.y, dir.x ); }
                    else
                    {
                        temp = dir.add(lastDir);
                        temp.normalize();
                        tangent.setValueXY( -temp.y, temp.x );
                    }
                }

                //vertex position
                var s : Number = i * 1.0 / n;
                tangent.mulOnValue ( width );
                verticesRawData[ vIndex ] = node.position.x + tangent.x;
                verticesRawData[ vIndex + 1 ] = node.position.y + tangent.y;

                verticesRawData[ vIndex + 8 ] = node.position.x - tangent.x;
                verticesRawData[ vIndex + 9 ] = node.position.y - tangent.y;

                //vertex uv
                _setUV ( verticesRawData, vIndex + 6, s );

                //vertex color
                var color : uint = node.color;
                var red : Number = ( ( color >> 24 ) & 0xff ) / 255.0;
                var green : Number = ( ( color >> 16 ) & 0xff ) / 255.0;
                var blue : Number = ( ( color >> 8 ) & 0xff ) / 255.0;
                var alpha : Number = ( color & 0xff ) / 255.0;
                verticesRawData[ vIndex + 2 ] = verticesRawData[ vIndex + 10 ] = red;
                verticesRawData[ vIndex + 3 ] = verticesRawData[ vIndex + 11 ] = green;
                verticesRawData[ vIndex + 4 ] = verticesRawData[ vIndex + 12 ] = blue;
                verticesRawData[ vIndex + 5 ] = verticesRawData[ vIndex + 13 ] = alpha;

                if ( index == 1 )
                {
                    node = trailNodes.getObject ( 0 ) as TrailNode;
                    width = node.width * 0.5;

                    //vertex position
                    verticesRawData[ vIndex + 16 ] = verticesRawData[ vIndex ];
                    verticesRawData[ vIndex + 17 ] = verticesRawData[ vIndex + 1 ];

                    verticesRawData[ vIndex + 24 ] = verticesRawData[ vIndex + 8 ];
                    verticesRawData[ vIndex + 25 ] = verticesRawData[ vIndex + 9 ];

                    //vertex color
                    color = node.color;
                    red = ( ( color >> 24 ) & 0xff ) / 255.0;
                    green = ( ( color >> 16 ) & 0xff ) / 255.0;
                    blue = ( ( color >> 8 ) & 0xff ) / 255.0;
                    alpha = ( color & 0xff ) / 255.0;
                    verticesRawData[ vIndex + 18 ] = verticesRawData[ vIndex + 26 ] = red;
                    verticesRawData[ vIndex + 19 ] = verticesRawData[ vIndex + 27 ] = green;
                    verticesRawData[ vIndex + 20 ] = verticesRawData[ vIndex + 28 ] = blue;
                    verticesRawData[ vIndex + 21 ] = verticesRawData[ vIndex + 29 ] = alpha;

                    //vertex uv
                    _setUV ( verticesRawData, vIndex + 22, s );
                }
                else
                {
                    var iIndex : int = i * 6;
                    vIndex = i * 2;

                    _indices[ iIndex + 0 ] = vIndex + 0;
                    _indices[ iIndex + 1 ] = vIndex + 1;
                    _indices[ iIndex + 2 ] = vIndex + 2;
                    _indices[ iIndex + 3 ] = vIndex + 3;
                    _indices[ iIndex + 4 ] = vIndex + 2;
                    _indices[ iIndex + 5 ] = vIndex + 1;
                }
            }
        }

        protected override function _update ( deltaTime : Number ) : void
        {
            super._update( deltaTime );
            var pos : CVector2 = sVector2DHelper0;
            pos.x = this.worldTransform.tx;
            pos.y = this.worldTransform.ty;

            _addNode ( pos );

            var newHeadIndex : int;
            var node : TrailNode;
            for ( newHeadIndex = _trailNodes.count - 1; newHeadIndex >= 0; )
            {
                node = _trailNodes.getObject ( newHeadIndex ) as TrailNode;
                node.life -= deltaTime;

                if ( node.life <= 0 )
                    break;
                else
                    --newHeadIndex;
            }

            if ( newHeadIndex >= 0 )
                _trailNodes.pop ( newHeadIndex + 1 );

            var segment : int = _trailNodes.count - 1;

            var i : int = 0;
            var n : int = segment + 1;
            var factor : Number;
            var matrix : Matrix = this.worldTransform;
            var widthScaler : Number = Math.sqrt ( matrix.a * matrix.a + matrix.b * matrix.b );
            for ( ; i < n; ++i )
            {
                factor = 1.0 - i * 1.0 / segment;

                node = _trailNodes.getObject ( i ) as TrailNode;
                node.color = _keyFrame.getColor ( factor );
                node.width = _keyFrame.getSize ( factor ).y * widthScaler;
            }
        }

        protected override function _reset () : void
        {
            super._reset ();
            _trailNodes.clear ();
        }

        override protected function _render ( support : RenderSupport, alpha : Number ) : void
        {
            var trailNodes : CLoopList = _trailNodes;
            var nodeCount : int = trailNodes.count;
            if ( nodeCount <= 1 ) return;

            var pTex : Texture = _material.texture;
            if ( pTex == null || !pTex.uploaded || pTex.base == null )
                return;

            _updateMesh ();
            _syncBuffersEx ();

            if ( _indices == null || _usedNumTriangles < 1 ) return;

            var rcmd : RenderCommand = RenderCommand.assign ( sMatrixIdentity );
            rcmd.geometry = this;
            rcmd.material = _material.concreteMaterial;
            Starling.current.addToRender ( rcmd );
        }

        public function _addNode ( pos : CVector2 ) : void
        {
            var MINI_DISTANCE : Number = 10.0;
            var forcePush : Boolean = _trailNodes.count < 1;
            var node : TrailNode;

            if ( !forcePush )
            {
                node = _trailNodes.getObject ( _trailNodes.count - 1 ) as TrailNode;

                var temp : CVector2 = pos.sub( node.position );
                var distSQ : Number = temp.x*temp.x + temp.y*temp.y;
                if ( distSQ > MINI_DISTANCE )
                {
                    forcePush = true;
                }
                else
                {
                    node.position.set ( pos );
                    node.life = life;
                }
            }
            if ( forcePush )
            {
                node = new TrailNode ();
                node.position.set ( pos );
                node.life = life;
                _trailNodes.push ( node );
            }
        }

        private function _setUV ( verticeRawData : Vector.<Number>, index : int, s : Number ) : void
        {
            var offset : int = _material.getUVOffsetByIndexInUVList ();
            var uvList : Vector.<Number> = _material.uvList;
            var u : Number = 1.0;
            var v : Number = 1.0;

            if ( _material.rotation == EffectMaterial.NONE
                    || _material.rotation == EffectMaterial.ROT180 )
            {
                u = s * (uvList[ offset + 2 ] - uvList[ offset ]) + uvList[ offset ];

                verticeRawData[ index ] = u;
                verticeRawData[ index + 1 ] = uvList[ offset + 1 ];

                verticeRawData[ index + 8 ] = u;
                verticeRawData[ index + 9 ] = uvList[ offset + 5 ];
            }
            else
            {
                v = s * ( uvList[ offset + 3 ] - uvList[ offset + 1 ] ) + uvList[ offset + 1 ];

                verticeRawData[ index ] = uvList[ offset ];
                verticeRawData[ index + 1 ] = v;

                verticeRawData[ index + 8 ] = uvList[ offset + 4 ];
                verticeRawData[ index + 9 ] = v;
            }
        }
    }
}