//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/27.
 * Time: 15:53
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
     * 2017/9/27
     */
    public class CVideoListView {
        private var _hookView : CHookView = null;
        private var _hookUI : HangUpUI = null;
        private var _videoArray : Array = [];
        private var _dicVideoToPath : Dictionary = null;
        private var _dicVideoToName : Dictionary = null;
        private var _videoURL:String="";

        public function CVideoListView( hookView : CHookView ) {
            _hookView = hookView;
            this._hookUI = hookView.hookUI;
            _dicVideoToPath = new Dictionary();
            _dicVideoToName = new Dictionary();
            var skillVideoTabel : CDataTable = CHookClientFacade.instance.hangUpSkillVideo;
            _videoArray = skillVideoTabel.toArray();
            _hookUI.videoList.renderHandler = new Handler( _renderVideoList );
            var sizeY:int=int( _videoArray.length / _hookUI.videoList.repeatX );
            if(_videoArray.length % _hookUI.videoList.repeatX!=0){
                sizeY++;
            }
            _hookUI.videoList.repeatY = sizeY;
            _hookUI.videoList.dataSource = _videoArray;
            var pConfigSystem : CKOFConfigSystem = CHookClientFacade.instance.hookSystem.stage.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
            _videoURL = pConfigSystem.configuration.getString( "videoURL" );
        }

        private function _renderVideoList( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var data : HangUpSkillVideo = itemUI.dataSource as HangUpSkillVideo;
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
            _dicVideoToName[ itemUI ] = data.videoDis;
            itemUI.addEventListener( MouseEvent.CLICK, _clickVideoList );
        }

        private function _clickVideoList( e : MouseEvent ) : void {
            var item : Box = e.currentTarget as Box;
            var path : String = _dicVideoToPath[ item ];
            var videoName : String = _dicVideoToName[ item ];
            _hookView.playVideo( path, videoName );
        }

        public function show() : void {
            _hookUI.videoPanel.visible = true;
        }

        public function hide() : void {
            _hookUI.videoPanel.visible = false;
        }
    }
}
