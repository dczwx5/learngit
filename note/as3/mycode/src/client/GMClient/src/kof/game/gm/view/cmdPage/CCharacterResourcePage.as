//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2018/1/5.
 */
package kof.game.gm.view.cmdPage {

import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.CDashPage;
import QFLib.Foundation.CSet;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;

import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import spineExt.CCharacterResourceData;

public class CCharacterResourcePage extends CDashPage{
    public function CCharacterResourcePage( theDashBoard : CDashBoard, theFrameWork : CFramework) {
        super( theDashBoard );
        m_theFrameWork = theFrameWork;
        m_theCharacterSet = theFrameWork.characterSet;

        m_theResourceText = new TextField();
        m_theResourceText.defaultTextFormat.font = "Terminal";
        m_theResourceText.defaultTextFormat.size = 18;
        m_theResourceText.textColor = 0xFFFFFF;
        m_theResourceText.wordWrap = true;
        m_theResourceText.multiline = true;
        m_theResourceText.border = true;
        m_theResourceText.borderColor = 0xFFFFFF;
        m_theResourceText.scrollV = m_theResourceText.numLines;
        m_thePageSpriteRoot.addChild( m_theResourceText );

        m_theLoadCharacterLabel = new TextField();
        m_theLoadCharacterLabel.defaultTextFormat.font = "Terminal";
        m_theLoadCharacterLabel.selectable = false;
        m_theLoadCharacterLabel.width = 160;
        m_theLoadCharacterLabel.height = 20;
        m_theLoadCharacterLabel.textColor = 0xFFFFFF;
        m_theLoadCharacterLabel.text = "Need to load:";
        m_thePageSpriteRoot.addChild( m_theLoadCharacterLabel );

        m_theLoadCharacterInput = new TextField();
        m_theLoadCharacterInput.type = TextFieldType.INPUT;
        m_theLoadCharacterInput.width = 160;
        m_theLoadCharacterInput.height = 20;
        m_theLoadCharacterInput.border = true;
        m_theLoadCharacterInput.borderColor = 0xFFFFFF;
        m_theLoadCharacterInput.defaultTextFormat.font = "Terminal";
        m_theLoadCharacterInput.textColor = 0xFFFFFF;
        m_thePageSpriteRoot.addChild( m_theLoadCharacterInput );

        m_theLoadCharacterButton = new TextField();
        m_theLoadCharacterButton.selectable = false;
        m_theLoadCharacterButton.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
        m_theLoadCharacterButton.border = true;
        m_theLoadCharacterButton.borderColor = 0xFFFFFF;
        m_theLoadCharacterButton.width = 160;
        m_theLoadCharacterButton.height = 20;
        m_theLoadCharacterButton.textColor = 0xFFFFFF;
        m_theLoadCharacterButton.text = "Start to load";
        m_thePageSpriteRoot.addChild( m_theLoadCharacterButton );
        m_theLoadCharacterButton.addEventListener(MouseEvent.CLICK, _onClickToStartLoad);


        // character label
        m_theCharacterLabel = new TextField();
        m_theCharacterLabel.defaultTextFormat.font = "Terminal";
        m_theCharacterLabel.selectable = false;
        m_theCharacterLabel.width = 160;
        m_theCharacterLabel.height = 20;
        m_theCharacterLabel.textColor = 0xFFFFFF;
        m_theCharacterLabel.text = "Character:";
        m_thePageSpriteRoot.addChild( m_theCharacterLabel );

        // character input
        m_theCharacterInput = new TextField();
        m_theCharacterInput.type = TextFieldType.INPUT;
        m_theCharacterInput.width = 160;
        m_theCharacterInput.height = 20;
        m_theCharacterInput.border = true;
        m_theCharacterInput.borderColor = 0xFFFFFF;
        m_theCharacterInput.defaultTextFormat.font = "Terminal";
        m_theCharacterInput.setTextFormat( m_theCharacterInput.defaultTextFormat );
        m_theCharacterInput.textColor = 0xFFFFFF;
        m_thePageSpriteRoot.addChild( m_theCharacterInput );

        m_theCopyButton = new TextField();
        m_theCopyButton.selectable = false;
        m_theCopyButton.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
        m_theCopyButton.border = true;
        m_theCopyButton.borderColor = 0xFFFFFF;
        m_theCopyButton.width = 160;
        m_theCopyButton.height = 20;
        m_theCopyButton.textColor = 0xFFFFFF;
        m_theCopyButton.text = "Get Information";
        m_thePageSpriteRoot.addChild( m_theCopyButton );
        m_theCopyButton.addEventListener(MouseEvent.CLICK, _onClickToGet);

        m_theCopyAllButton = new TextField();
        m_theCopyAllButton.selectable = false;
        m_theCopyAllButton.defaultTextFormat = new TextFormat( "Terminal", 12, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
        m_theCopyAllButton.border = true;
        m_theCopyAllButton.borderColor = 0xFFFFFF;
        m_theCopyAllButton.width = 160;
        m_theCopyAllButton.height = 20;
        m_theCopyAllButton.textColor = 0xFFFFFF;
        m_theCopyAllButton.text = "Get All Information";
        m_thePageSpriteRoot.addChild( m_theCopyAllButton );
        m_theCopyAllButton.addEventListener(MouseEvent.CLICK, _onClickToGetAll);
    }

    [Inline]
    override final public function get name() : String {
        return "CharacterResourcePage";
    }

    public override function onResize() : void {
        super.onResize();

        m_theResourceText.x = m_theDashBoardRef.pageX + 10;
        m_theResourceText.y = m_theDashBoardRef.pageY + 10;
        m_theResourceText.width = m_theDashBoardRef.pageWidth - 20 - 160 - 10;
        m_theResourceText.height = m_theDashBoardRef.pageHeight - 20;

        m_theLoadCharacterLabel.x = m_theResourceText.x + m_theResourceText.width + 10;
        m_theLoadCharacterLabel.y = m_theResourceText.y;
        m_theLoadCharacterInput.x = m_theLoadCharacterLabel.x;
        m_theLoadCharacterInput.y = m_theLoadCharacterLabel.y + 20;
        m_theLoadCharacterButton.x = m_theLoadCharacterInput.x;
        m_theLoadCharacterButton.y = m_theLoadCharacterInput.y + 22;

        m_theCharacterLabel.x = m_theLoadCharacterButton.x;
        m_theCharacterLabel.y = m_theLoadCharacterButton.y + 25;
        m_theCharacterInput.x = m_theCharacterLabel.x;
        m_theCharacterInput.y = m_theCharacterLabel.y + 20;
        m_theCopyButton.x = m_theCharacterInput.x;
        m_theCopyButton.y = m_theCharacterInput.y + 22;
        m_theCopyAllButton.x = m_theCopyButton.x;
        m_theCopyAllButton.y = m_theCopyButton.y + 22;
    }

    private function _onClickToStartLoad( e : MouseEvent ) : void
    {
        var theStr:String = m_theLoadCharacterInput.text;
        if(theStr.length > 0)
        {
            CFramework.StatisticsResourceOn = true;
            m_theFrameWork.fxPoolUpdateSwitchOn = false;

            var theList:Array = theStr.split(",");
            var characterName:String;
            for(var i:int=0; i<theList.length; i++)
            {
                characterName = theList[i];
                var lastIndex:int = characterName.lastIndexOf("/");
                characterName = characterName + "/" + characterName.substr(lastIndex+1);
                m_theCharacterList.push(_createCharacter("assets/character/" + characterName + ".json"));
            }
        }
    }

    private function _createCharacter(fileName:String) : CCharacter
    {
        var theCharacter : CCharacter = new CCharacter( m_theFrameWork);
        theCharacter.loadFile( fileName, null );

        return theCharacter;
    }

    private function _onClickToGet( e : MouseEvent ) : void
    {
        var searchStr:String = m_theCharacterInput.text;
        if( searchStr.length > 0 )
        {
            m_theResourceText.text = "========    Output Single character:[" + searchStr + "]";

            var obj:Object = CCharacterResourceData.getRecord();
            for(var characterName:String in obj) {
                if(characterName.indexOf(searchStr)!=-1) {
                    _toOutput( characterName, obj[ characterName ] , true);
                }
            }

            m_theResourceText.scrollV = m_theResourceText.numLines;
        }
    }

    private function _onClickToGetAll( e : MouseEvent ) : void
    {
        m_theResourceText.text = "========    Output All Character";

        var obj:Object = CCharacterResourceData.getRecord();
        for(var characterName:String in obj) {
            _toOutput(characterName, obj[characterName], false);
        }

        m_theResourceText.scrollV = m_theResourceText.numLines;
    }

    private function _toOutput(characterName:String, record:Object, needMenu:Boolean=false):void
    {
        var fxSize:int = 0;
        var audioSize:int = 0;
        var spineSize:int = 0;
        var totalSize:int = 0;
        m_theResourceText.appendText("\nCharacter:" + characterName);
        var fxObj:Object = record["fx"];
        var audioObj:Object = record["audio"];
        var spineObj:Object = record["character"];
        var fileName:String;
        var size:int;
        for(fileName in spineObj) {
            size = spineObj[fileName];
            spineSize += size;
            totalSize += size;
            if(needMenu) m_theResourceText.appendText("\nSpine:" + fileName + "    Size:" + Number(size/1024 ).toFixed(2) + "k");
        }
        for(fileName in fxObj) {
            size = fxObj[fileName];
            fxSize += size;
            totalSize += size;
            if(needMenu) m_theResourceText.appendText("\nFx:" + fileName + "    Size:" + Number(size/1024 ).toFixed(2) + "k");
        }
        for(fileName in audioObj) {
            size = audioObj[fileName];
            audioSize += size;
            totalSize += size;
            if(needMenu) m_theResourceText.appendText("\nAudio:" + fileName + "    Size:" + Number(size/1024 ).toFixed(2) + "k");
        }
        m_theResourceText.appendText("\n----------SpineSize:"+Number(spineSize/1024 ).toFixed(2) + "k");
        m_theResourceText.appendText("\n----------FxSize:"+Number(fxSize/1024 ).toFixed(2) + "k");
        m_theResourceText.appendText("\n----------AudioSize:"+Number(audioSize/1024 ).toFixed(2) + "k");
        m_theResourceText.appendText("\n----------TotalSize:"+Number(totalSize/1024 ).toFixed(2) + "k\n");
    }

    protected var m_theResourceText : TextField = null;
    protected var m_theLoadCharacterLabel : TextField = null;
    protected var m_theLoadCharacterInput : TextField = null;
    protected  var m_theLoadCharacterButton : TextField = null;
    protected var m_theCharacterLabel : TextField = null;
    protected var m_theCharacterInput : TextField = null;
    protected var m_theCopyButton : TextField = null;
    protected var m_theCopyAllButton : TextField = null;

    protected  var m_theFrameWork : CFramework = null;
    protected var m_theCharacterSet : CSet = null;
    protected  var m_theCharacterList : Array = [];
}
}
