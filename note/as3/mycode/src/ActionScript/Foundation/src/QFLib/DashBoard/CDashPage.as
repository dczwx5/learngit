//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/5
//----------------------------------------------------------------------------------------------------------------------

package QFLib.DashBoard
{

import QFLib.Memory.CSmartObject;

    import flash.display.Sprite;
    import flash.utils.getQualifiedClassName;

    //
    //
    //
    public class CDashPage extends CSmartObject
    {
        public function CDashPage( theDashBoard : CDashBoard )
        {
            super();
            m_theDashBoardRef = theDashBoard;

            m_thePageSpriteRoot = new Sprite();
            m_theDashBoardRef.boardSprite.addChild( m_thePageSpriteRoot );
        }
        
        public override function dispose() : void
        {
            super.dispose();
        }

        [Inline]
        final public function get pageRoot() : Sprite
        {
            return m_thePageSpriteRoot;
        }

        [Inline]
        final public function get visible() : Boolean
        {
            return m_bVisible;
        }

        // if user not override the name(), default will use the full class name instead
        public virtual function get name() : String
        {
            var sClassName : String = getQualifiedClassName( this );
            return sClassName;
        }

        public virtual function set visible( bVisible : Boolean ) : void
        {
            if( m_bVisible == bVisible ) return ;

            m_bVisible = bVisible;
            m_thePageSpriteRoot.visible = bVisible;
        }

        //
        public virtual function onResize() : void
        {
        }

        public virtual function update( fDeltaTime : Number ) : void
        {
        }

        //

        //
        //
        protected var m_theDashBoardRef : CDashBoard = null;
        protected var m_thePageSpriteRoot : Sprite = null;
        protected var m_bVisible : Boolean = true;
    }

}
