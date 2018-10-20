//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/11.
 */
package kof.game.chat.face {

import flash.display.Sprite;

import morn.core.components.Image;

public class CBaseFace extends Sprite{

    private var _faceLinkName:String;

    private var _img:Image;

    public function CBaseFace( faceLinkName:String ) {

        _faceLinkName = faceLinkName;

        _img = new Image();
        _img.skin = 'png.chatsystemface.' + ( _faceLinkName.replace('CFace',''));
        addChild( _img );
    }

    public function getFaceUrl( ID :String ):String{
        var url : String = '';
//        url = CChatConst.list_system_icon_url + ID + ".png";
//        if( url == ''){
//            url = CChatConst.list_shopface_icon_url + ID + ".png";
//        }
        return url;
    }
}
}
