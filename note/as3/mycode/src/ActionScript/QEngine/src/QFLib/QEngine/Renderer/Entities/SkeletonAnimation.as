/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/15.
 */
package QFLib.QEngine.Renderer.Entities
{
    import QFLib.Foundation;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.Entities.SpineExtension.MeshAttachmentExt;
    import QFLib.QEngine.Renderer.Entities.SpineExtension.RegionAttachmentExt;
    import QFLib.QEngine.Renderer.Entities.SpineExtension.RendererObject;
    import QFLib.QEngine.Renderer.Entities.SpineExtension.SkinedMeshAttachmentExt;
    import QFLib.QEngine.Renderer.IRenderCommand;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Materials.MSprite;
    import QFLib.QEngine.Renderer.RenderQueue.RenderCommandPool;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueueGroup;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Renderer.Utils.VertexData;
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;
    import QFLib.QEngine.ThirdParty.Spine.SkeletonData;
    import QFLib.QEngine.ThirdParty.Spine.Slot;
    import QFLib.QEngine.ThirdParty.Spine.animation.AnimationState;
    import QFLib.QEngine.ThirdParty.Spine.animation.AnimationStateData;
    import QFLib.QEngine.ThirdParty.Spine.attachments.Attachment;
    import QFLib.QEngine.ThirdParty.Spine.attachments.MeshAttachment;
    import QFLib.QEngine.ThirdParty.Spine.attachments.RegionAttachment;
    import QFLib.QEngine.ThirdParty.Spine.attachments.WeightedMeshAttachment;

    import flash.geom.Rectangle;

    public class SkeletonAnimation extends Entity
    {
        private static var sTempVertices : Vector.<Number> = new Vector.<Number>( 8 );

        private static function updateVertices( x : Number, y : Number, pSlot : Slot, pSubMesh : SubMesh ) : void
        {
            var pSharedVertices : VertexData = pSubMesh.Engine_Internal::_vertices;
            var pAttachment : Attachment = pSlot.attachment;
            var pRegionAttachment : RegionAttachmentExt = pAttachment as RegionAttachmentExt;
            if( pRegionAttachment != null )
            {
                pRegionAttachment.computeWorldVertexData( x, y, pSlot.bone, pSharedVertices );
                return;
            }

            var pMeshAttachment : MeshAttachmentExt = pAttachment as MeshAttachmentExt;
            if( pMeshAttachment != null )
            {
                pMeshAttachment.computeWorldVertexData( x, y, pSlot, pSharedVertices );
                return;
            }

            var pSkinedMeshAttachment : SkinedMeshAttachmentExt = pAttachment as SkinedMeshAttachmentExt;
            if( pSkinedMeshAttachment != null )
            {
                pSkinedMeshAttachment.computeWorldVertexData( x, y, pSlot, pSharedVertices );
            }
        }

        public function SkeletonAnimation( parentNode : SceneNode, skeletonData : SkeletonData,
                                           stateData : AnimationStateData = null )
        {
            m_AnimationStateData = stateData != null ? stateData : new AnimationStateData( skeletonData );
            Bone.yDown = true;

            m_Skeleton = new Skeleton( skeletonData );
            m_Skeleton.updateWorldTransform();

            m_AnimationState = new AnimationState( m_AnimationStateData );

            m_vecRendererObject = new Vector.<RendererObject>();
            m_vecDrawSubEntity = new Vector.<SubEntity>();

            super( parentNode );
        }
        private var m_vecRendererObject : Vector.<RendererObject> = null;
        private var m_vecDrawSubEntity : Vector.<SubEntity> = null;
        private var m_Material : IMaterial = null;
        private var m_Skeleton : Skeleton;
        private var m_AnimationState : AnimationState;
        private var m_AnimationStateData : AnimationStateData;
        private var m_strName : String = null;
        private var m_fTimeScale : Number = 1.0;
        private var m_iDrawCount : int = 0;
        private var m_bNeedBatch : Boolean = true;

        [Inline]
        final public function get name() : String
        { return m_strName; }

        [Inline]
        final public function set name( value : String ) : void
        { m_strName = value; }

        [Inline]
        final public function get skeleton() : Skeleton
        { return m_Skeleton; }

        [Inline]
        final public function get state() : AnimationState
        { return m_AnimationState }

        [Inline]
        final public function get stateData() : AnimationStateData
        { return m_AnimationStateData; }

        override public function dispose() : void
        {
            m_AnimationStateData = null;
            m_Skeleton = null;
            m_AnimationState = null;

            if( m_vecRendererObject != null )
            {
                for each ( var rendererObject : RendererObject in m_vecRendererObject )
                {
                    rendererObject.dispose();
                    rendererObject = null;
                }
                m_vecRendererObject.fixed = false;
                m_vecRendererObject.length = 0;
                m_vecRendererObject = null;
            }

            if( m_vecDrawSubEntity != null )
            {
                m_vecDrawSubEntity.fixed = false;
                m_vecDrawSubEntity.length = 0;
                m_vecDrawSubEntity = null;
            }

            super.dispose();
        }

        override public function updateRenderQueueGroup( pGroup : RenderQueueGroup, pCamera : Camera ) : void
        {
            clearDrawSubEntities();
            updateSkeletonAnimation();

            if( m_Visible )
            {
                var pRCmd : IRenderCommand = null;
                var pSubEntity : SubEntity = null;
                for( var i : int = 0; i < m_iDrawCount; i++ )
                {
                    pSubEntity = m_vecDrawSubEntity[ i ];
                    if( pSubEntity != null && pSubEntity.visible )
                    {
                        pRCmd = RenderCommandPool.getRenderCommand();
                        pSubEntity.getRenderCommand( pRCmd );
                        pGroup.addRenderCommand( pRCmd, pCamera );
                    }
                }
            }
        }

        override protected function initializeEntity() : void
        {
            super.initializeEntity();

            m_Vertices = new VertexData( 0, false, true );
            m_Material = new MSprite();
            m_Mesh = new Mesh( this );
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

        public function advanceTime( time : Number, bApplySkeleton : Boolean = false ) : void
        {
            time *= m_fTimeScale;
            skeleton.update( time );
            state.update( time );
            if( bApplySkeleton ) state.apply( skeleton );
            skeleton.updateWorldTransform();
        }

        public function calcBounds( resultRect : Rectangle ) : Rectangle
        {
            if( resultRect == null )
            {
                resultRect = new Rectangle();
            }

            var minX : Number = Number.MAX_VALUE, minY : Number = Number.MAX_VALUE;
            var maxX : Number = Number.MIN_VALUE, maxY : Number = Number.MIN_VALUE;
            var slots : Vector.<Slot> = skeleton.slots;
            var worldVertices : Vector.<Number> = sTempVertices;
            for( var i : int = 0, n : int = slots.length; i < n; ++i )
            {
                var slot : Slot = slots[ i ];
                var attachment : Attachment = slot.attachment;
                if( !attachment ) continue;
                var verticesLength : int;
                if( attachment is RegionAttachment )
                {
                    var region : RegionAttachment = RegionAttachment( slot.attachment );
                    verticesLength = 8;
                    region.computeWorldVertices( 0, 0, slot.bone, worldVertices );
                } else if( attachment is MeshAttachment )
                {
                    var mesh : MeshAttachment = MeshAttachment( attachment );
                    verticesLength = mesh.vertices.length;
                    if( worldVertices.length < verticesLength ) worldVertices.length = verticesLength;
                    mesh.computeWorldVertices( 0, 0, slot, worldVertices );
                } else if( attachment is WeightedMeshAttachment )
                {
                    var weightedMesh : WeightedMeshAttachment = WeightedMeshAttachment( attachment );
                    verticesLength = weightedMesh.uvs.length;
                    if( worldVertices.length < verticesLength ) worldVertices.length = verticesLength;
                    weightedMesh.computeWorldVertices( 0, 0, slot, worldVertices );
                } else
                    continue;
                for( var ii : int = 0; ii < verticesLength; ii += 2 )
                {
                    var x : Number = worldVertices[ ii ], y : Number = worldVertices[ ii + 1 ];
                    minX = minX < x ? minX : x;
                    minY = minY < y ? minY : y;
                    maxX = maxX > x ? maxX : x;
                    maxY = maxY > y ? maxY : y;
                }
            }

            var temp : Number;
            if( maxX < minX )
            {
                temp = maxX;
                maxX = minX;
                minX = temp;
            }
            if( maxY < minY )
            {
                temp = maxY;
                maxY = minY;
                minY = temp;
            }

            resultRect.setTo( minX, minY, maxX - minX, maxY - minY );
            return resultRect;
        }

        private function createSharedSubMesh() : SubMesh
        {
            var pSubMesh : SubMesh = m_Mesh.createSubMesh( 0, false, null, 0, null, 0, true );
            return pSubMesh;
        }

        private function updateSkeletonAnimation() : void
        {
            if( m_Skeleton == null )
            {
                Foundation.Log.logErrorMsg( "Can not update the skeleton animation, skeleton value is null pointer!" );
                return;
            }

            var red : Number = m_fRed * m_Skeleton.r;
            var green : Number = m_fGreen * m_Skeleton.g;
            var blue : Number = m_fBlue * m_Skeleton.b;
            var alpha : Number = m_fAlpha * m_Skeleton.a;
            var x : Number = m_Skeleton.x;
            var y : Number = m_Skeleton.y;

            var pSlot : Slot = null;
            var pAttachment : Attachment = null;
            var pRendererObject : RendererObject = null;
            var pSlots : Vector.<Slot> = m_Skeleton.drawOrder;
            m_iDrawCount = pSlots.length;
            if( m_vecDrawSubEntity.length < m_iDrawCount )
                m_vecDrawSubEntity.length = m_iDrawCount;
            for( var i : int = m_iDrawCount - 1; i >= 0; i-- )
            {
                pSlot = pSlots[ i ];
                pAttachment = pSlot.attachment;
                if( pAttachment == null )
                {
                    continue;
                }

                if( pAttachment is RegionAttachment )
                {
                    var pRegionAttachment : RegionAttachment = pAttachment as RegionAttachment;
                    pRendererObject = pRegionAttachment.rendererObject as RendererObject;

                    red = red * pSlot.r * pRegionAttachment.r;
                    green = green * pSlot.g * pRegionAttachment.g;
                    blue = blue * pSlot.b * pRegionAttachment.b;
                    alpha = alpha * pSlot.a * pRegionAttachment.a;
                }
                else if( pAttachment is MeshAttachment )
                {
                    var pMeshAttachment : MeshAttachment = pAttachment as MeshAttachment;
                    pRendererObject = pMeshAttachment.rendererObject as RendererObject;

                    red = red * pSlot.r * pMeshAttachment.r;
                    green = green * pSlot.g * pMeshAttachment.g;
                    blue = blue * pSlot.b * pMeshAttachment.b;
                    alpha = alpha * pSlot.a * pMeshAttachment.a;
                }
                else if( pAttachment is WeightedMeshAttachment )
                {
                    var pSkinnedMesh : WeightedMeshAttachment = pAttachment as WeightedMeshAttachment;
                    pRendererObject = pSkinnedMesh.rendererObject as RendererObject;

                    red = red * pSlot.r * pSkinnedMesh.r;
                    green = green * pSlot.g * pSkinnedMesh.g;
                    blue = blue * pSlot.b * pSkinnedMesh.b;
                    alpha = alpha * pSlot.a * pSkinnedMesh.a;
                }

                //(m_Material as MSkeleton ).blendMode = pSlot.data.blendMode.ordinal ? BlendMode.NORMAL : BlendMode.ADD;
                updateSubEntity( i, pAttachment.name, x, y, red, green, blue, alpha, pSlot, pRendererObject );
            }
        }

        /**
         * set attachments uv
         * @param pSubMesh
         * @param pAttachment
         */
        private function setAttachmentUVs( pSubMesh : SubMesh, pAttachment : Attachment ) : void
        {
            var pSharedVertices : VertexData = pSubMesh.Engine_Internal::_vertices;
            var pRegionAttachment : RegionAttachmentExt = pAttachment as RegionAttachmentExt;
            if( pRegionAttachment != null )
            {
                pSharedVertices.setTexCoords( 2, pRegionAttachment.uvs[ 2 ], pRegionAttachment.uvs[ 3 ] );
                pSharedVertices.setTexCoords( 3, pRegionAttachment.uvs[ 4 ], pRegionAttachment.uvs[ 5 ] );

                pSharedVertices.setTexCoords( 0, pRegionAttachment.uvs[ 0 ], pRegionAttachment.uvs[ 1 ] );
                pSharedVertices.setTexCoords( 1, pRegionAttachment.uvs[ 6 ], pRegionAttachment.uvs[ 7 ] );
            }

            var pMeshAttachment : MeshAttachmentExt = pAttachment as MeshAttachmentExt;
            if( pMeshAttachment != null )
            {
                pSubMesh.Engine_Internal::_setSharedUVs( pMeshAttachment.uvs );
            }

            var pSkinedMeshAttachment : SkinedMeshAttachmentExt = pAttachment as SkinedMeshAttachmentExt;
            if( pSkinedMeshAttachment != null )
            {
                pSubMesh.Engine_Internal::_setSharedUVs( pSkinedMeshAttachment.uvs );
            }
        }

        private function updateSubEntity( index : int, name : String, x : Number, y : Number, r : Number, g : Number, b : Number,
                                          alpha : Number, pSlot : Slot, pRendererObject : RendererObject ) : void
        {
            var pSubMesh : SubMesh = null;
            var pSharedVertices : VertexData = pRendererObject.vertices;

            //find sub entity, if not exist, create and push it to this sub entities list
            var pSubEntity : SubEntity = this.findSubEntity( name );
            var pAttachment : Attachment = pSlot.attachment;
            if( pSubEntity == null )
            {
                var pRegionAttachment : RegionAttachmentExt = pAttachment as RegionAttachmentExt;
                var pMeshAttachment : MeshAttachmentExt = pAttachment as MeshAttachmentExt;
                var pSkinedMeshAttachment : SkinedMeshAttachmentExt = pAttachment as SkinedMeshAttachmentExt;
                var pTriangles : Vector.<uint> = null;

                //initialize vertices and indices
                if( pMeshAttachment != null )
                {
                    pSharedVertices.numVertices = pMeshAttachment.uvs.length >> 1;
                    pTriangles = pMeshAttachment.triangles;
                }
                else if( pSkinedMeshAttachment != null )
                {
                    pSharedVertices.numVertices = pSkinedMeshAttachment.uvs.length >> 1;
                    pTriangles = pSkinedMeshAttachment.triangles;
                }
                else if( pRegionAttachment != null )
                {
                    pTriangles = pRendererObject.indices;
                }

                //create sub mesh and set shared vertices and indices
                pSubMesh = this.createSharedSubMesh();
                pSubMesh.Engine_Internal::_setSharedVertices( pSharedVertices.numVertices,
                        pSharedVertices, pTriangles, 0, pTriangles.length / 3 );

                //set attachment uvs
                this.setAttachmentUVs( pSubMesh, pAttachment );

                //set texture
                m_Material.texture = pRendererObject.texture;
                if( pRendererObject.texture != null )
                    pSharedVertices.setPremultipliedAlpha( pRendererObject.texture.premultipliedAlpha, false );

                //create sub entity
                pSubEntity = this.createSubEntity( pSubMesh, name );
                this.setSubEntityMaterial( pSubEntity.Engine_Internal::index - 1, m_Material, true );

                //manage renderer objects
                var len : int = m_vecRendererObject.length;
                m_vecRendererObject.fixed = false;
                m_vecRendererObject.length += 1;
                m_vecRendererObject.fixed = true;
                m_vecRendererObject[ len ] = pRendererObject;
            }
            else
            {
                pSubMesh = pSubEntity.Engine_Internal::getSubMesh();
            }

            //add this sub entity to draw list
            m_vecDrawSubEntity[ index ] = pSubEntity;

            //update vertices color
            pSharedVertices.setColorAndAlphaRGBA( r, g, b, alpha );

            //update vertices local position
            updateVertices( x, y, pSlot, pSubMesh );
            pSubMesh.Engine_Internal::_setVerticesDirty();
        }

        /**
         * clear draw list
         */
        private function clearDrawSubEntities() : void
        {
            if( m_vecDrawSubEntity != null )
            {
                for( var i : int = 0, length : int = m_vecDrawSubEntity.length; i < length; i++ )
                {
                    m_vecDrawSubEntity[ i ] = null;
                }
            }
        }

        /**
         * batch sub entities which in the draw lists
         */
        private function batchSelf() : void
        {
            if( m_bNeedBatch )
            {

            }
        }
    }
}