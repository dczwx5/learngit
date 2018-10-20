/**
 * Created by Administrator on 2016/8/16.
 */
package QFLib.Audio.audio {
import QFLib.Foundation;
import QFLib.ResourceLoader.CBaseLoader;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.ByteArray;


/**
 * OGG格式播放器
 * @author Maniac(maniac@qifun.com)
 */
public class CAudioOGGSource extends CAudioSource {

    public function CAudioOGGSource(soundURL:String, fnOnLoadFinished : Function = null)
    {
        super ( fnOnLoadFinished );

        this.audioPath = soundURL;
        this.init();
    }

    public function init():void
    {
        CResourceLoaders.instance().startLoadFile(this.audioPath,_onCompleteHandler,".OGG", ELoadingPriority.NORMAL, true);

        function _onCompleteHandler( loader : CBaseLoader, idErrorCode : int ):void
        {
            if( idErrorCode == 0 && loader.urlFile.numTotalBytes > 0 )
            {
                AssetsSize = loader.urlFile.numTotalBytes;
            }

            if ( _fnOnLoadFinished != null )
                _fnOnLoadFinished ( idErrorCode, this );
        }

    }

    private function _onLoadFail():void
    {
        Foundation.Log.logErrorMsg("audio load failure:" + this.audioPath);
    }

    override public function dispose():void
    {
        super.dispose();

        isLoaderComplete = false;
    }

    override public function play(soundTranform:SoundTransform = null, startTime:Number = 0.0, loops:int = 1):SoundChannel
    {
        this.isPlaying = true;
        this.isPaused = false;

        return null;

    }

    private function _onSoundComplete(event:Event):void {
        _playTimes ++;
    }

    private function _onSoundIOErrorHandler(event:IOErrorEvent):void {

    }

    override public function pause():void
    {
        super.pause();
    }

    override public function stop():void
    {
        super.stop();
    }
}
}
