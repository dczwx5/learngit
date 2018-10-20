/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.attachments
{
    import QFLib.QEngine.ThirdParty.Spine.Skin;
    import QFLib.QEngine.ThirdParty.Spine.atlas.Atlas;
    import QFLib.QEngine.ThirdParty.Spine.atlas.AtlasRegion;

    public class AtlasAttachmentLoader implements AttachmentLoader
    {
        static public function nextPOT( value : int ) : int
        {
            value--;
            value |= value >> 1;
            value |= value >> 2;
            value |= value >> 4;
            value |= value >> 8;
            value |= value >> 16;
            return value + 1;
        }

        public function AtlasAttachmentLoader( atlas : Atlas )
        {
            if( atlas == null )
                throw new ArgumentError( "atlas cannot be null." );
            this.atlas = atlas;
        }
        private var atlas : Atlas;

        public function newRegionAttachment( skin : Skin, name : String, path : String ) : RegionAttachment
        {
            var region : AtlasRegion = atlas.findRegion( path );
            if( region == null )
                throw new Error( "Region not found in atlas: " + path + " (region attachment: " + name + ")" );
            var attachment : RegionAttachment = new RegionAttachment( name );
            attachment.rendererObject = region;
            var scaleX : Number = region.page.width / nextPOT( region.page.width );
            var scaleY : Number = region.page.height / nextPOT( region.page.height );
            attachment.setUVs( region.u * scaleX, region.v * scaleY, region.u2 * scaleX, region.v2 * scaleY, region.rotate );
            attachment.regionOffsetX = region.offsetX;
            attachment.regionOffsetY = region.offsetY;
            attachment.regionWidth = region.width;
            attachment.regionHeight = region.height;
            attachment.regionOriginalWidth = region.originalWidth;
            attachment.regionOriginalHeight = region.originalHeight;
            return attachment;
        }

        public function newMeshAttachment( skin : Skin, name : String, path : String ) : MeshAttachment
        {
            var region : AtlasRegion = atlas.findRegion( path );
            if( region == null )
                throw new Error( "Region not found in atlas: " + path + " (mesh attachment: " + name + ")" );
            var attachment : MeshAttachment = new MeshAttachment( name );
            attachment.rendererObject = region;
            var scaleX : Number = region.page.width / nextPOT( region.page.width );
            var scaleY : Number = region.page.height / nextPOT( region.page.height );
            attachment.regionU = region.u * scaleX;
            attachment.regionV = region.v * scaleY;
            attachment.regionU2 = region.u2 * scaleX;
            attachment.regionV2 = region.v2 * scaleY;
            attachment.regionRotate = region.rotate;
            attachment.regionOffsetX = region.offsetX;
            attachment.regionOffsetY = region.offsetY;
            attachment.regionWidth = region.width;
            attachment.regionHeight = region.height;
            attachment.regionOriginalWidth = region.originalWidth;
            attachment.regionOriginalHeight = region.originalHeight;
            return attachment;
        }

        public function newWeightedMeshAttachment( skin : Skin, name : String, path : String ) : WeightedMeshAttachment
        {
            var region : AtlasRegion = atlas.findRegion( path );
            if( region == null )
                throw new Error( "Region not found in atlas: " + path + " (weighted mesh attachment: " + name + ")" );
            var attachment : WeightedMeshAttachment = new WeightedMeshAttachment( name );
            attachment.rendererObject = region;
            var scaleX : Number = region.page.width / nextPOT( region.page.width );
            var scaleY : Number = region.page.height / nextPOT( region.page.height );
            attachment.regionU = region.u * scaleX;
            attachment.regionV = region.v * scaleY;
            attachment.regionU2 = region.u2 * scaleX;
            attachment.regionV2 = region.v2 * scaleY;
            attachment.regionRotate = region.rotate;
            attachment.regionOffsetX = region.offsetX;
            attachment.regionOffsetY = region.offsetY;
            attachment.regionWidth = region.width;
            attachment.regionHeight = region.height;
            attachment.regionOriginalWidth = region.originalWidth;
            attachment.regionOriginalHeight = region.originalHeight;
            return attachment;
        }

        public function newBoundingBoxAttachment( skin : Skin, name : String ) : BoundingBoxAttachment
        {
            return new BoundingBoxAttachment( name );
        }
    }

}
