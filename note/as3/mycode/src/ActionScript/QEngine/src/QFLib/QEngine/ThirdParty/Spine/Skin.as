/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    import QFLib.QEngine.ThirdParty.Spine.attachments.Attachment;

    import flash.utils.Dictionary;

    /** Stores attachments by slot index and attachment name. */
    public class Skin
    {
        public function Skin( name : String )
        {
            if( name == null ) throw new ArgumentError( "name cannot be null." );
            _name = name;
        }

        internal var _name : String;

        [Inline]
        final public function get name() : String
        {
            return _name;
        }

        private var _attachments : Vector.<Dictionary> = new Vector.<Dictionary>();

        [Inline]
        final public function get attachments() : Vector.<Dictionary>
        {
            return _attachments;
        }

        public function addAttachment( slotIndex : int, name : String, attachment : Attachment ) : void
        {
            if( attachment == null ) throw new ArgumentError( "attachment cannot be null." );
            if( slotIndex >= attachments.length ) attachments.length = slotIndex + 1;
            if( !attachments[ slotIndex ] ) attachments[ slotIndex ] = new Dictionary();
            attachments[ slotIndex ][ name ] = attachment;
        }

        /** @return May be null. */
        [Inline]
        final public function getAttachment( slotIndex : int, name : String ) : Attachment
        {
            if( slotIndex >= attachments.length ) return null;
            var dictionary : Dictionary = attachments[ slotIndex ];
            return dictionary ? dictionary[ name ] : null;
        }

        public function toString() : String
        {
            return _name;
        }

        /** Attach each attachment in this skin if the corresponding attachment in the old skin is currently attached. */
        public function attachAll( skeleton : Skeleton, oldSkin : Skin ) : void
        {
            var slotIndex : int = 0;
            for each ( var slot : Slot in skeleton.slots )
            {
                var slotAttachment : Attachment = slot.attachment;
                if( slotAttachment && slotIndex < oldSkin.attachments.length )
                {
                    var dictionary : Dictionary = oldSkin.attachments[ slotIndex ];
                    for( var name : String in dictionary )
                    {
                        var skinAttachment : Attachment = dictionary[ name ];
                        if( slotAttachment == skinAttachment )
                        {
                            var attachment : Attachment = getAttachment( slotIndex, name );
                            if( attachment != null ) slot.attachment = attachment;
                            break;
                        }
                    }
                }
                slotIndex++;
            }
        }
    }

}
