//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/11/29.
 */
package kof.game.club.view.clubgame.view {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BlurFilter;
import flash.utils.clearTimeout;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import kof.game.club.view.clubgame.ClubGameImgUrlConst;

import kof.ui.master.club.clubgame.ClubGameCardItemUI;
import kof.ui.master.club.clubgame.ClubGameItemUI;

import morn.core.events.UIEvent;

public class ClubGameIcoSprite extends Sprite{
    private static const SRART_SITE:Number = -80;
    private static const CARD_GAP:Number = 160;
    private static const CHANGE_GAP:Number = 80;

    public var cardId:int;

    private var _icoAry:Array;

    private var _timeId:int;

    private var _endIndex:int;

    private var _skipTime:int;

    private var _time:int;

    private var _tempCount:int;

    private var _isOver:Boolean = false;

    private var _clubGameItemUI : ClubGameItemUI;

    public var imgID : int;

    private static var _filter:BlurFilter = new BlurFilter(0,10);

    public function ClubGameIcoSprite()
    {
        super();
        initUI();
    }
    private function initUI():void
    {
        _clubGameItemUI = new ClubGameItemUI();
        addChild( _clubGameItemUI );
        _icoAry = [];
        var cardItem:ClubGameCardItemUI;
        var i:int;
        for(i = 0 ; i < 3 ; i ++ )
        {
            cardItem = new ClubGameCardItemUI();
            cardItem.img.url = ClubGameImgUrlConst.getCardUrl( i );
            cardItem.dataSource = i;
            cardItem.y = SRART_SITE +  CARD_GAP * i ;
            cardItem.x = 22;
            _clubGameItemUI.box_ctn.addChild(cardItem);
            _icoAry.push(cardItem);
        }

        this.mouseEnabled =  this.mouseChildren = false;

        addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
        onRize();
    }

    public function initClubGameCardItem( index : int ,id : int ):void{
        var cardItem:ClubGameCardItemUI = _icoAry[ index ];
        cardItem.img.url = ClubGameImgUrlConst.getCardUrl( id );
        cardItem.dataSource = id;
    }



    public function doEffect(endIndex:int,time:int = 1000):void
    {
        _endIndex = endIndex;
        _skipTime = time;
        startPlay();
    }

    private function startPlay():void
    {
        _time = getTimer();
        _isOver = false;
        _tempCount = 2;
        _timeId = setTimeout(changeSite,20);
    }


    private function changeSite():void
    {
        var i:int,id:int;
        var cardItem:ClubGameCardItemUI;
        var rollOver:Boolean = false;
        for(i = 0;i<_icoAry.length;i++)
        {
            cardItem = _icoAry[i];
            if(cardItem.filters.length == 0)
            {
                cardItem.filters = [_filter];
            }

            cardItem.y += CHANGE_GAP;
            if(cardItem.y > SRART_SITE + CARD_GAP * _icoAry.length - CARD_GAP / 2)
            {
                cardItem.y = SRART_SITE - CARD_GAP / 2;
                var nextId:int = int( cardItem.dataSource ) - 3;
                if(_isOver)
                {
                    nextId = _endIndex + _tempCount - 1;
                    _tempCount --;
                    if(_tempCount < 0)
                    {
                        rollOver = true;
                    }
                }
                id = ( nextId + ClubGameImgUrlConst.CARD_ARY.length) % ClubGameImgUrlConst.CARD_ARY.length;
//                cardItem.changeId(id);
                cardItem.img.url =  ClubGameImgUrlConst.getCardUrl( id );
                cardItem.dataSource = id;
            }
        }
        _isOver = getTimer() - _time > _skipTime;
        if(!rollOver)
        {
            _timeId = setTimeout(changeSite,20);
        }
        else
        {
            resetOverSite();
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

    public function onAddToStage(e:Event):void
    {
    }
    public function onRemoveFromStage(e:Event):void
    {
        clearTimeout(_timeId);
//			if(_betEffect)
//				_betEffect.remove();
    }
    public function onRize():void
    {
        var pMaskDisplayObject : DisplayObject ;
        pMaskDisplayObject = _clubGameItemUI.maskimg;
        if ( pMaskDisplayObject ) {
            pMaskDisplayObject.cacheAsBitmap = true;
            _clubGameItemUI.box_ctn.mask = pMaskDisplayObject;
        }
    }

    public function reset():void
    {
        for(var i:int = 0;i<_icoAry.length;i++)
        {
            var cardItem:ClubGameCardItemUI = _icoAry[i];
            cardItem.y = SRART_SITE +  CARD_GAP * i;
//            cardItem.changeId(i);
            cardItem.img.url =  ClubGameImgUrlConst.getCardUrl( i );
            cardItem.dataSource = i;
        }

        stopBaoEff();
        stopBigEff();
    }

    private function resetOverSite():void
    {
        for(var i:int = 0;i<_icoAry.length;i++)
        {
            var cardItem:ClubGameCardItemUI = _icoAry[i];
            var nextId:int = (_endIndex + 1) % ClubGameImgUrlConst.CARD_ARY.length;
            var preId:int = (_endIndex - 1 + ClubGameImgUrlConst.CARD_ARY.length) % ClubGameImgUrlConst.CARD_ARY.length;
            var tempArr:Array = [preId,_endIndex,nextId];
            var site:int = tempArr.indexOf( int( cardItem.dataSource ) );
            cardItem.y = SRART_SITE +  CARD_GAP * site;
        }
    }
  //////////////////////////////////
    public function doBoaEff():void{
        _clubGameItemUI.frameclip_tobao.addEventListener( UIEvent.FRAME_CHANGED,onBaoChanged );
        _clubGameItemUI.frameclip_tobao.visible = true;
        _clubGameItemUI.frameclip_tobao.gotoAndPlay(0);
    }
    private function onBaoChanged(evt:UIEvent):void{
        if( _clubGameItemUI.frameclip_tobao.frame >=  _clubGameItemUI.frameclip_tobao.totalFrame - 1) {
            stopBaoEff();
        }
    }
    private function stopBaoEff():void{
        _clubGameItemUI.frameclip_tobao.removeEventListener( UIEvent.FRAME_CHANGED,onBaoChanged );
        _clubGameItemUI.frameclip_tobao.stop();
        _clubGameItemUI.frameclip_tobao.visible = false;
    }
    //////////////////////////////////
    public function doBigEff():void{
        _clubGameItemUI.franeclip_tobig.addEventListener( UIEvent.FRAME_CHANGED,onBigChanged );
        _clubGameItemUI.franeclip_tobig.visible = true;
        _clubGameItemUI.franeclip_tobig.gotoAndPlay(0);
    }
    private function onBigChanged(evt:UIEvent):void{
        if( _clubGameItemUI.franeclip_tobig.frame >=  _clubGameItemUI.franeclip_tobig.totalFrame - 1) {
            stopBigEff();
        }
    }
    private function stopBigEff():void{
        _clubGameItemUI.franeclip_tobig.removeEventListener( UIEvent.FRAME_CHANGED,onBigChanged );
        _clubGameItemUI.franeclip_tobig.stop();
        _clubGameItemUI.franeclip_tobig.visible = false;
    }

    ////////////
    public function clearFilters():void{
        var i : int;
        var cardItem:ClubGameCardItemUI;
        for(i = 0;i<_icoAry.length;i++) {
            cardItem = _icoAry[ i ];
            if(cardItem.filters.length > 0)
            {
                cardItem.filters = [];
            }
        }
    }

    public function get m__clubGameItemUI() : ClubGameItemUI {
        return _clubGameItemUI;
    }
}
}
