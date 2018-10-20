//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/5
//----------------------------------------------------------------------------------------------------------------------

package QFLib.DashBoard
{
    import QFLib.Foundation;
    import QFLib.Foundation.*;

    import QFLib.Memory.CSmartObject;

    import flash.display.DisplayObjectContainer;
    import flash.display.SimpleButton;

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;
    import flash.utils.Timer;

//
    //
    //
    public class CDashBoard extends CSmartObject
    {
        public function CDashBoard( theRoot : DisplayObjectContainer, fOpaque : Number = 0.6, fFPS : Number = 0.0 /* set fFPS to non-zero if you want this class call Update() itself */ )
        {
            m_fFPS = fFPS;
            if( fFPS > 0.0 ) _startTimer();

            m_iPageX = 0;
            m_iPageY = 20;
            m_fOpaque = fOpaque;
            m_theRootRef = theRoot;

            // add background board
            m_theBoardSprite = new Sprite();
            m_theRootRef.addChild( m_theBoardSprite );
            m_theBoardSprite.visible = m_bVisible;

            // add page number text
            m_thePageNumberText = new TextField();
            m_thePageNumberText.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
            m_thePageNumberText.x = 10;
            m_thePageNumberText.y = 5;
            m_thePageNumberText.width = 160;
            m_thePageNumberText.height = 20;
            m_thePageNumberText.textColor = 0xFFFFFF;
            m_thePageNumberText.border = true;
            m_thePageNumberText.borderColor = 0xFFFFFF;
            m_theBoardSprite.addChild( m_thePageNumberText );

            // add page name text
            m_thePageNameText = new TextField();
            m_thePageNameText.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
            m_thePageNameText.x = 0;
            m_thePageNameText.y = 5;
            m_thePageNameText.width = 220;
            m_thePageNameText.height = 20;
            m_thePageNameText.textColor = 0xFFFFFF;
            m_thePageNameText.border = true;
            m_thePageNameText.borderColor = 0xFFFFFF;
            m_theBoardSprite.addChild( m_thePageNameText );

            // add change size mode button
            m_theDashBoardSizeModeBtnText = new TextField();
            m_theDashBoardSizeModeBtnText.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
            m_theDashBoardSizeModeBtnText.x = 0;
            m_theDashBoardSizeModeBtnText.y = 5;
            m_theDashBoardSizeModeBtnText.width = 160;
            m_theDashBoardSizeModeBtnText.height = 20;
            m_theDashBoardSizeModeBtnText.textColor = 0xFFFFFF;
            m_theDashBoardSizeModeBtnText.border = true;
            m_theDashBoardSizeModeBtnText.borderColor = 0xFFFFFF;
            m_theDashBoardSizeModeBtnText.text = "Resize";
            m_theDashBoardSizeModeButton = new SimpleButton( m_theDashBoardSizeModeBtnText, m_theDashBoardSizeModeBtnText, m_theDashBoardSizeModeBtnText, m_theDashBoardSizeModeBtnText );
            m_theBoardSprite.addChild( m_theDashBoardSizeModeButton );
            m_theDashBoardSizeModeButton.addEventListener( MouseEvent.MOUSE_DOWN, _onBoardSizeModeButtonDown );

            // initialize keyboard
            m_theKeyboard = new CKeyboard( m_theRootRef.stage );
            m_theKeyboard .registerKeyCode( true, Keyboard.PAGE_DOWN, _pageDownKeyDown );
            m_theKeyboard .registerKeyCode( true, Keyboard.PAGE_UP, _pageUpKeyDown );

            // add default panels
            addPage( new CConsolePage( this ) );
            addPage( new CPerformancePage( this ) );
            addPage( new CResourceCachePage( this ) );
            addPage( new CResourceLoadersPage( this ) );
            _redrawPanel( false );
        }
        
        public override function dispose() : void
        {
            if( m_theKeyboard )
            {
                m_theKeyboard.dispose();
                m_theKeyboard = null;
            }

            super.dispose();

            this._stopTimer();
            m_theEventTimer = null;
        }

        [Inline]
        final public function get visible() : Boolean
        {
            return m_bVisible;
        }
        public function set visible( bVisible : Boolean ) : void
        {
            if( m_bVisible == bVisible ) return ;

            // make sure rgw dash board at the top always
            if(m_theBoardSprite.parent && m_theBoardSprite.parent == m_theRootRef){
                m_theRootRef.removeChild( m_theBoardSprite );
            }

            m_theRootRef.addChild( m_theBoardSprite );

            m_bVisible = bVisible;
            _setVisibleProcess( bVisible );
        }

        [Inline]
        final public function get tabEnable() : Boolean
        {
            return m_bTabEnable;
        }
        public function set tabEnable( bEnable : Boolean ) : void
        {
            if( m_bTabEnable == bEnable ) return ;

            m_theDashBoardSizeModeButton.tabEnabled = bEnable;

            m_bTabEnable = bEnable;
        }

        public function setTheDashBoardSize(index:int ):void{
            m_iCurrentBoardSizeMode = index;
            _redrawPanel(false);
        }

        [Inline]
        final public function get pageX() : int
        {
            return m_iPageX;
        }
        [Inline]
        final public function get pageY() : int
        {
            return m_iPageY;
        }
        [Inline]
        final public function get pageWidth() : int
        {
            return m_iPageWidth;
        }
        [Inline]
        final public function get pageHeight() : int
        {
            return m_iPageHeight;
        }

        [Inline]
        final public function get boardWidth() : int
        {
            return m_iBoardWidth;
        }
        [Inline]
        final public function get boardHeight() : int
        {
            return m_iBoardHeight;
        }

        [Inline]
        final public function get rootSpriteRef() : DisplayObjectContainer
        {
            return m_theRootRef;
        }

        public function addPage( thePage : CDashPage, iIdx : int = -1 ) : void
        {
            if( this.findPage( thePage.name ) != null )
            {
                Foundation.Log.logErrorMsg( "fail adding a duplicated page: " + thePage.name );
                return ;
            }

            thePage.visible = false;
            m_vPages.push( thePage );
            this.setActivePage( m_iCurrentPageIdx, false );
        }

        public function findPage( pageClassName : String ) : CDashPage
        {
            for each( var page : CDashPage in m_vPages )
            {
                if( page.name == pageClassName ) return page;
            }

            return null;
        }
        public function findPageByClass(clazz:Class) : CDashPage {
            for each(var page:CDashPage in m_vPages) {
                if( page is clazz) return page;
            }
            return null;
        }

        public function prevPage() : void
        {
            var iPageIdx : int = this.activePageIndex - 1;
            if( iPageIdx < 0 ) iPageIdx = m_vPages.length - 1;
            this.setActivePage( iPageIdx );
        }

        public function nextPage() : void
        {
            var iPageIdx : int = this.activePageIndex + 1;
            if( iPageIdx >= m_vPages.length ) iPageIdx = 0;
            this.setActivePage( iPageIdx );
        }

        [Inline]
        final public function get activePageIndex() : int
        {
            return m_iCurrentPageIdx;
        }
        public function setActivePage( iPageIdx : int, bCheck : Boolean = true ) : void
        {
            if( m_iCurrentPageIdx == iPageIdx && bCheck ) return ;

            if( m_iCurrentPageIdx < m_vPages.length ) m_vPages[ m_iCurrentPageIdx ].visible = false;
            if( iPageIdx < m_vPages.length )
            {
                m_iCurrentPageIdx = iPageIdx;
                m_vPages[ m_iCurrentPageIdx ].visible = true;
                _redrawPanel( true );
            }
        }

        [Inline]
        final public function get boardSprite() : Sprite
        {
            return m_theBoardSprite;
        }

        public function update( fDeltaTime : Number ) : void
        {
            Foundation.Perf.sectionBegin( "DashBoard_Update" );

            if( m_bVisible )
            {
                _redrawPanel( false );

                if ( m_iCurrentPageIdx < m_vPages.length )
                {
                    m_vPages[ m_iCurrentPageIdx ].update( fDeltaTime );
                }
            }

            //
            if( m_fTimeCountdown != 0.0 && m_theBoardSprite != null )
            {
                var fDis : Number;

                if( m_fTimeCountdown > 0.0 ) // roll down
                {
                    m_fTimeCountdown -= fDeltaTime * 4.0;
                    if( m_fTimeCountdown < 0.0 ) m_fTimeCountdown = 0.0;

                    fDis = Math.cos( m_fTimeCountdown * Math.PI * 0.5 );
                    m_theBoardSprite.y = ( fDis * m_iBoardHeight ) - m_iBoardHeight;
                }
                else // roll up
                {
                    m_fTimeCountdown += fDeltaTime * 4.0;
                    if( m_fTimeCountdown > 0.0 )
                    {
                        m_fTimeCountdown = 0.0;
                        m_theBoardSprite.visible = false;
                        if( m_iCurrentPageIdx < m_vPages.length ) m_vPages[ m_iCurrentPageIdx ].visible = false;
                    }
                    else
                    {
                        fDis = Math.cos( -m_fTimeCountdown * Math.PI * 0.5 );
                        m_theBoardSprite.y = -fDis * m_iBoardHeight;
                    }
                }
            }

            Foundation.Perf.sectionEnd( "DashBoard_Update" );
        }

        //
        private function _onTimer( e:TimerEvent ) : void
        {
            var fDeltaTime : Number = m_theTimer.seconds();
            m_theTimer.reset();

            update( fDeltaTime );
        }

        private function _redrawPanel( bForceRedraw : Boolean ) : void
        {
            // set page number and name
            m_thePageNumberText.text = "Page: ";
            m_thePageNumberText.text += m_iCurrentPageIdx + 1;
            m_thePageNumberText.text += " of ";
            m_thePageNumberText.text += m_vPages.length;
            m_thePageNameText.text = m_vPages[ m_iCurrentPageIdx ].name;

            // set the dash board size
            var fRatio : Number;
            if( m_iCurrentBoardSizeMode == 0 )
            {
                m_theDashBoardSizeModeBtnText.text = "Small";
                fRatio = 4.0;
            }
            else if( m_iCurrentBoardSizeMode == 1 )
            {
                m_theDashBoardSizeModeBtnText.text = "Medium";
                fRatio = 2.0;
            }
            else
            {
                m_theDashBoardSizeModeBtnText.text = "Large";
                fRatio = 1.33;
            }

            var iWidth : int = m_theRootRef.stage.stageWidth;
            var iHeight : int = m_theRootRef.stage.stageHeight / fRatio;
            if( bForceRedraw || ( m_iBoardWidth != iWidth || m_iBoardHeight != iHeight ) )
            {
                // set the position of page name & size mode button
                m_thePageNameText.x = ( iWidth - m_thePageNameText.width ) / 2;
                m_thePageNameText.y = 5;
                m_theDashBoardSizeModeButton.x = iWidth - 160 - 10;
                m_theDashBoardSizeModeButton.y = 0;

                // draw board sprite range
                m_theBoardSprite.graphics.clear();
                m_theBoardSprite.graphics.beginFill( 0x151020, m_fOpaque );
                m_theBoardSprite.graphics.drawRect( 0, 0, iWidth, iHeight );

                m_iPageWidth = iWidth - m_iPageX;
                m_iPageHeight = iHeight - m_iPageY;
                m_iBoardWidth = iWidth;
                m_iBoardHeight = iHeight;

                if( m_iCurrentPageIdx < m_vPages.length ) m_vPages[ m_iCurrentPageIdx ].onResize();
            }
        }

        private function _startTimer() : void
        {
            if (!m_theEventTimer && m_fFPS > 0.0)
                m_theEventTimer = new Timer( Number(1.0 / m_fFPS) );

            if (m_theEventTimer && !m_theEventTimer.running) {
                m_theEventTimer.addEventListener( TimerEvent.TIMER, _onTimer );
                m_theEventTimer.start();

                m_theTimer = new CTimer();
            }
        }

        private function _stopTimer() : void
        {
            if (m_theEventTimer) {
                m_theEventTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
                m_theEventTimer.stop();

                m_theTimer = null;
            }
        }

        private function _setVisibleProcess( bVisible : Boolean ) : void
        {
            if( bVisible )
            {
                m_theBoardSprite.y = -m_iPageHeight;
                if( m_fTimeCountdown == 0.0 ) m_fTimeCountdown = 1.0;
                else if( m_fTimeCountdown < 0.0 ) m_fTimeCountdown = -m_fTimeCountdown;

                m_theBoardSprite.visible = true;
                this.setActivePage( m_iCurrentPageIdx, false );
            }
            else
            {
                m_theBoardSprite.y = 0;
                if( m_fTimeCountdown == 0.0 ) m_fTimeCountdown = -1.0;
                else if( m_fTimeCountdown > 0.0 ) m_fTimeCountdown = -m_fTimeCountdown;
            }
        }

        private function _pageUpKeyDown( keyCode : int ) : void
        {
            if( this.visible ) prevPage();
        }

        private function _pageDownKeyDown( keyCode : int ) : void
        {
            if( this.visible ) nextPage();
        }

        private function _onBoardSizeModeButtonDown( e : MouseEvent ) : void
        {
            m_iCurrentBoardSizeMode++;
            if( m_iCurrentBoardSizeMode > 2 ) m_iCurrentBoardSizeMode = 0;
            _redrawPanel( false );
        }

        //
        //
        protected var m_vPages : Vector.<CDashPage> = new Vector.<CDashPage>();
        protected var m_iCurrentPageIdx : int = 0;
        protected var m_iCurrentBoardSizeMode : int = 0;
        protected var m_bVisible : Boolean = false;
        protected var m_bTabEnable : Boolean = true;
        protected var m_iPageX : int = 0;
        protected var m_iPageY : int = 0;
        protected var m_iPageWidth : int = 0;
        protected var m_iPageHeight : int = 0;
        protected var m_iBoardWidth : int = 0;
        protected var m_iBoardHeight : int = 0;
        protected var m_fOpaque : Number = 0.5;
        protected var m_fTimeCountdown : Number = 0.0;

        protected var m_theRootRef : DisplayObjectContainer = null;
        protected var m_theBoardSprite : Sprite = null;

        protected var m_thePageNumberText : TextField = null;
        protected var m_thePageNameText : TextField = null;

        protected var m_theDashBoardSizeModeBtnText : TextField = null;
        protected var m_theDashBoardSizeModeButton : SimpleButton = null;

        protected var m_theKeyboard : CKeyboard = null;

        private var m_theEventTimer: Timer = null;
        private var m_theTimer: CTimer = null;
        private var m_fFPS : Number;
    }

}

