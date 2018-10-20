/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/1.
 */
package QFLib.QEngine.Renderer.Entities
{
    import QFLib.Foundation.CMap;
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CMatrix4;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.RenderQueue.RenderCommandPool;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueueGroup;
    import QFLib.QEngine.Renderer.Utils.Color;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    public class Entity extends MovableObject implements IDisposable
    {
        public function Entity( pParentNode : SceneNode )
        {
            super( pParentNode );
            initializeEntity();
        }
        protected var m_Mesh : Mesh = null;
        protected var m_vecSubEntities : Vector.<SubEntity> = null;
        protected var m_mapSubEntityNames : CMap = null;
        protected var m_Vertices : VertexData = null;
        protected var m_fAlpha : Number = 1.0;
        protected var m_uColor : uint = Color.WHITE;
        protected var m_fRed : Number = 1.0;
        protected var m_fGreen : Number = 1.0;
        protected var m_fBlue : Number = 1.0;
        protected var m_bAlphaDirty : Boolean = true;
        protected var m_bColorDirty : Boolean = true;
        protected var m_Visible : Boolean = true;

        override public function get visible() : Boolean
        { return m_Visible; }

        override public function set visible( value : Boolean ) : void
        { m_Visible = value; }

        override public function get color() : uint
        { return m_uColor; }

        override public function set color( value : uint ) : void
        {
            if( m_uColor != value )
            {
                m_fRed = ( m_uColor & 0xff0000 ) >> 16;
                m_fGreen = ( m_uColor & 0x00ff00 ) >> 8;
                m_fBlue = ( m_uColor & 0x0000ff );

                m_uColor = value;
                m_bColorDirty = true;
            }
        }

        override public function get alpha() : Number
        { return m_fAlpha; }

        override public function set alpha( value : Number ) : void
        {
            if( m_fAlpha != value )
            {
                m_fAlpha = value;
                m_bAlphaDirty = true;
            }
        }

        override public function dispose() : void
        {
            destroyEntity();
            super.dispose();
        }

        /**
         *
         * @param red  0.0 - 1.0
         * @param green  0.0 - 1.0
         * @param blue  0.0 - 1.0
         * @param alpha  0.0 - 1.0
         */
        override public function setColorWithAlpha( red : Number, green : Number, blue : Number, alpha : Number ) : void
        {
            var uColor : uint = Color.rgb( red * 255, green * 255, blue * 255 );
            this.color = uColor;
            this.alpha = alpha;
        }

        override public function updateRenderQueueGroup( pGroup : RenderQueueGroup, pCamera : Camera ) : void
        {
            if( m_Visible )
            {
                var len : int = m_vecSubEntities.length;
                var pRCmd : IRenderCommand = null;
                var pSubEntity : SubEntity = null;
                for( var i : int = 0; i < len; i++ )
                {
                    pSubEntity = m_vecSubEntities[ i ];
                    if( pSubEntity != null && pSubEntity.visible )
                    {
                        pRCmd = RenderCommandPool.getRenderCommand();
                        pSubEntity.getRenderCommand( pRCmd );
                        pGroup.addRenderCommand( pRCmd, pCamera );
                    }
                }
            }
        }

        override public function update( deltaTime : Number ) : void
        {
            if( !m_Enable ) return;
            super.update( deltaTime );
        }

        public function getWorldMatrix() : CMatrix4
        { return m_pParentNode.transform.worldMatrix; }

        public function createSubEntity( pSubMesh : SubMesh, name : String = "SubEntity" ) : SubEntity
        {
            var len : int = m_vecSubEntities.length;
            if( name == "SubEntity" ) name = name + "_" + len;
            var subEntity : SubEntity = new SubEntity( this, pSubMesh, name );
            addSubEntity( subEntity );
            return subEntity;
        }

        public function addSubEntity( pSubEntity : SubEntity ) : void
        {
            var len : int = m_vecSubEntities.length;
            m_vecSubEntities.fixed = false;
            m_vecSubEntities.length += 1;
            m_vecSubEntities.fixed = true;
            m_vecSubEntities[ len ] = pSubEntity;
            var index : int = pSubEntity.Engine_Internal::index = len + 1;

            m_mapSubEntityNames.add( pSubEntity.name, index )
        }

        public function deleteSubEntitty( pSubEntity : SubEntity ) : void
        { m_vecSubEntities[ pSubEntity.Engine_Internal::index - 1 ] = null; }

        public function findSubEntity( name : String ) : SubEntity
        {
            if( m_mapSubEntityNames.count == 0 ) return null;
            var index : int = m_mapSubEntityNames.find( name );
            if( index <= 0 ) return null;

            var len : int = m_vecSubEntities.length;
            if( len == 0 || index > len ) return null;
            return m_vecSubEntities[ index - 1 ];
        }

        public function setSubEntityMaterial( index : int, material : IMaterial, useSharedMaterial : Boolean = true ) : void
        {
            if( m_vecSubEntities != null && index < m_vecSubEntities.length )
                m_vecSubEntities[ index ].Engine_Internal::_setMaterial( material, useSharedMaterial );
        }

        protected function initializeEntity() : void
        {
            m_mapSubEntityNames = new CMap();
            m_vecSubEntities = new Vector.<SubEntity>();
        }

        protected function destroyEntity() : void
        {
            if( m_vecSubEntities != null )
            {
                var len : int = m_vecSubEntities.length;
                for( var i : int = 0; i < len; i++ )
                {
                    m_vecSubEntities[ i ].dispose();
                }

                m_vecSubEntities.fixed = false;
                m_vecSubEntities.length = 0;
                m_vecSubEntities = null;
            }
            if( m_mapSubEntityNames != null )
            {
                m_mapSubEntityNames.clear();
                m_mapSubEntityNames = null;
            }

            if( m_Mesh != null )
            {
                m_Mesh.dispose();
                m_Mesh = null;
            }

            if( m_Vertices != null )
            {
                m_Vertices.dispose();
                m_Vertices = null;
            }
        }

        Engine_Internal function get mesh() : Mesh { return m_Mesh; }
    }
}