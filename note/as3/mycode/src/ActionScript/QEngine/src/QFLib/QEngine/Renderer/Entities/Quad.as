/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/24.
 */
package QFLib.QEngine.Renderer.Entities
{
    import QFLib.Math.CVector2;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Materials.MSprite;
    import QFLib.QEngine.Renderer.Utils.Color;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    public class Quad extends Entity
    {
        /**
         *
         * @param parentNode
         * @param color
         * @param alpha
         * @param width
         * @param height
         */
        public function Quad( parentNode : SceneNode, color : uint = Color.RED, alpha : Number = 1.0, width : Number = 1.0, height : Number = 1.0,
                              pma : Boolean = false )
        {
            m_bPremultiplyAlpha = pma;
            super( parentNode );

            this.color = color;
            this.alpha = alpha;
            this.width = width;
            this.height = height;
        }
        private var m_Material : IMaterial = null;
        private var m_Indices : Vector.<uint> = null;
        private var m_Pivot : CVector2 = CVector2.zero();
        private var m_Alpha : Number = 1.0;
        private var m_fWidth : Number = 0.0;
        private var m_fHeight : Number = 0.0;
        private var m_Color : uint = Color.RED;
        private var m_PivotDirty : Boolean = false;
        private var m_bPremultiplyAlpha : Boolean = false;

        override public function get color() : uint
        { return m_Color; }

        override public function set color( value : uint ) : void
        {
            m_Color = value;
            if( m_Vertices != null )
            {
                m_Vertices.setColor( value );
            }
        }

        override public function get alpha() : Number
        { return m_Alpha; }

        override public function set alpha( value : Number ) : void
        {
            m_Alpha = value;
            if( m_Vertices != null )
            {
                m_Vertices.setAlpha( m_Alpha );
            }
        }

        [Inline]
        final public function get width() : Number
        { return m_fWidth; }

        public function set width( value : Number ) : void
        {
            if( m_fWidth == value ) return;

            m_fWidth = value;
            var xVal : Number = m_fWidth * 0.5;
            var yVal : Number = m_fHeight * 0.5;

            m_Vertices.setPosition( 0, -xVal, -yVal, 0 );
            m_Vertices.setPosition( 1, xVal, -yVal, 0 );
            m_Vertices.setPosition( 2, xVal, yVal, 0 );
            m_Vertices.setPosition( 3, -xVal, yVal, 0 );
        }

        [Inline]
        final public function get height() : Number
        { return m_fHeight; }

        public function set height( value : Number ) : void
        {
            if( m_fHeight == value ) return;

            m_fHeight = value;
            var xVal : Number = m_fWidth * 0.5;
            var yVal : Number = m_fHeight * 0.5;
            m_Vertices.setPosition( 0, -xVal, -yVal, 0 );
            m_Vertices.setPosition( 1, xVal, -yVal, 0 );
            m_Vertices.setPosition( 2, xVal, yVal, 0 );
            m_Vertices.setPosition( 3, -xVal, yVal, 0 );
        }

        [Inline]
        final public function get pivot() : CVector2
        { return m_Pivot; }

        [Inline]
        final public function set pivot( value : CVector2 ) : void
        {
            m_PivotDirty = ( m_Pivot.x != value.x || m_Pivot.y != value.y );
            if( m_PivotDirty )
            {
                m_Pivot.x = value.x;
                m_Pivot.y = value.y;

//                var deltaX : Number = m_Pivot.x, deltaY : Number = m_Pivot.y;
//                m_pQuadRenderer.translateVertex ( 0, )
            }
        }

        [Inline]
        final public function get premultiplyAlpha() : Boolean
        { return m_bPremultiplyAlpha; }

        [Inline]
        final public function set premultiplyAlpha( value : Boolean ) : void
        {
            if( m_bPremultiplyAlpha != value )
            {
                m_bPremultiplyAlpha = value;
                m_Mesh.setPremultilyAlpha( value );
            }
        }

        override public function dispose() : void
        {
            m_Pivot = null;
            super.dispose();
        }

        override protected function initializeEntity() : void
        {
            super.initializeEntity();

            m_Material = new MSprite();
            m_Vertices = new VertexData( 4, m_bPremultiplyAlpha, true );
            m_Indices = new <uint>[ 0, 2, 1, 0, 3, 2 ];

            m_Mesh = new Mesh( this );
            var pSubMesh : SubMesh = m_Mesh.createSubMesh( 4, m_bPremultiplyAlpha, m_Indices, 0, m_Vertices, 2, true );
            m_Mesh.setSubMeshTriangles( 0, m_Indices );

            createSubEntity( pSubMesh, "Quad" );
            setSubEntityMaterial( 0, m_Material );
        }

        override protected function destroyEntity() : void
        {
            if( m_Material != null )
            {
                m_Material.dispose();
                m_Material = null;
            }
            super.destroyEntity();
        }
    }
}