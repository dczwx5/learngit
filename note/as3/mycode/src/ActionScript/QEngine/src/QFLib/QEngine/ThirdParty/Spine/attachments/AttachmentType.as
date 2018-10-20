/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.attachments
{

    public class AttachmentType
    {
        public static const region : AttachmentType = new AttachmentType( 0, "region" );
        public static const regionsequence : AttachmentType = new AttachmentType( 1, "regionsequence" );
        public static const boundingbox : AttachmentType = new AttachmentType( 2, "boundingbox" );
        public static const mesh : AttachmentType = new AttachmentType( 3, "mesh" );
        public static const weightedmesh : AttachmentType = new AttachmentType( 4, "weightedmesh" );
        public static const linkedmesh : AttachmentType = new AttachmentType( 3, "linkedmesh" );
        public static const weightedlinkedmesh : AttachmentType = new AttachmentType( 4, "weightedlinkedmesh" );

        public function AttachmentType( ordinal : int, name : String )
        {
            this.ordinal = ordinal;
            this.name = name;
        }
        public var ordinal : int;
        public var name : String;
    }

}
