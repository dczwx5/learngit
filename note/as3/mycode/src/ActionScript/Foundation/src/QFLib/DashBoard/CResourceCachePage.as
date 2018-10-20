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
    public class CResourceCachePage extends CDashPage
    {
        public function CResourceCachePage( theDashBoard : CDashBoard )
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

            // add continuous snapshot button
            m_theContinuousSnapshotText = new TextField();
            m_theContinuousSnapshotText.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
            m_theContinuousSnapshotText.width = 160;
            m_theContinuousSnapshotText.height = 20;
            m_theContinuousSnapshotText.textColor = 0xFFFFFF;
            m_theContinuousSnapshotText.border = true;
            m_theContinuousSnapshotText.borderColor = 0xFFFFFF;
            m_theContinuousSnapshotText.text = "Continuous Snapshot";
            m_theContinuousSnapshotButton = new SimpleButton( m_theContinuousSnapshotText, m_theContinuousSnapshotText, m_theContinuousSnapshotText, m_theContinuousSnapshotText );
            m_thePageSpriteRoot.addChild( m_theContinuousSnapshotButton );
            m_theContinuousSnapshotButton.addEventListener( MouseEvent.MOUSE_DOWN, _onContinuousSnapshotButtonDown );

            // add continuous snapshot button
            m_theSortText = new TextField();
            m_theSortText.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
            m_theSortText.width = 160;
            m_theSortText.height = 20;
            m_theSortText.textColor = 0xFFFFFF;
            m_theSortText.border = true;
            m_theSortText.borderColor = 0xFFFFFF;
            m_theSortText.text = "Sorted by Name";
            m_theSortButton = new SimpleButton( m_theSortText, m_theSortText, m_theSortText, m_theSortText );
            m_thePageSpriteRoot.addChild( m_theSortButton );
            m_theSortButton.addEventListener( MouseEvent.MOUSE_DOWN, _onSortButtonDown );

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

            // layer label
            m_theCountLabel = new TextField();
            m_theCountLabel.defaultTextFormat.font = "Terminal";
            m_theCountLabel.width = 160;
            m_theCountLabel.height = 20;
            m_theCountLabel.textColor = 0xFFFFFF;
            m_theCountLabel.text = "Counts(<,=,>):";
            m_thePageSpriteRoot.addChild( m_theCountLabel );

            // layer input
            m_theCountInput = new TextField();
            m_theCountInput.type = TextFieldType.INPUT;
            m_theCountInput.width = 160;
            m_theCountInput.height = 20;
            m_theCountInput.border = true;
            m_theCountInput.borderColor = 0xFFFFFF;
            m_theCountInput.defaultTextFormat.font = "Terminal";
            m_theCountInput.setTextFormat( m_theFilterInput.defaultTextFormat );
            m_theCountInput.textColor = 0xFFFFFF;
            m_theCountInput.useRichTextClipboard = true;
            m_thePageSpriteRoot.addChild( m_theCountInput );

            m_theCountInput.addEventListener( FocusEvent.FOCUS_IN, _onLayerInputKeyFocusChange );
            m_theCountInput.addEventListener( FocusEvent.FOCUS_OUT, _onLayerInputKeyFocusChange );

            m_theKeyboard = new CKeyboard( m_theDashBoardRef.rootSpriteRef.stage );
            m_theKeyboard .registerKeyCode( true, Keyboard.ENTER, _enterKeyDown );
        }
        
        public override function dispose() : void
        {
            super.dispose();
        }

        public override function get name() : String
        {
            return "ResourceCachePage";
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

            m_theCountLabel.x = m_theResourceText.x + m_theResourceText.width + 10;
            m_theCountLabel.y = m_theResourceText.y + 40;
            m_theCountInput.x = m_theResourceText.x + m_theResourceText.width + 10;
            m_theCountInput.y = m_theResourceText.y + 60;

            m_theSortButton.x = m_theResourceText.x + m_theResourceText.width + 10;
            m_theSortButton.y = m_theResourceText.y + 100;

            m_theContinuousSnapshotButton.x = m_theResourceText.x + m_theResourceText.width + 10;
            m_theContinuousSnapshotButton.y = m_theDashBoardRef.pageY + m_theDashBoardRef.pageHeight - 20 - 10;
        }

        public override function update( fDeltaTime : Number ) : void
        {
            super.update( fDeltaTime );

            if( m_bContinuousSnapShot )
            {
                m_fUpdateTime += fDeltaTime;
                if( m_fUpdateTime > m_fUpdatePeriod )
                {
                    // separate the condition and the number
                    var sCountInput : String = "";
                    var sCountCondition : String = "";
                    var iLastIndex : int = m_theCountInput.text.lastIndexOf( "<" );
                    var iLastIndex2 : int = m_theCountInput.text.lastIndexOf( "=" );
                    var iLastIndex3 : int = m_theCountInput.text.lastIndexOf( ">" );
                    if( iLastIndex < iLastIndex2 ) iLastIndex = iLastIndex2;
                    if( iLastIndex < iLastIndex3 ) iLastIndex = iLastIndex3;
                    if( iLastIndex >= 0 )
                    {
                        sCountInput = m_theCountInput.text.substr( iLastIndex + 1 );
                        sCountCondition = m_theCountInput.text.substr( 0, iLastIndex + 1 );
                    }
                    else
                    {
                        sCountInput = m_theCountInput.text;
                        sCountCondition = null;
                    }

                    m_theResourceText.htmlText = CResourceCache.instance().dump( true, true, m_theFilterInput.text, int( sCountInput ), sCountCondition, m_iSortMethod );
                    m_fUpdateTime %= m_fUpdatePeriod;
                }
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
                    m_theDashBoardRef.rootSpriteRef.stage.focus = m_theCountInput;
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

        private function _onLayerInputKeyFocusChange( e : FocusEvent ) : void
        {
            if( m_theDashBoardRef.rootSpriteRef.stage.focus == m_theCountInput ) m_theKeyboard.exclusive = true;
            else m_theKeyboard.exclusive = false;
        }

        private function _onContinuousSnapshotButtonDown( e : MouseEvent ) : void
        {
            m_bContinuousSnapShot = !m_bContinuousSnapShot;
            if( m_bContinuousSnapShot )
            {
                Foundation.Perf.enabled = true;
                m_theContinuousSnapshotText.text = "Continuous Snapshot";
            }
            else
            {
                Foundation.Perf.enabled = false;
                m_theContinuousSnapshotText.text = "Snapshot Paused";
            }
        }

        private function _onSortButtonDown( e : MouseEvent ) : void
        {
            m_iSortMethod++;
            if( m_iSortMethod > 2 ) m_iSortMethod = 0;

            if( m_iSortMethod == 0 )
            {
                m_theSortText.text = "Sorted by Name";
            }
            else if( m_iSortMethod == 1 )
            {
                m_theSortText.text = "Sorted by TimeStamp";
            }
            else if( m_iSortMethod == 2 )
            {
                m_theSortText.text = "Sorted by RefCount";
            }
        }

        //
        //
        protected var m_theResourceText : TextField = null;

        protected var m_theFilterLabel : TextField = null;
        protected var m_theFilterInput : TextField = null;
        protected var m_theCountLabel : TextField = null;
        protected var m_theCountInput : TextField = null;
        protected var m_theKeyboard : CKeyboard = null;

        protected var m_theSortText : TextField = null;
        protected var m_theSortButton : SimpleButton = null;

        protected var m_theContinuousSnapshotText : TextField = null;
        protected var m_theContinuousSnapshotButton : SimpleButton = null;

        protected var m_fUpdateTime : Number = 0.0;
        protected var m_fUpdatePeriod : Number = 0.1;
        protected var m_bContinuousSnapShot : Boolean = true;
        protected var m_iSortMethod : int = 0;
    }

}
