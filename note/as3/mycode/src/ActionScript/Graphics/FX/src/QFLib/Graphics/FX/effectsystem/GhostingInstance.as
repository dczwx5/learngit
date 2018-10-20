/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/9.
 */
package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.FX.utils.LoopPoolList;
    import QFLib.Graphics.FX.utils.Snapshot;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Math.CVector2;

    import flash.geom.Rectangle;

    public class GhostingInstance extends BaseEffectInstance
    {
        private static const MAX_NODE_COUNT : int = 10;
        private static const sVectorHelper : CVector2 = new CVector2 ( 0.0, 0.0 );

        private var m_nodes : LoopPoolList = new LoopPoolList ( MAX_NODE_COUNT, _createNode, null, _unuseNode );
        private var m_emitInterval : Number = 1.0;
        private var m_passTimeFromLast : Number = 0.0;
        private var m_nodeLife : Number = 1.0;
        private var m_theTarget : IFXModify = null;
        private var m_snapshot : Snapshot = new Snapshot ();

        public function GhostingInstance ()
        {}

        public override function dispose () : void
        {
            if ( m_nodes != null )
                m_nodes.dispose ();
            m_nodes = null;

            m_theTarget = null;

            if ( m_snapshot != null )
                m_snapshot.dispose ();
            m_snapshot = null;

            super.dispose ();
        }

        [Inline]
        public override function attachToTarget ( target : IFXModify ) : void { m_theTarget = target; }

        [Inline]
        public override function detachFromTarget () : void { m_theTarget = null; }

        public override function get isDead():Boolean {
            if(_loop && _time > life){
                reset();
            }
            return _time > life;
        }

        [Inline]
        public function get nodes () : LoopPoolList { return m_nodes; }

        protected override function _updateMesh () : void
        {
            var i : int;
            var count : int = m_nodes.count;

            if ( count == 0 )return;

            var vertexRawData : Vector.<Number> = null;
            var flipX : Boolean = this.worldScaleX < 0;
            var worldScaleX : Number = Math.abs( this.worldScaleX );
            var worldScaleY : Number = Math.abs( this.worldScaleY );
            var swapVal : Number = 0.0;
            for ( i = 0; i < count; ++i )
            {
                var node : GhostingNode = m_nodes.getObject ( i ) as GhostingNode;
                var texture : Texture = node.texture;
                if ( texture == null ) continue;

                var rect : Rectangle = node.rect;
                var pos : CVector2 = node.position;
                var right_u : Number = rect.width / texture.width;
                var bottom_v : Number = rect.height / texture.height;
                var left : Number = rect.left * node.scale.x;
                var top : Number = rect.top * node.scale.y * worldScaleY;
                var right : Number = rect.right * node.scale.x;
                var bottom : Number = rect.bottom * node.scale.y * worldScaleY;

                if ( flipX )
                {
                    swapVal = -left;
                    left = -right * worldScaleX;
                    right = swapVal * worldScaleX;
                }

                vertexRawData = node.vertices.rawData;

                //update vertex position
                vertexRawData[ 0 ] = left + pos.x;
                vertexRawData[ 1 ] = top + pos.y;

                vertexRawData[ 8 ] = right + pos.x;
                vertexRawData[ 9 ] = top + pos.y;

                vertexRawData[ 16 ] = right + pos.x;
                vertexRawData[ 17 ] = bottom + pos.y;

                vertexRawData[ 24 ] = left + pos.x;
                vertexRawData[ 25 ] = bottom + pos.y;

                //update vertex color
                var color : uint = node.color;
                var alpha : Number = ( color & 0xFF ) / 255.0;
                color = ( color >> 8 ) & 0x00FFFFFF;
                node.vertices.setColorAndAlpha ( 0, color, alpha );
                node.vertices.setColorAndAlpha ( 1, color, alpha );
                node.vertices.setColorAndAlpha ( 2, color, alpha );
                node.vertices.setColorAndAlpha ( 3, color, alpha );

                //vertex uv
                if ( !flipX )
                {
                    vertexRawData[ 6 ] = 0.0;
                    vertexRawData[ 7 ] = 0.0;

                    vertexRawData[ 14 ] = right_u;
                    vertexRawData[ 15 ] = 0.0;

                    vertexRawData[ 22 ] = right_u;
                    vertexRawData[ 23 ] = bottom_v;

                    vertexRawData[ 30 ] = 0.0;
                    vertexRawData[ 31 ] = bottom_v;
                }
                else
                {
                    vertexRawData[ 6 ] = right_u;
                    vertexRawData[ 7 ] = 0.0;

                    vertexRawData[ 14 ] = 0.0;
                    vertexRawData[ 15 ] = 0.0;

                    vertexRawData[ 22 ] = 0.0;
                    vertexRawData[ 23 ] = bottom_v;

                    vertexRawData[ 30 ] = right_u;
                    vertexRawData[ 31 ] = bottom_v;
                }
            }
        }

        protected override function _update ( deltaTime : Number ) : void
        {
            super._update( deltaTime );
            var nodes : LoopPoolList = m_nodes;
            var i : int;
            var node : GhostingNode;
            for ( i = nodes.count - 1; i >= 0; )
            {
                node = nodes.getObject ( i ) as GhostingNode;
                node.life -= deltaTime;
                if ( node.life < 0 )
                {
                    break;
                }
                else
                    --i;
            }

            if ( i >= 0 )
            {
                nodes.pop ( i + 1 );
            }

            m_passTimeFromLast += deltaTime;
            if(m_theTarget == null)return;

            var generateCount : uint = 0;
            if ( m_emitInterval != 0.0 && m_passTimeFromLast >= m_emitInterval )
            {
                generateCount = (int)(m_passTimeFromLast / m_emitInterval);
                m_passTimeFromLast %= m_emitInterval;
            }

            while ( generateCount > 0 )
            {
                var posHelper : CVector2 = sVectorHelper;
                posHelper.x = this.worldTransform.tx;
                posHelper.y = this.worldTransform.ty;
                _addNode ( posHelper );
                --generateCount;
            }

            var l : int;
            for ( i = 0, l = nodes.count; i < l; ++i )
            {
                node = nodes.getObject ( i ) as GhostingNode;
                node.color = _keyFrame.getColor ( node.normalLife );
            }
        }

        protected override function _render ( support : RenderSupport, alpha : Number ) : void
        {
            _updateMesh ();

            var node : GhostingNode = null;
            var pTex : Texture = null;
            for ( var i : int = 0, count : int = m_nodes.count; i < count; i++ )
            {
                node = m_nodes.getObject( i ) as GhostingNode;
                if ( node == null )
                    continue;

                pTex = node.texture;
                if ( pTex == null || pTex.base == null )
                    continue;

                //XXX:填坑取巧，后面需改进，仍然会丢失部分的材质信息
                _material.texture = node.texture;
                _material.concreteMaterial.mainTexture = null;

                _vertices = node.vertices;
                _syncBuffers ();

                var rcmd : RenderCommand = RenderCommand.assign ( sMatrixIdentity );
                rcmd.geometry = this;
                rcmd.mainTexture = node.texture;
                rcmd.material = _material.concreteMaterial;
                Starling.current.addToRender ( rcmd );
            }
        }

        protected override function _reset () : void
        {
            m_nodes.clear ();
            m_passTimeFromLast = m_emitInterval;
        }

        protected override function _loadFromObject ( data : Object ) : void
        {
            if ( checkObject ( data, "emitRate" ) )
                _setEmitRate ( data.emitRate );
            if ( checkObject ( data, "nodeLife" ) )
                m_nodeLife = data.nodeLife;

            //ghosting effect don't exit bound, so here set bound to null.
            //_bound = null;

            _enable = true;
            if ( _onEffectLoadFunc != null )
                _onEffectLoadFunc ();
        }

        private function _addNode ( pos : CVector2 ) : void
        {
            if ( m_theTarget != null )
            {
                var node : GhostingNode = m_nodes.push () as GhostingNode;
                node.maxLife = m_nodeLife;
                node.life = m_nodeLife;
                node.position.setValueXY(pos.x,pos.y);
                node.snapshot ( m_theTarget.renderableObject );
            }
        }

        private function _createNode () : GhostingNode { return new GhostingNode ( m_snapshot ); }

        private function _unuseNode ( node : GhostingNode ) : void { node.unuse (); }

        private function _getEmitRate () : Number
        {
            if ( m_emitInterval == 0.0 )return 0;
            else return 1 / m_emitInterval;
        }

        private function _setEmitRate ( newEmitRate : Number ) : void
        {
            if ( newEmitRate <= 0 )m_emitInterval = 0.0;
            else m_emitInterval = 1 / newEmitRate;

            m_passTimeFromLast = m_emitInterval;
        }
    }
}
