//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/12/9.
 */
package kof.game.level.bubbles {

import kof.game.core.CGameObject;
import kof.ui.demo.BubblesDialogueUI;

public class CBubblesDialogueView {
    public var bubblesDialogueUI:BubblesDialogueUI;
    public var hideCallBack:Function;
    public var actor:CGameObject;
    public var x:int;
    public var y:int;
    public var content:String;
    public var position:int;
    public var time:Number;

    public function CBubblesDialogueView() {
    }

    public function init():void{
        bubblesDialogueUI = new BubblesDialogueUI();
        bubblesDialogueUI.txt_content.textField.width = 154;
        bubblesDialogueUI.txt_content.text = content;
        bubblesDialogueUI.txt_content.height = bubblesDialogueUI.txt_content.textField.textHeight + 35;
        bubblesDialogueUI.txt_content.width =  bubblesDialogueUI.txt_content.textField.textWidth + 35;

        if(position){
            bubblesDialogueUI.img_target.scaleX = 1;
            bubblesDialogueUI.img_target.x = 7;
        }
        else{
            bubblesDialogueUI.img_target.scaleX = -1;
            bubblesDialogueUI.img_target.x = bubblesDialogueUI.txt_content.x + bubblesDialogueUI.txt_content.width - 7;
        }

        bubblesDialogueUI.x += x;
        bubblesDialogueUI.y += y;
    }

    public function dispose():void{
        bubblesDialogueUI.txt_content.text = "";
        hideCallBack = null;
        actor = null;
        x = 0;
        y = 0;
        content = "";
        position = 0;
        time = 0;
    }
}
}
