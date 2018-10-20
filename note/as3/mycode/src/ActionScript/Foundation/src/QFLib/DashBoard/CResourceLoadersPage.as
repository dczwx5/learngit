//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/5
//----------------------------------------------------------------------------------------------------------------------

package QFLib.DashBoard
{

    import QFLib.Foundation;
    import QFLib.Foundation.CKeyboard;
    import QFLib.Foundation.CLog;
    import QFLib.ResourceLoader.CResourceCache;
    import QFLib.ResourceLoader.CResourceLoaders;

    import flash.display.SimpleButton;

    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;

    //
    //
    //
    public class CResourceLoadersPage extends CDashPage
    {
        public function CResourceLoadersPage( theDashBoard : CDashBoard )
        {
            super( theDashBoard );

            m_theResourceText = new TextField();
            m_theResourceText.defaultTextFormat.font = "Terminal";
            m_theResourceText.textColor = 0xFFFFFF;
            m_theResourceText.wordWrap = true;
            m_theResourceText.multiline = true;
            m_theResourceText.border = true;
            m_theResourceText.borderColor = 0xFFFFFF;
            m_theResourceText.scrollV = m_theResourceText.numLines;
            m_thePageSpriteRoot.addChild( m_theResourceText );

            // filter label
            m_theFilterLabel = new TextField();
            m_theFilterLabel.defaultTextFormat.font = "Terminal";
            m_theFilterLabel.width = 160;
            m_theFilterLabel.height = 20;
            m_theFilterLabel.textColor = 0xFFFFFF;
            m_theFilterLabel.text = "Filter:";
            m_thePageSpriteRoot.addChild( m_theFilterLabel );

            // filter input
            m_theFilterInput = new TextField();
            m_theFilterInput.type = TextFieldType.INPUT;
            m_theFilterInput.width = 160;
            m_theFilterInput.height = 20;
            m_theFilterInput.border = true;
            m_theFilterInput.borderColor = 0xFFFFFF;
            m_theFilterInput.defaultTextFormat.font = "Terminal";
            m_theFilterInput.setTextFormat( m_theFilterInput.defaultTextFormat );
            m_theFilterInput.textColor = 0xFFFFFF;
            m_theFilterInput.useRichTextClipboard = true;
            m_thePageSpriteRoot.addChild( m_theFilterInput );

            m_theFilterInput.addEventListener( FocusEvent.FOCUS_IN, _onFilterInputKeyFocusChange );
            m_theFilterInput.addEventListener( FocusEvent.FOCUS_OUT, _onFilterInputKeyFocusChange );

            m_theKeyboard = new CKeyboard( m_theDashBoardRef.rootSpriteRef.stage );
            m_theKeyboard .registerKeyCode( true, Keyboard.ENTER, _enterKeyDown );
        }
        
        public override function dispose() : void
        {
            super.dispose();
        }

        public override function get name() : String
        {
            return "ResourceLoadersPage";
        }

        public override function set visible( bVisible : Boolean ) : void
        {
            super.visible = bVisible;

            if( m_bVisible )
            {
                if( m_theDashBoardRef.visible == true )
                {
                }
            }
            else
            {
            }
        }

        public override function onResize() : void
        {
            super.onResize();

            m_theResourceText.x = m_theDashBoardRef.pageX + 10;
            m_theResourceText.y = m_theDashBoardRef.pageY + 10;
            m_theResourceText.width = m_theDashBoardRef.pageWidth - 20 - 160 - 10;
            m_theResourceText.height = m_theDashBoardRef.pageHeight - 20;

            m_theFilterLabel.x = m_theResourceText.x + m_theResourceText.width + 10;
            m_theFilterLabel.y = m_theResourceText.y;
            m_theFilterInput.x = m_theResourceText.x + m_theResourceText.width + 10;
            m_theFilterInput.y = m_theResourceText.y + 20;
        }

        public override function update( fDeltaTime : Number ) : void
        {
            super.update( fDeltaTime );

            m_fUpdateTime += fDeltaTime;
            if( m_fUpdateTime > m_fUpdatePeriod )
            {
                m_theResourceText.htmlText = CResourceLoaders.instance().dump( true, true, m_theFilterInput.text );

                m_fUpdateTime %= m_fUpdatePeriod;
            }
        }

        private function _enterKeyDown( keyCode : int ) : void
        {
            if( m_theDashBoardRef.visible == false || this.visible == false ) return ;

            if( m_theKeyboard.exclusive == false )
            {
                m_theKeyboard.exclusive = true;
                m_theDashBoardRef.rootSpriteRef.stage.focus = m_theFilterInput;
            }
            else
            {
                if( m_theDashBoardRef.rootSpriteRef.stage.focus == m_theFilterInput )
                {
                }
                else
                {
                    m_theKeyboard.exclusive = false;
                    m_theDashBoardRef.rootSpriteRef.stage.focus = null;
                }
            }
        }

        private function _onFilterInputKeyFocusChange( e : FocusEvent ) : void
        {
            if( m_theDashBoardRef.rootSpriteRef.stage.focus == m_theFilterInput ) m_theKeyboard.exclusive = true;
            else m_theKeyboard.exclusive = false;
        }


        //
        //
        protected var m_theResourceText : TextField = null;

        protected var m_theFilterLabel : TextField = null;
        protected var m_theFilterInput : TextField = null;
        protected var m_theKeyboard : CKeyboard = null;

        protected var m_fUpdateTime : Number = 0.0;
        protected var m_fUpdatePeriod : Number = 0.1;
    }

}
