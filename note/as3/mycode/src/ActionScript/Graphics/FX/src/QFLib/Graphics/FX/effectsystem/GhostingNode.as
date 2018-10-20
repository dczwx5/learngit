/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/8.
 */
package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Graphics.FX.utils.Snapshot;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CVector2;

    import flash.geom.Rectangle;

    public final class GhostingNode implements IDisposable
    {
        public var rect : Rectangle = new Rectangle ();
        public var color : uint = 0xFFFFFFFF;
        public var position : CVector2 = CVector2.zero();
        public var scale : CVector2 = CVector2.one();

        private var m_Vertices : VertexData = new VertexData ( 4 );

        private var m_pRenderTexture : Texture;
        private var m_NormalLife : Number = 1.0;
        private var m_Life : Number = 1.0;
        private var m_MaxLife : Number = 1.0;
        private var m_Snapshot : Snapshot;

        public function GhostingNode ( snapshot : Snapshot )
        {
            m_Snapshot = snapshot;
        }

        public function dispose () : void
        {
            if ( m_pRenderTexture != null )
            {
                m_Snapshot.recycleTexture ( m_pRenderTexture );
                m_pRenderTexture = null;
            }
            m_Snapshot = null;

            if ( m_Vertices != null )
            {
                m_Vertices.dispose();
                m_Vertices = null;
            }
        }

        public function snapshot ( theTarget : DisplayObject ) : void
        {
            var snapshot : Snapshot = m_Snapshot;
            if ( m_pRenderTexture != null )
                snapshot.recycleTexture ( m_pRenderTexture );

            if ( snapshot.snapshotDisplayObject ( theTarget ) )
            {
                m_pRenderTexture = snapshot.currentRT;
                rect.copyFrom ( snapshot.currentRect );
                scale.set ( snapshot.currentScale )
            }
            else
            {
                m_pRenderTexture = null;
            }
        }

        public function unuse () : void
        {
            if ( m_pRenderTexture != null )
            {
                m_Snapshot.recycleTexture ( m_pRenderTexture );
                m_pRenderTexture = null;
            }
        }

        [Inline]
        final public function get vertices () : VertexData { return m_Vertices; }
        [Inline]
        final public function get texture () : Texture { return m_pRenderTexture; }

        [Inline]
        final public function get life () : Number { return m_Life; }
        public function set life ( value : Number ) : void
        {
            m_Life = value;
            m_NormalLife = 1.0 - m_Life / m_MaxLife;
        }

        [Inline]
        final public function get maxLife () : Number { return m_MaxLife; }
        public function set maxLife ( value : Number ) : void
        {
            m_MaxLife = value;
            m_NormalLife = 1.0 - m_Life / m_MaxLife;
        }

        [Inline]
        final public function get normalLife () : Number { return m_NormalLife; }
    }
}
