/**
 * (C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
 * Created on 2016/5/11.
 */
package spineExt.starling
{

    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.material.MSkeleton;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.Mesh;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.Color;
    import QFLib.Graphics.RenderCore.starling.utils.MatrixUtil;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Math.CAABBox2;

    import flash.events.Event;

    import flash.geom.Rectangle;

    import spine.BlendMode;
    import spine.SkeletonData;
    import spine.Skin;
    import spine.Slot;
    import spine.animation.AnimationStateData;
    import spine.attachments.Attachment;
    import spine.attachments.AttachmentType;
    import spine.attachments.BoundingBoxAttachment;
    import spine.starling.SkeletonAnimation;

    public class SkeletonAnimation extends spine.starling.SkeletonAnimation
    {
        private static var sTempVertices : Vector.<Number> = new Vector.<Number> ( 8 );
        private static var sTriangles : Vector.<uint> = new <uint>[ 0, 1, 2, 1, 3, 2 ];

        protected var _drawItems : Vector.<DrawItem> = null;
        protected var _material : MSkeleton = null;
        protected var _stateData : AnimationStateData;
        protected var _bounds : Rectangle = new Rectangle ();
        protected var _tintColor : Vector.<Number> = Vector.<Number> ( [ 1.0, 1.0, 1.0, 1.0 ] );
        protected var _maskColor : Vector.<Number> = Vector.<Number> ( [ 0.0, 0.0, 0.0, 0.0 ] );
        protected var _autoRecalculateBound : Boolean = true;

        public function SkeletonAnimation ( skeletonData : SkeletonData, renderMeshes : Boolean = true, stateData : AnimationStateData = null )
        {
            _stateData = stateData ? stateData : new AnimationStateData ( skeletonData );
            super ( skeletonData, renderMeshes, _stateData );

            _drawItems = new Vector.<DrawItem> ( 1 );
            _drawItems[ 0 ] = new DrawItem ();
            _material = new MSkeleton ();
        }

        public override function dispose () : void
        {
            if ( _material != null )
            {
                _material.dispose ();
                _material = null;
            }

            if ( _drawItems != null )
            {
                for each ( var item : DrawItem in _drawItems )
                {
                    if ( item != null )
                    {
                        item.dispose ();
                    }
                }
                _drawItems.fixed = false;
                _drawItems.length = 0;
                _drawItems = null;
            }

            super.dispose ();
        }

        public function advanceTimeOnly ( time : Number, bApplySkeleton : Boolean = false ) : void
        {
            time *= timeScale;
            skeleton.update ( time );
            state.update ( time );
            if ( bApplySkeleton ) state.apply ( skeleton );
            //skeleton.updateWorldTransform(); <-- not update skeleton/bones' world matrix yet
        }

        public function get stateData () : AnimationStateData
        {
            return _stateData;
        }

        [Inline]
        final public function get autoRecalculateBound () : Boolean
        {
            return _autoRecalculateBound;
        }

        [Inline]
        final public function set autoRecalculateBound ( bAutoRecalculate : Boolean ) : void
        {
            _autoRecalculateBound = bAutoRecalculate;
        }

        public function setBound ( theAABB : CAABBox2 ) : void
        {
            _bounds.setTo ( theAABB.min.x, theAABB.min.y, theAABB.width, theAABB.height );
        }

        public override function getBounds ( targetSpace : DisplayObject, resultRect : Rectangle = null ) : Rectangle
        {
            if ( _autoRecalculateBound ) _bounds = calcBounds ( _bounds );

            if ( !resultRect )
            {
                resultRect = new Rectangle ();
            }
            if ( targetSpace == this )
            {
                resultRect.setTo ( _bounds.x, _bounds.y, _bounds.width, _bounds.height );
            }
            else
            {
                getTransformationMatrix ( targetSpace, sHelperMatrix );
                resultRect.copyFrom ( _bounds );
                MatrixUtil.transformRectangle ( sHelperMatrix, resultRect );
            }
            return resultRect;
        }

        public function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            if ( masking )
            {
                _maskColor[ 0 ] = r;
                _maskColor[ 1 ] = g;
                _maskColor[ 2 ] = b;
                _maskColor[ 3 ] = alpha;
                this.alpha = _tintColor[ 0 ] = _tintColor[ 1 ] = _tintColor[ 2 ] = _tintColor[ 3 ] = 1.0;
            }
            else
            {
                _tintColor[ 0 ] = r;
                _tintColor[ 1 ] = g;
                _tintColor[ 2 ] = b;
                this.alpha = _tintColor[ 3 ] = alpha;
                _maskColor[ 3 ] = 0.0;
            }
        }

        public function resetColor () : void
        {
            _maskColor[ 0 ] = _maskColor[ 1 ] = _maskColor[ 2 ] = 0.0;
            _maskColor[ 3 ] = 0.0;
            this.alpha = _tintColor[ 0 ] = _tintColor[ 1 ] = _tintColor[ 2 ] = _tintColor[ 3 ] = 1.0;
        }

        [Inline] public function get material () : IMaterial { return _material; }

        public function setLightColorAndContrast ( r : Number = 1.0, g : Number = 1.0, b : Number = 1.0, alpha : Number = 1.0, contrast : Number = 0.0 ) : void
        {
            _material.setLightColorAndContrast ( r, g, b, alpha, contrast );
        }

        override public function render ( support : RenderSupport, alpha : Number ) : void
        {
            _drawItems.fixed = false;

            resetDrawItems ();
            var drawOrder : Vector.<Slot> = skeleton.drawOrder;
            var pCurrentItem : DrawItem = _drawItems[ 0 ];
            var numItems : int = _drawItems.length;
            var numUsedItem : int = 1;

            var pCurrentMesh : Mesh = pCurrentItem.mesh;
            var usedNumVertices : int = 0;
            var pSlot : Slot = null;
            var pAttachment : Attachment = null;
            var usedNumIndieces : int = 0;
            var pLastTexture : Texture = null;
            var pCurrentTexture : Texture = null;
            var lastBlendMode : String = null;
            var currentBlendMode : String = "normal";
            var isAttachmentNull : Boolean = false;
            var isTextureDiff : Boolean = false;
            var isBlendModeDiff : Boolean = false;
            var numAttachmentVertices : int = 0;
            var numAttachmentIndices : int = 0;
            for ( var i : int = 0, n : int = drawOrder.length; i < n; i++ )
            {
                pSlot = drawOrder[ i ];
                pAttachment = pSlot.attachment;
                if ( pAttachment == null )
                {
                    continue;
                }

                if ( pCurrentItem.startSlot < 0 ) pCurrentItem.startSlot = i;

                currentBlendMode = ( pSlot.data.blendMode.ordinal == BlendMode.normal.ordinal ) ? "normal" : "add";

                if ( pAttachment is RegionAttachment )
                {
                    var pRegionAttachment : RegionAttachment = pAttachment as RegionAttachment;
                    var a : Number = pSlot.a * pRegionAttachment.a;
                    if ( a < 0.01 )
                        continue;

                    numAttachmentVertices = 4;
                    numAttachmentIndices = 6;
                    pCurrentTexture = pRegionAttachment.texture;
                }
                else if ( pAttachment is MeshAttachment )
                {
                    var pMeshAttachment : MeshAttachment = pAttachment as MeshAttachment;

                    numAttachmentVertices = ( pMeshAttachment.vertices.length >> 1 );
                    numAttachmentIndices = pMeshAttachment.triangles.length;
                    pCurrentTexture = pMeshAttachment.texture;
                }
                else if ( pAttachment is WeightedMeshAttachment )
                {
                    var pSkinnedMesh : WeightedMeshAttachment = pAttachment as WeightedMeshAttachment;

                    numAttachmentVertices = ( pSkinnedMesh.uvs.length >> 1 );
                    numAttachmentIndices = pSkinnedMesh.triangles.length;
                    pCurrentTexture = pSkinnedMesh.texture;
                }
                else
                {
                    continue;
                }

                if ( pCurrentTexture == null || pCurrentTexture.base == null )
                {
                    if ( pCurrentTexture != null && pCurrentTexture.disposed )
                        Foundation.Log.logErrorMsg ( "We should check when the texture -"
                                + pCurrentTexture.root.fileName + " has been disposed!" );

                    continue;
                }

                usedNumVertices += numAttachmentVertices;
                usedNumIndieces += numAttachmentIndices;

                if ( !isAttachmentNull )
                {
                    pLastTexture = pCurrentTexture.root;
                    lastBlendMode = currentBlendMode;
                    isAttachmentNull = true;
                }

                isTextureDiff = pLastTexture != null && pLastTexture != pCurrentTexture.root;
                isBlendModeDiff = lastBlendMode != null && currentBlendMode != lastBlendMode;
                if ( isBlendModeDiff || isTextureDiff )
                {
                    pCurrentItem.endSlot = i - 1;

                    var mesh : Mesh = null;
                    var item : DrawItem = null;
                    numItems = _drawItems.length;
                    if ( numItems <= numUsedItem )
                    {
                        _drawItems.length += 1;
                        item = _drawItems[ numItems ] = new DrawItem ( pCurrentTexture );
                        mesh = _drawItems[ numItems ].mesh;
                    }
                    else
                    {
                        item = _drawItems[ numUsedItem ];
                        mesh = item.mesh;
                        mesh.texture = pCurrentTexture;
                    }

                    pCurrentItem = item;
                    pCurrentItem.startSlot = i;
                    pCurrentMesh = mesh;
                    numUsedItem += 1;
                    usedNumVertices = numAttachmentVertices;
                    usedNumIndieces = numAttachmentIndices;

                    pLastTexture = pCurrentTexture.root;
                    lastBlendMode = currentBlendMode;
                }

                pCurrentItem.usedNumVertices = usedNumVertices;
                pCurrentItem.usedNumIndices = usedNumIndieces;

                pCurrentMesh.texture = pCurrentTexture;
                pCurrentMesh.blendMode = currentBlendMode;
            }
            pCurrentItem.endSlot = drawOrder.length - 1;
            _drawItems.fixed = true;

            updateAndRenderItems ( support, alpha, numUsedItem );
        }

        private function updateAndRenderItems ( support : RenderSupport, alpha : Number, usedItems : int ) : void
        {
            alpha *= this.alpha * skeleton.a;
            var r : Number = skeleton.r * 255;
            var g : Number = skeleton.g * 255;
            var b : Number = skeleton.b * 255;
            var x : Number = skeleton.x;
            var y : Number = skeleton.y;

            var shouldRender : Boolean = false;
            var pItem : DrawItem = null;
            var pCurrentMesh : Mesh = null;
            var pSlot : Slot = null;
            var drawOrder : Vector.<Slot> = skeleton.drawOrder;
            var verticeOffset : int = 0;
            var triangleOffset : int = 0;
            var curNumVertices : int = 0;
            var curNumIndices : int = 0;
            var pAttachment : Attachment = null;
            var numAttachmentVertices : int = 0;
            var numAttachmentIndices : int = 0;
            var verticesColor : uint = Color.WHITE;
            var verticesAlpha : Number = 1.0;

            for ( var i : int = 0; i < usedItems; i++ )
            {
                pItem = _drawItems[ i ];
                if ( pItem == null || pItem.startSlot < 0 || pItem.endSlot < 0 || pItem.startSlot > pItem.endSlot )
                    continue;

                pItem.updateMesh ();
                pCurrentMesh = pItem.mesh;
                if( i == 0 )
                {
                    this.blendMode = pCurrentMesh.blendMode;
                }

                curNumVertices = 0;
                curNumIndices = 0;
                shouldRender = false;

                for ( var j : int = pItem.startSlot; j <= pItem.endSlot; j++ )
                {
                    pSlot = drawOrder[ j ];
                    verticeOffset = curNumVertices;
                    triangleOffset = curNumIndices;
                    pAttachment = pSlot.attachment;
                    if ( pAttachment == null )
                        continue;

                    if ( pAttachment is RegionAttachment )
                    {
                        var pRegionAttachment : RegionAttachment = pAttachment as RegionAttachment;
                        var a : Number = pSlot.a * pRegionAttachment.a;
                        if ( a < 0.01 )
                            continue;

                        numAttachmentVertices = 4;
                        numAttachmentIndices = 6;

                        verticesColor = Color.rgb (
                                r * pSlot.r * pRegionAttachment.r,
                                g * pSlot.g * pRegionAttachment.g,
                                b * pSlot.b * pRegionAttachment.b );
                        verticesAlpha = a;
                    }
                    else if ( pAttachment is MeshAttachment )
                    {
                        var pMeshAttachment : MeshAttachment = pAttachment as MeshAttachment;

                        numAttachmentVertices = ( pMeshAttachment.vertices.length >> 1 );
                        numAttachmentIndices = pMeshAttachment.triangles.length;

                        verticesColor = Color.rgb (
                                r * pSlot.r * pMeshAttachment.r,
                                g * pSlot.g * pMeshAttachment.g,
                                b * pSlot.b * pMeshAttachment.b );
                        verticesAlpha = pSlot.a * pMeshAttachment.a;
                    }
                    else if ( pAttachment is WeightedMeshAttachment )
                    {
                        var pSkinnedMesh : WeightedMeshAttachment = pAttachment as WeightedMeshAttachment;

                        numAttachmentVertices = ( pSkinnedMesh.uvs.length >> 1 );
                        numAttachmentIndices = pSkinnedMesh.triangles.length;

                        verticesColor = Color.rgb (
                                r * pSlot.r * pSkinnedMesh.r,
                                g * pSlot.g * pSkinnedMesh.g,
                                b * pSlot.b * pSkinnedMesh.b );
                        verticesAlpha = pSlot.a * pSkinnedMesh.a;
                    }
                    else
                    {
                        continue;
                    }

                    curNumVertices += numAttachmentVertices;
                    curNumIndices += numAttachmentIndices;

                    updateMesh ( pSlot, x, y, verticesColor, verticesAlpha, verticeOffset, triangleOffset, numAttachmentVertices, pCurrentMesh );
                    shouldRender = true;
                }

                if ( shouldRender )
                {
                    renderMesh ( support, alpha, pCurrentMesh );
                }
            }
        }

        private function updateMesh ( pSlot : Slot, x : Number, y : Number, color : uint, alpha : Number,
                                      verticeOffset : int, triangleOffset : int, numVertices : int, pMesh : Mesh ) : void
        {
            var pMeshVertices : VertexData = pMesh.vertices;
            var pMeshTriangles : Vector.<uint> = pMesh.indices;
            var pTriangles : Vector.<uint> = null;
            var pUVs : Vector.<Number> = null;
            var pAttachment : Attachment = pSlot.attachment;
            var pRegionAttachment : RegionAttachment = pAttachment as RegionAttachment;
            if ( pRegionAttachment != null )
            {
                pTriangles = sTriangles;
                pUVs = pRegionAttachment.uvs;
                pRegionAttachment._computeWorldVertices ( x, y, pSlot, verticeOffset, pMeshVertices );

                pMeshVertices.setTexCoords ( verticeOffset, pUVs[ 2 ], pUVs[ 3 ] );
                pMeshVertices.setTexCoords ( verticeOffset + 1, pUVs[ 4 ], pUVs[ 5 ] );
                pMeshVertices.setTexCoords ( verticeOffset + 2, pUVs[ 0 ], pUVs[ 1 ] );
                pMeshVertices.setTexCoords ( verticeOffset + 3, pUVs[ 6 ], pUVs[ 7 ] );
            }

            var pMeshAttachment : MeshAttachment = pAttachment as MeshAttachment;
            if ( pMeshAttachment != null )
            {
                pTriangles = pMeshAttachment.triangles;
                pUVs = pMeshAttachment.uvs;
                pMeshAttachment._computeWorldVertices ( x, y, pSlot, verticeOffset, numVertices, pMeshVertices );
            }

            var pWeightMeshAttachment : WeightedMeshAttachment = pAttachment as WeightedMeshAttachment;
            if ( pWeightMeshAttachment != null )
            {
                pTriangles = pWeightMeshAttachment.triangles;
                pUVs = pWeightMeshAttachment.uvs;
                pWeightMeshAttachment._computeWorldVertices ( x, y, pSlot, verticeOffset, numVertices, pMeshVertices );
            }

            /** set vertices color and uvs */
            var count : int = ( pUVs.length >> 1 );
            for ( var i : int = 0, j : int = 0; i < count; i++, j += 2 )
            {
                pMeshVertices.setColorAndAlpha ( verticeOffset + i, color, alpha );
                if ( pRegionAttachment == null )
                {
                    pMeshVertices.setTexCoords ( verticeOffset + i, pUVs[ j ], pUVs[ j + 1 ] );
                }
            }

            /** triangles changed when the animation state changed, so optimize the below code later.*/
//            var numIndices : int = pMeshTriangles.length - triangleOffset - pTriangles.length;
//            if ( numIndices < 0 )
//                pMeshTriangles.length += ( -numIndices );
            for ( i = 0, count = pTriangles.length; i < count; i++ )
            {
                pMeshTriangles[ triangleOffset + i ] = pTriangles[ i ] + verticeOffset;
            }
        }

        private function renderMesh ( support : RenderSupport, alpha : Number, pMesh : Mesh ) : void
        {
            if ( !Starling.current.contextValid )
                return;

            var pTex : Texture = pMesh.texture.root;
            if ( pTex == null || pTex.disposed || !pTex.uploaded || pTex.base == null )
                return;

            _tintColor[ 3 ] = alpha;
            _material.tintColor = _tintColor;
            _material.maskColor = _maskColor;
            _material.mainTexture = pMesh.texture;
            _material.pma = pMesh.texture.premultipliedAlpha;
            _material.blendMode = pMesh.blendMode;

            pMesh.worldMatrix2D = worldTransform;
            pMesh.material = _material;
            pMesh.syncBuffers();
            pMesh.render ( support, 1 );
        }

        private function resetDrawItems () : void
        {
            for each ( var item : DrawItem in _drawItems )
            {
                if ( item != null )
                {
                    item.startSlot = -1;
                    item.endSlot = -1;
                }
            }
        }

        public function calcBounds ( resultRect : Rectangle ) : Rectangle
        {
            if ( resultRect == null )
            {
                resultRect = new Rectangle ();
            }

            var minX : Number = Number.MAX_VALUE, minY : Number = Number.MAX_VALUE;
            var maxX : Number = Number.MIN_VALUE, maxY : Number = Number.MIN_VALUE;
            var slots : Vector.<Slot> = skeleton.slots;
            var worldVertices : Vector.<Number> = sTempVertices;
            for ( var i : int = 0, n : int = slots.length; i < n; ++i )
            {
                var slot : Slot = slots[ i ];
                var attachment : Attachment = slot.attachment;
                if ( !attachment ) continue;
                var verticesLength : int;
                if ( attachment is RegionAttachment )
                {
                    var region : RegionAttachment = RegionAttachment ( slot.attachment );
                    verticesLength = 8;
                    region.computeWorldVertices ( 0, 0, slot.bone, worldVertices );
                } else if ( attachment is MeshAttachment )
                {
                    var mesh : MeshAttachment = MeshAttachment ( attachment );
                    verticesLength = mesh.vertices.length;
                    if ( worldVertices.length < verticesLength ) worldVertices.length = verticesLength;
                    mesh.computeWorldVertices ( 0, 0, slot, worldVertices );
                } else if ( attachment is WeightedMeshAttachment )
                {
                    var weightedMesh : WeightedMeshAttachment = WeightedMeshAttachment ( attachment );
                    verticesLength = weightedMesh.uvs.length;
                    if ( worldVertices.length < verticesLength ) worldVertices.length = verticesLength;
                    weightedMesh.computeWorldVertices ( 0, 0, slot, worldVertices );
                } else
                    continue;
                for ( var ii : int = 0; ii < verticesLength; ii += 2 )
                {
                    var x : Number = worldVertices[ ii ], y : Number = worldVertices[ ii + 1 ];
                    minX = minX < x ? minX : x;
                    minY = minY < y ? minY : y;
                    maxX = maxX > x ? maxX : x;
                    maxY = maxY > y ? maxY : y;
                }
            }

            var temp : Number;
            if ( maxX < minX )
            {
                temp = maxX;
                maxX = minX;
                minX = temp;
            }
            if ( maxY < minY )
            {
                temp = maxY;
                maxY = minY;
                minY = temp;
            }

            resultRect.setTo ( minX, minY, maxX - minX, maxY - minY );
            return resultRect;
        }

        public function setSkin ( skinNameOrPath : String ) : void
        {
            // spine default setSkin function
            if ( skeleton.data.findSkin ( skinNameOrPath ) != null )
            {
                skeleton.skinName = skinNameOrPath;
            }
            //according to path to get the texture and setSkinAttachment
            else
            {
                var oldSkin : Skin = skeleton.skin;
                var textureAtlasResources : Array = null;

                var attachmentLoader : StarlingAtlasAttachmentLoader = new StarlingAtlasAttachmentLoader ( textureAtlasResources[ 0 ].theObject );
                var length : int = textureAtlasResources.length;
                for ( var i : int = 0; i < length; ++i )
                {
                    attachmentLoader.addPage ( textureAtlasResources[ i ].theObject );
                }

                var name : String;
                for each ( var slot : Slot in  skeleton.slots )
                {
                    name = slot.data.attachmentName;
                    if ( name )
                    {
                        slot.attachment = readAttachment ( slot.attachment, attachmentLoader, oldSkin );
                    }
                }
            }
        }

        //skin is just a parameter and useless
        public function readAttachment ( attachment : Attachment, attachmentLoader : StarlingAtlasAttachmentLoader, skin : Skin ) : Attachment
        {
            var type : AttachmentType = AttachmentType.region;
            if ( (attachment as RegionAttachment) != null )
            {
                type = AttachmentType.region;
            }
            else if ( (attachment as MeshAttachment) != null )
            {
                type = AttachmentType.mesh;
            }
            else if ( (attachment as WeightedMeshAttachment) != null )
            {
                type = AttachmentType.weightedmesh;
            } else if ( (attachment as BoundingBoxAttachment) != null )
            {
                type = AttachmentType.boundingbox;
            }

            switch ( type )
            {
                case AttachmentType.region:
                    var regionTemp : RegionAttachment = attachment as RegionAttachment;
                    var region : RegionAttachment = attachmentLoader.newRegionAttachmentEx ( skin, attachment.name, regionTemp.path );
                    if ( !region ) return null;

                    region.path = regionTemp.path;
                    region.x = regionTemp.x;
                    region.y = regionTemp.y;
                    region.scaleX = regionTemp.scaleX;
                    region.scaleY = regionTemp.scaleY;
                    region.rotation = regionTemp.rotation;
                    region.width = regionTemp.width;
                    region.height = regionTemp.height;

                    region.r = regionTemp.r;
                    region.g = regionTemp.g;
                    region.b = regionTemp.b;
                    region.a = regionTemp.a;
                    region.updateOffset ();
                    return region;

                case AttachmentType.mesh:
                case AttachmentType.linkedmesh:
                    var meshTemp : MeshAttachment = attachment as MeshAttachment;
                    var mesh : MeshAttachment = attachmentLoader.newMeshAttachmentEx ( skin, meshTemp.name, meshTemp.path );
                    if ( !mesh ) return null;
                    mesh.path = meshTemp.path;

                    mesh.r = meshTemp.r;
                    mesh.g = meshTemp.g;
                    mesh.b = meshTemp.b;
                    mesh.a = meshTemp.a;

                    mesh.width = meshTemp.width;
                    mesh.height = meshTemp.height;

                    if ( !meshTemp.parentMesh )
                    {
                        mesh.vertices = meshTemp.vertices;
                        mesh.triangles = meshTemp.triangles;
                        mesh.regionUVs = meshTemp.regionUVs;
                        mesh.updateUVs ();

                        mesh.hullLength = meshTemp.hullLength;
                        mesh.edges = meshTemp.edges;
                    } else
                    {
                        mesh.inheritFFD = meshTemp.inheritFFD;
                        //linkedMeshes[linkedMeshes.length] = new LinkedMesh(mesh, map["skin"], slotIndex, map["parent"]);
                    }
                    return mesh;

                case AttachmentType.weightedmesh:
                case AttachmentType.weightedlinkedmesh:
                    var weightedMeshTemp : WeightedMeshAttachment = attachment as WeightedMeshAttachment;
                    var weightedMesh : WeightedMeshAttachment = attachmentLoader.newWeightedMeshAttachmentEx ( skin, weightedMeshTemp.name, weightedMeshTemp.path );
                    if ( !weightedMesh ) return null;

                    weightedMesh.path = weightedMeshTemp.path;

                    weightedMesh.r = weightedMeshTemp.r;
                    weightedMesh.g = weightedMeshTemp.g;
                    weightedMesh.b = weightedMeshTemp.b;
                    weightedMesh.a = weightedMeshTemp.a;

                    weightedMesh.width = weightedMeshTemp.width;
                    weightedMesh.height = weightedMeshTemp.height;

                    if ( !weightedMeshTemp.parentMesh )
                    {
                        weightedMesh.bones = weightedMeshTemp.bones;
                        weightedMesh.weights = weightedMeshTemp.weights;
                        weightedMesh.triangles = weightedMeshTemp.triangles;
                        weightedMesh.regionUVs = weightedMeshTemp.regionUVs;
                        weightedMesh.updateUVs ();

                        weightedMesh.hullLength = weightedMeshTemp.hullLength;
                        weightedMesh.edges = weightedMeshTemp.edges;
                    } else
                    {
                        weightedMesh.inheritFFD = weightedMeshTemp.inheritFFD;
//						linkedMeshes[linkedMeshes.length] = new LinkedMesh(weightedMesh, map["skin"], slotIndex, map["parent"]);
                    }
                    return weightedMesh;
                case AttachmentType.boundingbox:
                    var boxTemp : BoundingBoxAttachment = attachment as BoundingBoxAttachment;
                    var box : BoundingBoxAttachment = attachmentLoader.newBoundingBoxAttachment ( skin, boxTemp.name );
                    box.vertices = boxTemp.vertices;
                    return box;
            }
            return null;
        }
    }
}

import QFLib.Graphics.RenderCore.starling.display.Mesh;
import QFLib.Graphics.RenderCore.starling.textures.Texture;
import QFLib.Interface.IDisposable;

class DrawItem implements IDisposable
{
    public var mesh : Mesh = null;
    public var startSlot : int = -1;
    public var endSlot : int = -1;
    public var usedNumVertices : int = 0;
    public var usedNumIndices : int = 0;
    public var enable : Boolean = false;

    public function DrawItem ( pTexture : Texture = null )
    {
        mesh = new Mesh ( pTexture );
    }

    public function dispose () : void
    {
        mesh.dispose ();
        mesh = null;
    }

    public function updateMesh () : void
    {
        mesh.useNumVertices = usedNumVertices;
        if ( mesh.numVertices < usedNumVertices )
        {
            mesh.numVertices = usedNumVertices * 1.5;
        }

        mesh.useNumIndices = usedNumIndices;
        if ( mesh.numIndices < usedNumIndices )
        {
            mesh.numIndices = usedNumIndices * 1.5;
        }
    }
}

