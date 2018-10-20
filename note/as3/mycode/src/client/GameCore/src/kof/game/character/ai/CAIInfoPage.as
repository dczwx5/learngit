//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/29.
 * Time: 10:58
 */
package kof.game.character.ai {

    import QFLib.DashBoard.CConsolePage;
    import QFLib.DashBoard.CDashBoard;
    import QFLib.Foundation.CLog;

    import flash.display.SimpleButton;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    public class CAIInfoPage extends CConsolePage {
        public function CAIInfoPage( theDashBoard : CDashBoard, pLog : CLog ) {
            this.m_pAILog = pLog;
            super( theDashBoard );
            m_pIdLabel = new TextField();
            m_pIdLabel.defaultTextFormat.font = "Terminal";
            m_pIdLabel.width = 160;
            m_pIdLabel.height = 20;
            m_pIdLabel.textColor = 0xFFFFFF;
            m_pIdLabel.text = "当前场景中的活动角色:";
            m_thePageSpriteRoot.addChild( m_pIdLabel );

            m_pIdText = new TextField();
            m_pIdText.width = 320;
            m_pIdText.height = 260;
            m_pIdText.multiline = true;
            m_pIdText.border = true;
            m_pIdText.borderColor = 0xFFFFFF;
            m_pIdText.defaultTextFormat.font = "Terminal";
            m_pIdText.setTextFormat( m_pIdText.defaultTextFormat );
            m_pIdText.textColor = 0xFFFFFF;
            m_pIdText.useRichTextClipboard = true;
            m_theLogText.scrollV = m_theLogText.numLines;
            m_thePageSpriteRoot.addChild( m_pIdText );

            m_pFilterLabel = new TextField();
            m_pFilterLabel.defaultTextFormat.font = "Terminal";
            m_pFilterLabel.width = 160;
            m_pFilterLabel.height = 20;
            m_pFilterLabel.textColor = 0xFFFFFF;
            m_pFilterLabel.text = "输入要查看的角色ID:";
            m_thePageSpriteRoot.addChild( m_pFilterLabel );

            m_pFilterInputText = new TextField();
            m_pFilterInputText.width = 160;
            m_pFilterInputText.height = 20;
            m_pFilterInputText.border = true;
            m_pFilterInputText.borderColor = 0xFFFFFF;
            m_pFilterInputText.defaultTextFormat.font = "Terminal";
            m_pFilterInputText.setTextFormat( m_pFilterInputText.defaultTextFormat );
            m_pFilterInputText.textColor = 0xFFFFFF;
            m_pFilterInputText.useRichTextClipboard = true;
            m_pFilterInputText.type = TextFieldType.INPUT;
            m_thePageSpriteRoot.addChild( m_pFilterInputText );

            // add change size mode button
            m_theContinuousSnapshotText = new TextField();
            m_theContinuousSnapshotText.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
            m_theContinuousSnapshotText.width = 160;
            m_theContinuousSnapshotText.height = 20;
            m_theContinuousSnapshotText.textColor = 0xFFFFFF;
            m_theContinuousSnapshotText.border = true;
            m_theContinuousSnapshotText.borderColor = 0xFFFFFF;
            m_theContinuousSnapshotText.text = "Continuous";
            m_theContinuousSnapshotButton = new SimpleButton( m_theContinuousSnapshotText, m_theContinuousSnapshotText, m_theContinuousSnapshotText, m_theContinuousSnapshotText );
            m_thePageSpriteRoot.addChild( m_theContinuousSnapshotButton );
            m_theContinuousSnapshotButton.addEventListener( MouseEvent.MOUSE_DOWN, _onContinuousButtonDown );
        }

        [Inline]
        override final protected function configureLog() : void {
            m_pAILog.setCustomLogFunction( customLogOut );
        }

        [Inline]
        override final public function get name() : String {
            return "AIInfoPage";
        }

        [Inline]
        override final public function onResize() : void {
            var iTextInputHeight : int = 30;
            m_theLogText.x = m_theDashBoardRef.pageX + 10;
            m_theLogText.y = m_theDashBoardRef.pageY + 10;
            m_theLogText.width = m_theDashBoardRef.pageWidth - 20 - 360 - 10;
            m_theLogText.height = m_theDashBoardRef.pageHeight - 20 - iTextInputHeight;

            m_theTextInput.x = m_theDashBoardRef.pageX + 10;
            m_theTextInput.y = m_theDashBoardRef.pageY + m_theDashBoardRef.pageHeight - iTextInputHeight;
            m_theTextInput.width = m_theDashBoardRef.pageWidth - 20;
            m_theTextInput.height = iTextInputHeight - 10;

            m_pIdLabel.x = m_theLogText.x + m_theLogText.width + 10;
            m_pIdLabel.y = m_theLogText.y;
            m_pIdText.x = m_theLogText.x + m_theLogText.width + 10;
            m_pIdText.y = m_theLogText.y + 20;

            m_pFilterLabel.x = m_theLogText.x + m_theLogText.width + 10;
            m_pFilterLabel.y = m_theTextInput.y - 55;
            m_pFilterInputText.x = m_theLogText.x + m_theLogText.width + 10;
            m_pFilterInputText.y = m_theTextInput.y - 30;

            m_theContinuousSnapshotText.x = m_pFilterInputText.x + m_pFilterInputText.width + 10;
            m_theContinuousSnapshotText.y = m_pFilterInputText.y;

            m_pIdText.height = m_pFilterLabel.y - 55;

        }

        [Inline]
        override final public function update( fDeltaTime : Number ) : void {
            super.update( fDeltaTime );
            if ( m_bContinuous ) {
                m_fUpdateTime += fDeltaTime;
                if ( m_fUpdateTime > m_fUpdatePeriod ) {
                    m_pIdText.htmlText = CAILog.printObjID();
                    m_fUpdateTime %= m_fUpdatePeriod;
                    CAILog.sIdTxt = m_pFilterInputText.text;
                }
            }
        }

        [Inline]
        private function _onContinuousButtonDown( e : MouseEvent ) : void {
            m_bContinuous = !m_bContinuous;
            if ( m_bContinuous ) {
                CAILog.enabled = true;
                m_theContinuousSnapshotText.text = "Continuous";
            }
            else {
                CAILog.enabled = false;
                m_theContinuousSnapshotText.text = "Paused";
            }
        }

        private var m_pAILog : CLog = null;
        private var m_pIdLabel : TextField = null;
        private var m_pIdText : TextField = null;
        private var m_pFilterLabel : TextField = null;
        private var m_pFilterInputText : TextField = null;
        protected var m_theContinuousSnapshotText : TextField = null;
        protected var m_theContinuousSnapshotButton : SimpleButton = null;
        protected var m_bContinuous : Boolean = true;

        protected var m_fUpdateTime : Number = 0.0;
        protected var m_fUpdatePeriod : Number = 1;

    }
}
