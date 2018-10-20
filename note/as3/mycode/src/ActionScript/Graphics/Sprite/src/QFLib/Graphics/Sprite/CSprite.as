//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite
{
    import QFLib.Graphics.RenderCore.*;

    public class CSprite extends CImageObject
	{
        public function CSprite( theSpriteSystem : CSpriteSystem, bCenterPosition : Boolean = false )
        {
            super( theSpriteSystem.renderer, bCenterPosition );

            m_theSpriteSystemRef = theSpriteSystem;
            theSpriteSystem._addSprite( this );
        }

        public override function dispose() : void
        {
            if ( this.disposed )
                return;
            m_theSpriteSystemRef._removeSprite( this );
            super.dispose();
        }

        public override function set visible( bVisible : Boolean ) : void
        {
            if( super.visible == bVisible ) return ;

            m_theSpriteSystemRef._removeSprite( this );
            super.visible = bVisible;
            m_theSpriteSystemRef._addSprite( this );

            if( bVisible ) update( 0.0 ); // update once just in case this function is called after the update
        }

        public function get spriteSystemRef() : CSpriteSystem
        {
            return m_theSpriteSystemRef;
        }


        //
        protected var m_theSpriteSystemRef : CSpriteSystem = null;

    }
}
