//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/5
//----------------------------------------------------------------------------------------------------------------------

package QFLib.DashBoard
{

    import QFLib.Foundation;
    import QFLib.Foundation.CKeyboard;
    import QFLib.Foundation.CLog;

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
    public class CPerformancePage extends CDashPage
    {
        public function CPerformancePage( theDashBoard : CDashBoard )
        {
            super( theDashBoard );

            m_thePerfText = new TextField();
            m_thePerfText.defaultTextFormat.font = "Terminal";
            m_thePerfText.textColor = 0xFFFFFF;
            m_thePerfText.wordWrap = true;
            m_thePerfText.multiline = true;
            m_thePerfText.border = true;
            m_thePerfText.borderColor = 0xFFFFFF;
            m_thePerfText.scrollV = m_thePerfText.numLines;
            m_thePageSpriteRoot.addChild( m_thePerfText );

            // add change size mode button
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
            m_theLayerLabel = new TextField();
            m_theLayerLabel.defaultTextFormat.font = "Terminal";
            m_theLayerLabel.width = 160;
            m_theLayerLabel.height = 20;
            m_theLayerLabel.textColor = 0xFFFFFF;
            m_theLayerLabel.text = "Layer:";
            m_thePageSpriteRoot.addChild( m_theLayerLabel );

            // layer input
            m_theLayerInput = new TextField();
            m_theLayerInput.type = TextFieldType.INPUT;
            m_theLayerInput.width = 160;
            m_theLayerInput.height = 20;
            m_theLayerInput.border = true;
            m_theLayerInput.borderColor = 0xFFFFFF;
            m_theLayerInput.defaultTextFormat.font = "Terminal";
            m_theLayerInput.setTextFormat( m_theFilterInput.defaultTextFormat );
            m_theLayerInput.textColor = 0xFFFFFF;
            m_theLayerInput.useRichTextClipboard = true;
            m_thePageSpriteRoot.addChild( m_theLayerInput );

            m_theLayerInput.addEventListener( FocusEvent.FOCUS_IN, _onLayerInputKeyFocusChange );
            m_theLayerInput.addEventListener( FocusEvent.FOCUS_OUT, _onLayerInputKeyFocusChange );

            m_theKeyboard = new CKeyboard( m_theDashBoardRef.rootSpriteRef.stage );
            m_theKeyboard .registerKeyCode( true, Keyboard.ENTER, _enterKeyDown );
        }
        
        public override function dispose() : void
        {
            super.dispose();
        }

        public override function get name() : String
        {
            return "PerformancePage";
        }

        public override function set visible( bVisible : Boolean ) : void
        {
            super.visible = bVisible;

            if( m_bVisible )
            {
                if( m_theDashBoardRef.visible == true )
                {
                    _setContinuousSnapShotState( Foundation.Perf.enabled );
                }
            }
            else
            {
            }
        }

        public override function onResize() : void
        {
            super.onResize();

            m_thePerfText.x = m_theDashBoardRef.pageX + 10;
            m_thePerfText.y = m_theDashBoardRef.pageY + 10;
            m_thePerfText.width = m_theDashBoardRef.pageWidth - 20 - 160 - 10;
            m_thePerfText.height = m_theDashBoardRef.pageHeight - 20;

            m_theFilterLabel.x = m_thePerfText.x + m_thePerfText.width + 10;
            m_theFilterLabel.y = m_thePerfText.y;
            m_theFilterInput.x = m_thePerfText.x + m_thePerfText.width + 10;
            m_theFilterInput.y = m_thePerfText.y + 20;

            m_theLayerLabel.x = m_thePerfText.x + m_thePerfText.width + 10;
            m_theLayerLabel.y = m_thePerfText.y + 40;
            m_theLayerInput.x = m_thePerfText.x + m_thePerfText.width + 10;
            m_theLayerInput.y = m_thePerfText.y + 60;

            m_theContinuousSnapshotButton.x = m_thePerfText.x + m_thePerfText.width + 10;
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
                    m_thePerfText.htmlText = Foundation.Perf.dump( true, m_theFilterInput.text, int( m_theLayerInput.text ) );
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
                    m_theDashBoardRef.rootSpriteRef.stage.focus = m_theLayerInput;
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
            if( m_theDashBoardRef.rootSpriteRef.stage.focus == m_theLayerInput ) m_theKeyboard.exclusive = true;
            else m_theKeyboard.exclusive = false;
        }

        private function _onContinuousSnapshotButtonDown( e : MouseEvent ) : void
        {
            _setContinuousSnapShotState( !m_bContinuousSnapShot );
        }

        private function _setContinuousSnapShotState( bContinuousSnapShot : Boolean ) : void
        {
            m_bContinuousSnapShot = bContinuousSnapShot;
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

        //
        //
        protected var m_thePerfText : TextField = null;

        protected var m_theFilterLabel : TextField = null;
        protected var m_theFilterInput : TextField = null;
        protected var m_theLayerLabel : TextField = null;
        protected var m_theLayerInput : TextField = null;
        protected var m_theKeyboard : CKeyboard = null;

        protected var m_theContinuousSnapshotText : TextField = null;
        protected var m_theContinuousSnapshotButton : SimpleButton = null;

        protected var m_fUpdateTime : Number = 0.0;
        protected var m_fUpdatePeriod : Number = 0.1;
        protected var m_bContinuousSnapShot : Boolean = true;
    }

}
