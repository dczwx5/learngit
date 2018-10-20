//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/26.
 * Time: 10:31
 */
package kof.game.hook.view.childViews {

import QFLib.Foundation.CPath;
import QFLib.ResourceLoader.CResourceLoaders;

import flash.events.MouseEvent;
    import flash.utils.Dictionary;

    import kof.data.CDataTable;
import kof.game.config.CKOFConfigSystem;
import kof.game.hook.CHookClientFacade;
    import kof.game.hook.view.CHookView;
    import kof.table.HangUpSkillVideo;
    import kof.ui.master.hangup.HangUpUI;

    import morn.core.components.Box;
    import morn.core.components.Component;
    import morn.core.components.Image;
    import morn.core.components.Label;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/9/26
     */
    public class CRecommendVideoView {
        private var _hookView : CHookView = null;
        private var _hookUI : HangUpUI = null;
        private var _videoArray : Array = [];
        private var _dicVideoToPath : Dictionary = null;
        private var _dicVideoToVideoName : Dictionary = null;
        private var _videoURL:String="";

        public function CRecommendVideoView( hookView : CHookView ) {
            this._hookView = hookView;
            this._hookUI = hookView.hookUI;
            _dicVideoToPath = new Dictionary();
            _dicVideoToVideoName = new Dictionary();
            var skillVideoTabel : CDataTable = CHookClientFacade.instance.hangUpSkillVideo;
            var recommendArr : Array = skillVideoTabel.toArray();
            for ( var i : int = 0; i < recommendArr.length; i++ ) {
                if ( recommendArr[ i ].videoCommend > 0 ) {
                    _videoArray.push( recommendArr[ i ] );
                }
            }
            _hookUI.recommendList.renderHandler = new Handler( _renderVideoList );
//            _hookUI.recommendList.selectHandler = new Handler(_onSelectList);
            _videoArray.sort( _compareVideo );
            _hookUI.recommendList.selectedIndex = 0;
//            _hookUI.recommendList.repeatY = _videoArray.length;
            _hookUI.recommendList.dataSource = _videoArray;
            var pConfigSystem : CKOFConfigSystem = CHookClientFacade.instance.hookSystem.stage.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
            _videoURL = pConfigSystem.configuration.getString( "videoURL" );
        }

        private function _onSelectList(selectIndex:int) : void {
            var item:Box = _hookUI.recommendList.getCell(selectIndex + _hookUI.recommendList.startIndex);
        }

        public function hide() : void {
            this._hookUI.recommendList.visible = false;
        }

        public function show() : void {
            this._hookUI.recommendList.visible = true;
        }

        private function _renderVideoList( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var data : HangUpSkillVideo = item.dataSource as HangUpSkillVideo;
            if ( !data )return;
            (itemUI.getChildByName( "videoListBg" ) as Image).url = data.videoImageSource + data.videoName + ".jpg";
            (itemUI.getChildByName( "videoName" ) as Label).text = data.videoDis;
            var videoPath : String = "";
            videoPath=_videoURL+data.videoSource;
            if (/^http:\/\//g.test(videoPath)) {
                videoPath = videoPath+data.videoName+".mp4";
            } else {
                videoPath = data.videoSource + data.videoName + ".mp4";
                videoPath = (CResourceLoaders.instance().absoluteURI ? CPath.addRightSlash(CResourceLoaders.instance().absoluteURI) : "") + videoPath;
            }
            videoPath = CResourceLoaders.instance().assetVersion.mappingFilenameWithVersion(videoPath);

            _dicVideoToPath[ itemUI ] = videoPath;
            _dicVideoToVideoName[ itemUI ] = data.videoDis;
            itemUI.addEventListener( MouseEvent.CLICK, _clickVideoList );
        }

        private function _clickVideoList( e : MouseEvent ) : void {
            var item : Box = e.currentTarget as Box;
            var path : String = _dicVideoToPath[ item ];
            var videoName : String = _dicVideoToVideoName[ item ];
            _hookView.playVideo( path, videoName );



//
//            for(var i:int = 0;i < _hookUI.recommendList.length;i++) {
//                var cell : Component = _hookUI.recommendList.getCell( i ) as Component;
//                var overLabel : Image = cell.getChildByName( "seleted" ) as Image;
//                overLabel.visible = false;
//            }
        }

        private function _compareVideo( a : HangUpSkillVideo, b : HangUpSkillVideo ) : int {
            if ( a.videoCommend > b.videoCommend ) {
                return -1;
            } else if ( a.videoCommend < b.videoCommend ) {
                return 1;
            } else {
                return 0;
            }
        }
    }
}
