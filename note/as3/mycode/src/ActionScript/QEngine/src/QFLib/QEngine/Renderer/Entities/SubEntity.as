/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/17.
 */
package QFLib.QEngine.Renderer.Entities
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Renderer.IRenderCommand;
    import QFLib.QEngine.Renderer.IRenderable;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Core.Engine_Internal;

    public class SubEntity implements IRenderable, IDisposable
    {
        public function SubEntity( pOwner : Entity, pSubMesh : SubMesh, name : String = "SubEntity" )
        {
            m_strName = name;
            m_pOwnerEntity = pOwner;
            m_pSubMesh = pSubMesh;
        }
        private var m_strName : String = "SubEntity";
        private var m_pOwnerEntity : Entity = null;
        private var m_pSubMesh : SubMesh = null;
        private var m_iIndex : int = -1;
        private var m_bVisible : Boolean = true;

        [Inline]
        final public function get name() : String
        { return m_strName; }

        [Inline]
        final public function set name( value : String ) : void
        { m_strName = value; }

        [Inline]
        final public function get visible() : Boolean
        { return m_bVisible; }

        [Inline]
        final public function set visible( value : Boolean ) : void
        { m_bVisible = value; }

        public function dispose() : void
        {
            m_pOwnerEntity = null;
            m_pSubMesh = null;
        }

        public function getRenderCommand( cmd : IRenderCommand ) : void
        {
            cmd.worldMatrix = m_pOwnerEntity.getWorldMatrix();
            m_pSubMesh.Engine_Internal::_getRenderCommand( cmd );
        }

        [Inline]
        final Engine_Internal function get index() : int
        { return m_iIndex; }

        [Inline]
        final Engine_Internal function set index( value : int ) : void
        { m_iIndex = value; }

        [Inline]
        final Engine_Internal function getSubMesh() : SubMesh
        { return m_pSubMesh; }

        [Inline]
        final Engine_Internal function setSubMesh( pSubMesh : SubMesh ) : void
        { m_pSubMesh = pSubMesh; }

        Engine_Internal function _setMaterial( value : IMaterial, useSharedMaterial : Boolean = true ) : void
        {
            if( useSharedMaterial ) m_pSubMesh.Engine_Internal::_sharedMaterial = value;
            else m_pSubMesh.Engine_Internal::_material = value;
        }

        Engine_Internal function _setTintColorWithAlpha( red : Number, green : Number, blue : Number, alpha : Number ) : void
        {
            m_pSubMesh.Engine_Internal::_sharedMaterial.setTintColorWithAlpha( red, green, blue, alpha );
        }
    }
}
