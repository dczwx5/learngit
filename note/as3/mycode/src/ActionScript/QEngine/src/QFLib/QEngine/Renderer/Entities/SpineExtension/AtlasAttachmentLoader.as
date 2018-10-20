/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Entities.SpineExtension
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Renderer.Textures.SubTexture;
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.QEngine.Renderer.Textures.TextureAtlas;
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.Skin;
    import QFLib.QEngine.ThirdParty.Spine.attachments.AttachmentLoader;
    import QFLib.QEngine.ThirdParty.Spine.attachments.BoundingBoxAttachment;
    import QFLib.QEngine.ThirdParty.Spine.attachments.MeshAttachment;
    import QFLib.QEngine.ThirdParty.Spine.attachments.RegionAttachment;
    import QFLib.QEngine.ThirdParty.Spine.attachments.WeightedMeshAttachment;

    import flash.geom.Rectangle;

    public class AtlasAttachmentLoader implements AttachmentLoader, IDisposable
    {
        private static var sTriangleHelper : Vector.<uint> = new <uint>[ 0, 2, 1, 1, 2, 3 ];

        private static function _newRegionAttachment( skin : Skin, name : String, path : String, pages : Vector.<TextureAtlas> ) : RegionAttachmentExt
        {
            var arr : Array = [ 0 ];
            var texture : Texture = findTexture( name, path, pages, arr );

            if( texture == null )
            {
                throw new Error( "Region not found in Starling atlas: " + path + " (region attachment: " + name + ")" );
            }

            // It's frame fixed in attachement
            texture.ignoreFrame = true;

            var attachment : RegionAttachmentExt = new RegionAttachmentExt( name );
            var frame : Rectangle = texture.frame;
            if( frame == null )
            {
                frame = new Rectangle( 0, 0, texture.width, texture.height );
            }

            texture = Texture.fromTexture( texture );

            var region : Rectangle = pages[ arr[ 0 ] ].getRegion( path );
            if( region == null )
                throw new Error( "Region not found in atlas: " + path + " (region attachment: " + name + ")" );

            var subTexture : SubTexture = texture as SubTexture;
            if( subTexture )
            {
                var root : Texture = subTexture.root;
                var rectRegion : Rectangle = pages[ arr[ 0 ] ].getRegion( path );
                var u : Number = rectRegion.x / root.width;
                var v : Number = rectRegion.y / root.height;
                var u2 : Number = (rectRegion.x + subTexture.width) / root.width;
                var v2 : Number = (rectRegion.y + subTexture.height) / root.height;
                attachment.setUVs( u, v, u2, v2, pages[ arr[ 0 ] ].getRotation( path ) );
            } else
            {
                attachment.setUVs( 0, 1, 1, 0, pages[ arr[ 0 ] ].getRotation( path ) );
            }

            var rendererObject : RendererObject = new RendererObject( 4, attachment.uvs, sTriangleHelper, texture );
            attachment.rendererObject = rendererObject;
            attachment.regionOffsetX = -frame.x;
            attachment.regionOffsetY = -frame.y;
            attachment.regionWidth = texture.width;
            attachment.regionHeight = texture.height;
            attachment.regionOriginalWidth = frame.width;
            attachment.regionOriginalHeight = frame.height;
            return attachment;
        }

        private static function _newMeshAttachment( skin : Skin, name : String, path : String, pages : Vector.<TextureAtlas> ) : MeshAttachmentExt
        {
            var texture : Texture = findTexture( name, path, pages );

            if( texture == null )
            {
                throw new Error( "Region not found in Starling atlas: " + path + " (region attachment: " + name + ")" );
            }

            // It's frame fixed in attachement
            texture.ignoreFrame = true;

            var attachment : MeshAttachmentExt = new MeshAttachmentExt( name );

            var frame : Rectangle = texture.frame;
            if( frame == null )
            {
                frame = new Rectangle( 0, 0, texture.width, texture.height );
            }

            var subTexture : SubTexture = texture as SubTexture;
            if( subTexture )
            {
                var clipping : Rectangle = subTexture.clipping;
                attachment.regionRotate = subTexture.rotated;
                var invw : Number = 1 / subTexture.parent.width;
                var invh : Number = 1 / subTexture.parent.height;

                if( attachment.regionRotate )
                {
                    attachment.regionU = clipping.x - (frame.y + frame.width - texture.width) * invw;
                    attachment.regionV = clipping.y + frame.x * invh;
                    attachment.regionU2 = attachment.regionU + frame.height * invw;
                    attachment.regionV2 = attachment.regionV + frame.width * invh;
                }
                else
                {
                    attachment.regionU = clipping.x + frame.x * invw;
                    attachment.regionV = clipping.y + frame.y * invh;
                    attachment.regionU2 = attachment.regionU + frame.width * invw;
                    attachment.regionV2 = attachment.regionV + frame.height * invh;
                }
            }
            else
            {
                attachment.regionU = 0;
                attachment.regionV = 1;
                attachment.regionU2 = 1;
                attachment.regionV2 = 0;
            }

            texture = Texture.fromTexture( texture );
            var rendererObject : RendererObject = new RendererObject( 0, attachment.uvs, attachment.triangles, texture );
            attachment.rendererObject = rendererObject;
            attachment.regionOffsetX = -frame.x;
            attachment.regionOffsetY = -frame.y;
            attachment.regionWidth = texture.width;
            attachment.regionHeight = texture.height;
            attachment.regionOriginalWidth = frame.width;
            attachment.regionOriginalHeight = frame.height;
            return attachment;
        }

        private static function _newWeightedMeshAttachment( skin : Skin, name : String, path : String, pages : Vector.<TextureAtlas> ) : SkinedMeshAttachmentExt
        {
//            var texture : Texture = findTexture ( name, path, pages );
//
//            if ( texture == null )
//            {
//                throw new Error ( "Region not found in Starling atlas: " + path + " (region attachment: " + name + ")" );
//            }
//
//            // It's frame fixed in attachement
//            texture.ignoreFrame = true;
//
//            var attachment : CSkinedMeshAttachment = new CSkinedMeshAttachment ( name );
//
//            var frame : Rectangle = texture.frame;
//            if ( frame == null )
//            {
//                frame = new Rectangle ( 0, 0, texture.width, texture.height );
//            }
//
//            var subTexture : SubTexture = texture as SubTexture;
//            if ( subTexture )
//            {
//                var clipping : Rectangle = subTexture.clipping;
//                attachment.regionRotate = subTexture.rotated;
//                var invw : Number = 1 / subTexture.parent.width;
//                var invh : Number = 1 / subTexture.parent.height;
//
//                if ( attachment.regionRotate )
//                {
//                    attachment.regionU = clipping.x - (frame.y + frame.width - texture.width) * invw;
//                    attachment.regionV = clipping.y + frame.x * invh;
//                    attachment.regionU2 = attachment.regionU + frame.height * invw;
//                    attachment.regionV2 = attachment.regionV + frame.width * invh;
//                }
//                else
//                {
//                    attachment.regionU = clipping.x + frame.x * invw;
//                    attachment.regionV = clipping.y + frame.y * invh;
//                    attachment.regionU2 = attachment.regionU + frame.width * invw;
//                    attachment.regionV2 = attachment.regionV + frame.height * invh;
//                }
//            }
//            else
//            {
//                attachment.regionU = 0;
//                attachment.regionV = 1;
//                attachment.regionU2 = 1;
//                attachment.regionV2 = 0;
//            }
//
//            texture = Texture.fromTexture ( texture );
//            var rendererObject : CRendererObject = new CRendererObject ( 0, attachment.uvs, attachment.triangles, texture );
//            attachment.rendererObject = rendererObject;
//            attachment.regionOffsetX = -frame.x;
//            attachment.regionOffsetY = -frame.y;
//            attachment.regionWidth = texture.width;
//            attachment.regionHeight = texture.height;
//            attachment.regionOriginalWidth = frame.width;
//            attachment.regionOriginalHeight = frame.height;
//            return attachment;

            var arr : Array = [ 0 ];
            var texture : Texture = findTexture( name, path, pages, arr );

            if( texture == null )
                throw new Error( "Region not found in Starling atlas: " + path + " (weighted mesh attachment: " + name + ")" );
            var attachment : SkinedMeshAttachmentExt = new SkinedMeshAttachmentExt( name );
            var rendererObject : RendererObject = new RendererObject( 0, attachment.uvs, attachment.triangles, texture );
            attachment.rendererObject = rendererObject; // Discard frame.
            var subTexture : SubTexture = texture as SubTexture;
            if( subTexture )
            {
                var root : Texture = subTexture.root;
                var rectRegion : Rectangle = pages[ arr[ 0 ] ].getRegion( path );
                attachment.regionU = rectRegion.x / root.width;
                attachment.regionV = rectRegion.y / root.height;
                attachment.regionU2 = (rectRegion.x + subTexture.width) / root.width;
                attachment.regionV2 = (rectRegion.y + subTexture.height) / root.height;
            } else
            {
                attachment.regionU = 0;
                attachment.regionV = 1;
                attachment.regionU2 = 1;
                attachment.regionV2 = 0;
            }
            var frame : Rectangle = texture.frame;
            attachment.regionOffsetX = frame ? -frame.x : 0;
            attachment.regionOffsetY = frame ? -frame.y : 0;
            attachment.regionWidth = texture.width;
            attachment.regionHeight = texture.height;
            attachment.regionOriginalWidth = frame ? frame.width : texture.width;
            attachment.regionOriginalHeight = frame ? frame.height : texture.height;
            return attachment;
        }

        private static function findTexture( name : String, path : String, pages : Vector.<TextureAtlas>, arr : Array = null ) : Texture
        {
            var texture : Texture = null;

            // throw exception if pages is null
            for( var i : int = pages.length - 1; i >= 0; i-- )
            {
                if( pages[ i ].ImageName == path )
                {
                    texture = pages[ i ].getTexture( name );
                    if( texture != null )
                    {
                        if( arr != null ) arr[ 0 ] = i;
                        return texture;
                    }
                }
            }

            // 如果上面没找到，则使用宽松规则找
            for( i = pages.length - 1; i >= 0; i-- )
            {
                texture = pages[ i ].getTexture( path );
                if( texture != null )
                {
                    if( arr != null ) arr[ 0 ] = i;
                    return texture;
                }

                texture = pages[ i ].getTexture( name );
                if( texture != null )
                {
                    if( arr != null ) arr[ 0 ] = i;
                    return texture;
                }
            }

            return texture;
        }

        public function AtlasAttachmentLoader( atlas : TextureAtlas )
        {
            m_Atlas = atlas;
            Bone.yDown = true;

            addPage( atlas );
        }
        private var m_vecPages : Vector.<TextureAtlas>;
        private var m_Atlas : TextureAtlas;

        public function dispose() : void
        {
            if( m_vecPages )
            {
                m_vecPages.length = 0;
                m_vecPages = null;
            }

            m_Atlas = null;
        }

        public function addPage( atlas : TextureAtlas ) : void
        {
            if( m_vecPages == null )
            {
                m_vecPages = new Vector.<TextureAtlas>();
            }

            if( m_vecPages.indexOf( atlas ) == -1 )
            {
                m_vecPages.push( atlas );
            }
        }

        public function newRegionAttachment( skin : Skin, name : String, path : String ) : RegionAttachment
        {
            return _newRegionAttachment( skin, name, path, m_vecPages );
        }

        public function newMeshAttachment( skin : Skin, name : String, path : String ) : MeshAttachment
        {
            return _newMeshAttachment( skin, name, path, m_vecPages );
        }

        public function newWeightedMeshAttachment( skin : Skin, name : String, path : String ) : WeightedMeshAttachment
        {
            return _newWeightedMeshAttachment( skin, name, path, m_vecPages );
        }

        public function newBoundingBoxAttachment( skin : Skin, name : String ) : BoundingBoxAttachment
        {
            return new BoundingBoxAttachmentExt( name );
        }

        public function newRegionAttachmentExtension( skin : Skin, name : String, path : String ) : RegionAttachmentExt
        {
            return _newRegionAttachment( skin, name, path, m_vecPages );
        }

        public function newMeshAttachmentExtension( skin : Skin, name : String, path : String ) : MeshAttachmentExt
        {
            return _newMeshAttachment( skin, name, path, m_vecPages );
        }

        public function newWeightedMeshAttachmentExtension( skin : Skin, name : String, path : String ) : SkinedMeshAttachmentExt
        {
            return _newWeightedMeshAttachment( skin, name, path, m_vecPages );
        }

        public function newBoundingBoxAttachmentExtension( skin : Skin, name : String ) : BoundingBoxAttachmentExt
        {
            return new BoundingBoxAttachmentExt( name );
        }
    }
}
