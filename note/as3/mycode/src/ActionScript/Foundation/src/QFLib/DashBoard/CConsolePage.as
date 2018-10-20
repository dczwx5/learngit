//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/5
//----------------------------------------------------------------------------------------------------------------------

package QFLib.DashBoard
{

    import QFLib.Foundation;
    import QFLib.Foundation.CKeyboard;
    import QFLib.Foundation.CLog;
    import QFLib.Foundation.CMap;

    import flash.events.FocusEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.ui.Keyboard;

    //
    //
    //
    public class CConsolePage extends CDashPage
    {
        public function CConsolePage( theDashBoard : CDashBoard )
        {
            super( theDashBoard );

            m_vLogTexts = new Vector.<String>( 2 );
            m_vLogTexts[ 0 ] = "";
            m_vLogTexts[ 1 ] = "";

            m_theTextInput = new TextField();
            m_theTextInput.type = TextFieldType.INPUT;
            m_theTextInput.border = true;
            m_theTextInput.borderColor = 0xFFFFFF;
            m_theTextInput.defaultTextFormat.font = "Terminal";
            m_theTextInput.setTextFormat( m_theTextInput.defaultTextFormat );
            m_theTextInput.textColor = 0xFFFFFF;
            m_theTextInput.useRichTextClipboard = true;
            m_thePageSpriteRoot.addChild( m_theTextInput );

            m_theLogText = new TextField();
            m_theLogText.defaultTextFormat.font = "Terminal";
            m_theLogText.textColor = 0xFFFFFF;
            m_theLogText.wordWrap = true;
            m_theLogText.multiline = true;
            m_theLogText.border = true;
            m_theLogText.borderColor = 0xFFFFFF;
            m_theLogText.scrollV = m_theLogText.numLines;

            m_thePageSpriteRoot.addChild( m_theLogText );

            m_theKeyboard = new CKeyboard( m_theDashBoardRef.rootSpriteRef.stage );
            m_theKeyboard .register( true, _onKeyDown );

            m_theTextInput.addEventListener( FocusEvent.FOCUS_IN, _onKeyFocusChange );
            m_theTextInput.addEventListener( FocusEvent.FOCUS_OUT, _onKeyFocusChange );

            configureLog();
        }

        public override function dispose() : void
        {
            if( m_theKeyboard )
            {
                m_theKeyboard.dispose();
                m_theKeyboard = null;
            }

            super.dispose();
        }

        protected function configureLog() : void {
            Foundation.Log.setCustomLogFunction( customLogOut );
        }

        public override function get name() : String
        {
            return "ConsolePage";
        }

        [Inline]
        public final function get popUpLogLevel() : int
        {
            return m_iPopUpLogLevel;
        }
        [Inline]
        public final function set popUpLogLevel( iPopUpLogLevel : int ) : void
        {
            m_iPopUpLogLevel = iPopUpLogLevel;
        }

        public override function set visible( bVisible : Boolean ) : void
        {
            super.visible = bVisible;

            if( m_bVisible )
            {
                if( m_theDashBoardRef.visible == true )
                {
                    m_theLogText.htmlText = m_vLogTexts[ 0 ] + m_vLogTexts[ 1 ];
                    m_theLogText.scrollV = m_theLogText.numLines;
                }
            }
            else
            {
                m_theKeyboard.exclusive = false;
            }
        }

        public override function onResize() : void
        {
            super.onResize();

            var iTextInputHeight : int = 30;
            m_theLogText.x = m_theDashBoardRef.pageX + 10;
            m_theLogText.y = m_theDashBoardRef.pageY + 10;
            m_theLogText.width = m_theDashBoardRef.pageWidth - 20;
            m_theLogText.height = m_theDashBoardRef.pageHeight - 20 - iTextInputHeight;

            m_theTextInput.x = m_theDashBoardRef.pageX + 10;
            m_theTextInput.y = m_theDashBoardRef.pageY + m_theDashBoardRef.pageHeight - iTextInputHeight;
            m_theTextInput.width = m_theDashBoardRef.pageWidth - 20;
            m_theTextInput.height = iTextInputHeight - 10;
        }

        public function clearLogs() : void
        {
            for( var i : int = 0; i < m_vLogTexts.length; i++ )
            {
                m_vLogTexts[ i ] = "";
            }
            m_theLogText.htmlText = "";
        }

        //
        // function onCommand( aCommands : Array ) : void
        //
        [Inline]
        public function get commandHandler() : CConsoleCommandHandler
        {
            return m_theCommandHandler;
        }

        public override function update( fDeltaTime : Number ) : void
        {
            super.update( fDeltaTime );
        }

        //
        private function _onKeyDown( keyCode : int ) : void
        {
            if( keyCode == Keyboard.TAB ) _tabKeyDown( keyCode );
            else
            {
                m_iTabCandidateCommandIdx = -1;
                m_sTabText = null;

                if( keyCode == Keyboard.ENTER ) _enterKeyDown( keyCode );
                else if( keyCode == Keyboard.UP ) _upKeyDown( keyCode );
                else if( keyCode == Keyboard.DOWN ) _downKeyDown( keyCode );
            }
        }

        private function _enterKeyDown( keyCode : int ) : void
        {
            if( m_theDashBoardRef.visible == false || this.visible == false ) return ;

            if( m_theKeyboard.exclusive == false )
            {
                m_theKeyboard.exclusive = true;
                m_theDashBoardRef.rootSpriteRef.stage.focus = m_theTextInput;
                m_theDashBoardRef.tabEnable = false;
            }
            else
            {
                m_theKeyboard.exclusive = false;
                m_theDashBoardRef.rootSpriteRef.stage.focus = null;
                m_theDashBoardRef.tabEnable = true;

                if( m_theTextInput.text.length != 0 )
                {
                    m_theCommandHandler.parseCommand( m_theTextInput.text );

                    m_vCommandList.push( m_theTextInput.text );
                    if( m_vCommandList.length > 20 ) m_vCommandList.shift();

                    m_iCandidateCommandIdx = m_vCommandList.length;
                }

                m_theTextInput.text = "";
                m_sTemporalCommand = "";
            }
        }

        private function _onKeyFocusChange( e : FocusEvent ) : void
        {
            if( m_theDashBoardRef.rootSpriteRef.stage.focus == m_theTextInput )
            {
                m_theKeyboard.exclusive = true;
                m_theDashBoardRef.tabEnable = false;
            }
            else
            {
                m_theKeyboard.exclusive = false;
                m_theDashBoardRef.tabEnable = true;
            }
        }

        private function _upKeyDown( keyCode : int ) : void
        {
            if( m_theDashBoardRef.rootSpriteRef.stage.focus != m_theTextInput ) return ;
            if( m_vCommandList.length == 0 ) return ;

            if( m_iCandidateCommandIdx == m_vCommandList.length ) m_sTemporalCommand = m_theTextInput.text;
            m_iCandidateCommandIdx--;
            if( m_iCandidateCommandIdx < 0 ) m_iCandidateCommandIdx = m_vCommandList.length;

            if( m_iCandidateCommandIdx == m_vCommandList.length ) m_theTextInput.text = m_sTemporalCommand;
            else m_theTextInput.text = m_vCommandList[ m_iCandidateCommandIdx ];

            m_theTextInput.setSelection( m_theTextInput.length, m_theTextInput.length );
        }

        private function _downKeyDown( keyCode : int ) : void
        {
            if( m_theDashBoardRef.rootSpriteRef.stage.focus != m_theTextInput ) return ;
            if( m_vCommandList.length == 0 ) return ;

            if( m_iCandidateCommandIdx == m_vCommandList.length ) m_sTemporalCommand = m_theTextInput.text;
            m_iCandidateCommandIdx++;
            if( m_iCandidateCommandIdx > m_vCommandList.length ) m_iCandidateCommandIdx = 0;

            if( m_iCandidateCommandIdx == m_vCommandList.length ) m_theTextInput.text = m_sTemporalCommand;
            else m_theTextInput.text = m_vCommandList[ m_iCandidateCommandIdx ];

            m_theTextInput.setSelection( m_theTextInput.length, m_theTextInput.length );
        }

        private function _tabKeyDown( keyCode : int ) : void
        {
            if( m_theDashBoardRef.rootSpriteRef.stage.focus != m_theTextInput ) return ;

            var aRegisteredCommands : Array = m_theCommandHandler.commandMap.toArray();
            if( aRegisteredCommands.length == 0 ) return ;
            aRegisteredCommands.sort( Array.CASEINSENSITIVE );

            if( m_sTabText == null )
            {
                m_sTabText = m_theTextInput.text;
            }

            var i : int;
            var sFirstMatchedIdx : int = -1;
            for( i = 0; i < aRegisteredCommands.length; i++ )
            {
                if( aRegisteredCommands[i].name.indexOf( m_sTabText ) == 0 )
                {
                    if( sFirstMatchedIdx == -1 ) sFirstMatchedIdx = i;

                    if( i > m_iTabCandidateCommandIdx )
                    {
                        m_iTabCandidateCommandIdx = i;
                        break;
                    }
                }
            }

            if( i == aRegisteredCommands.length ) // not found
            {
                if( sFirstMatchedIdx != -1 ) m_iTabCandidateCommandIdx = sFirstMatchedIdx;
                else m_iTabCandidateCommandIdx = -1;
            }

            if( m_iTabCandidateCommandIdx != -1 )
            {
                m_theTextInput.text = aRegisteredCommands[ m_iTabCandidateCommandIdx ].name;
            }
            else m_theTextInput.text = "";

            m_theTextInput.setSelection( m_theTextInput.length, m_theTextInput.length );
            //m_theDashBoardRef.rootSpriteRef.stage.focus = m_theTextInput;
        }

        protected function customLogOut( iLogLevel : int, sTime : String, s : String, sLogFullMsg : String ) : void
        {
            var bForceScrollV : Boolean = m_theLogText.scrollV == m_theLogText.maxScrollV;

            if( iLogLevel >= m_iPopUpLogLevel ) m_theDashBoardRef.visible = true;

            if( iLogLevel == CLog.LOG_LEVEL_ERROR ) m_vLogTexts[ 1 ] += "<font face =\"Terminal\" size=\"" + m_iFontSize + "\" color=\"#FF0000\">" + sLogFullMsg + "</font>\n";
            else if( iLogLevel == CLog.LOG_LEVEL_WARNING ) m_vLogTexts[ 1 ] += "<font face =\"Terminal\" size=\"" + m_iFontSize + "\" color=\"#FFFF00\">" + sLogFullMsg + "</font>\n";
            else if( iLogLevel == CLog.LOG_LEVEL_NORMAL ) m_vLogTexts[ 1 ] += "<font face =\"Terminal\" size=\"" + m_iFontSize + "\" color=\"#FFFFFF\">" + sLogFullMsg + "</font>\n";
            else m_vLogTexts[ 1 ] += "<font face =\"Terminal\" size=\"" + m_iFontSize + "\" color=\"#777777\">" + sLogFullMsg + "</font>\n";

            m_iLogLineCounter++;
            if( m_iLogLineCounter >= m_iMaxLogLines )
            {
                m_vLogTexts.shift();
                m_vLogTexts.push( "" );
                m_iLogLineCounter = 0;
            }

            if( this.visible && m_theDashBoardRef.visible )
            {
                m_theLogText.htmlText = m_vLogTexts[ 0 ] + m_vLogTexts[ 1 ];
                if ( bForceScrollV )
                    m_theLogText.scrollV = m_theLogText.numLines;
            }
        }

        //
        //
        protected var m_theLogText : TextField = null;
        protected var m_theTextInput : TextField = null;
        protected var m_vLogTexts : Vector.<String> = null;
        protected var m_iFontSize : int = 12;

        protected var m_iLogLineCounter : int = 0;
        protected var m_iMaxLogLines : int = 300;

        protected var m_iPopUpLogLevel : int = CLog.LOG_LEVEL_WARNING;

        protected var m_vCommandList : Vector.<String> = new Vector.<String>();
        protected var m_sTemporalCommand : String = "";
        protected var m_iCandidateCommandIdx : int = 0;

        protected var m_sTabText : String = null;
        protected var m_iTabCandidateCommandIdx : int = -1;

        protected var m_theKeyboard : CKeyboard;
        protected var m_theCommandHandler : CConsoleCommandHandler = new CConsoleCommandHandler( this );
    }

}
