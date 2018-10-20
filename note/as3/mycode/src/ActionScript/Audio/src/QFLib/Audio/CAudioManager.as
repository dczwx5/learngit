/**
 * Created by Manaic on 2016/8/5.
 */
package QFLib.Audio {
import QFLib.Audio.audio.CAudio;
import QFLib.Audio.audio.CAudioMP3Source;
import QFLib.Audio.audio.CAudioOGGSource;
import QFLib.Audio.audio.CAudioSource;
import QFLib.Audio.event.CAudioEvent;
import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CPath;
import QFLib.Interface.IUpdatable;
import QFLib.ResourceLoader.ELoadingPriority;

import com.greensock.TweenLite;
import QFLib.Memory.CResourcePool;
import QFLib.Memory.CResourcePools;
import QFLib.ResourceLoader.CBaseLoader;
import QFLib.ResourceLoader.CJsonLoader;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceCache;
import QFLib.ResourceLoader.CResourceLoaders;

import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.getTimer;

/**
 * 音效管理器
 * @author Maniac(maniac@qifun.com)
 */
public class CAudioManager implements IUpdatable {

    public function CAudioManager()
    {
        this._init();
    }

    public function audioDatasIteration( audioDatas: CMap):void {
        m_mapAudioDatas = audioDatas;
    }

    /**
     * 预加载音效资源
     * @param sFilename
     */
    public function loadFile(sFilename:String):void
    {
        CResourceLoaders.instance().startLoadFile(sFilename, _loadFinished,null, ELoadingPriority.HIGH, true);

        function _loadFinished(loader : CBaseLoader, idErrorCode : int ):void
        {
            if( idErrorCode == 0)
            {
                if(loader is CJsonLoader)
                {
                    var jsonObj : Object = CJsonLoader( loader ).createObject() as Object;

                    if( m_mapAudioDatas == null)
                    {
                        m_mapAudioDatas = new CMap();
                    }
                    else
                    {
                        m_mapAudioDatas.clear();
                    }
                    m_mapAudioDatas.append( jsonObj, "name", CAudioData );

                    var audioData:CAudioData;
                    for each( audioData in m_mapAudioDatas )
                    {
                        if(audioData.preLoad == 1)
                        {
                            //预加载
                            _createAudioFromCache( audioData.fileName );
                        }
                    }
                }
            }
            else
            {
                Foundation.Log.logWarningMsg( "[CAudioManager] load file failed: " + sFilename );
            }

        }
    }

    /**
     * 预加载音效
     * @param jsonObj
     */
    public function loadAudio(jsonObj:Object, fnOnloadFinished : Function = null ):void
    {
        if(jsonObj == null)return;

        if( jsonObj is String)
        {
            _createAudioFromCache( String(jsonObj), fnOnloadFinished );
        }
        else
        {
            for each(var data:Object in jsonObj )
            {
                _createAudioFromCache( data.fileName, fnOnloadFinished );
            }
        }
    }

    /**
     * 播放背景音乐
     * @param audioName 音效名称
     * @param startTime 开始播放时间
     * @param times 循环次数（默认循环播放）
     * @param fadeOutTime 淡出时间
     * @param fadeInTime 淡入时间
     * @param bReplay 是否重新开始播放
     */
    public function playMusic(audioName:String, times:int = int.MAX_VALUE, startTime:Number = 0.0, fadeOutTime:Number = 3.0, fadeInTime:Number = 3.0, bReplay:Boolean = false):void
    {
        var fileName:String = this._findPath( audioName );
        if(fileName == null)
        {
            Foundation.Log.logWarningMsg( "[CAudioManager] load audio failed: audioID ==> " + audioName );
            return;
        }

        this.playMusicByPath(fileName, times, startTime, fadeOutTime, fadeInTime, bReplay);
    }

    public function playMusicByPath(fileName:String, times:int = int.MAX_VALUE, startTime:Number = 0.0, fadeOutTime:Number = 3.0, fadeInTime:Number = 3.0, bReplay:Boolean = false):void
    {
        if(fileName == null)
        {
            Foundation.Log.logWarningMsg( "[CAudioManager] load audio failed: fileName is null " );
            return;
        }

        if(!bReplay)//不重新播放
        {
            //如果是播放的同一首音乐接着播放
            if(_musicSource && _musicSource.audioPath == fileName)
            {
                return;
            }
        }

        if(_musicSource)
        {
            //上一个淡出完成后，下一个淡入

            TweenLite.to(_musicSource, fadeOutTime, {volume:0, onComplete:_onTweenCompleteHandle, onCompleteParams:[fileName, times, fadeInTime]});
        }
        else
        {
            _onPlayByLoaded(fileName,times,fadeInTime);
        }
    }

    private function _onStartTweenPlay( fadeInTime:Number, times:int ) : void {
        if(_musicSource == null)return;
        if(fadeInTime > 0)
        {
            _musicChannel = _musicSource.play( _musicTransform, 0,  times );
            if(_musicSource){
                _musicSource.volume = 0;
            }
            TweenLite.to(this, fadeInTime, {musicVolume:_musicVolue});
        }
        else
        {
            _musicChannel = _musicSource.play( _musicTransform, 0,  times );
        }
    }

    /**
     * 根据音效名称播放效果音效
     * @param audioName 音效名称
     */
    public function playAudioByName(audioName:String, times:int = 1, startTime:Number = 0.0, playMode:int = 0):void
    {
        var fileName:String = this._findPath( audioName.toLocaleLowerCase() );
        if(fileName == null)
        {
            Foundation.Log.logWarningMsg( "[CAudioManager] load audio failed: audioID ==> " + audioName );
            return;
        }

        this.playAudioByPath(fileName, times, startTime, playMode);
    }

    /**
     * 根据音效路径播放效果音效
     * @param audioName 音效路径
     */
    public function playAudioByPath(fileName:String, times:int = 1, startTime:Number = 0.0, playMode:int = 0):void
    {
        if(fileName == null)
        {
            Foundation.Log.logWarningMsg( "[CAudioManager] load audio failed: fileName is null");
            return;
        }

        var audioSource:CAudioSource = _createAudioSource( fileName );
        var audio:CAudio = _allocate(audioSource.audioPath);
        if(audio == null)
        {
            audio = new CAudio(audioSource);
        }

        if( playMode == 0){
            //播放模式默认是0，处理同时播放相同音效的问题
            var sameNum:int = handleSameTimeSound(audioSource.audioPath);
            if(sameNum > 2)return;
        }
        //播放模式1，表示从UI调用（按钮点击音效），不用处理相同音效的问题

        audio.volume = this.audioVolume;
        audio.play(0,times);
        _addPlayingMap( audio );
        resetSoundVolume( audioSource.audioPath );
    }

    /**
     * 停止背景音乐
     */
    public function stopMusic():void
    {
        if(_musicSource)
        {
            _musicSource.stop();
            _musicSource = null;
        }
    }

    /**
     * 停止效果音效
     */
    public function stopAudio():void
    {
        for each(var audios:Array in m_playingMap)
        {
            for each(var audio:CAudio in audios)
            {
                audio.stop();
            }
        }
    }

    /**
     * 根据音效名称停止指定的效果音效
     * @param audioName
     */
    public function stopAudioByName(audioName:String):void
    {
        for each(var audios:Array in m_playingMap)
        {
            for each(var audio:CAudio in audios)
            {
                if(audio.name == audioName)
                {
                    audio.stop();
                }
            }
        }
    }

    /**
     * 根据音效路径停止指定的效果音效
     * @param fileName
     */
    public function stopAudioByPath(fileName:String):void
    {
        for each(var audios:Array in m_playingMap)
        {
            for each(var audio:CAudio in audios)
            {
                if(audio.audioPath == fileName)
                {
                    audio.stop();
                }
            }
        }
    }

    /**
     * 停止所有声音
     */
    public function stopAll():void
    {
        stopMusic();
        stopAudio();
    }

    public function update( delta : Number ) : void {
        if ( m_theResourcePools ) {
            m_theResourcePools.update( delta );
        }
    }

    /**
     * 暂停
     */
    public function pauseMusic(audio:CAudio):void
    {
        if(audio)
        {
            audio.pause();
        }
    }

    /**
     * 销毁所有音效
     */
    public function disposeAll():void
    {
        if( _musicSource )
        {
            _musicSource.dispose();
            _musicSource = null;
        }

        for each(var audios:Array in m_playingMap)
        {
            for each(var audio:CAudio in audios)
            {
                audio.dispose();
            }
        }

        m_theResourcePools.dispose();
        m_playingMap.clear();
    }

    /**
     * @return volume
     */
    public function get musicVolume():Number
    {
        if(_musicSource)
        {
            return _musicSource.volume;
        }
        return 0;
    }
    /**
     * 设置背景音乐音量大小
     * @param volume
     */
    public function set musicVolume( volume:Number ) : void
    {
        if( volume <= 0 )
        {
            volume = 0;
        }
        _musicVolue = volume;
        if(_musicSource)
        {
            _musicSource.volume = volume;
        }
    }

    public function get isMusicMute():Boolean
    {
        return _isMusicMute;
    }

    public function set isMusicMute(value:Boolean):void
    {
        _isMusicMute = value;
        if(_isMusicMute)
        {
            stopMusic();
        }
    }

    public function get isAudioMute():Boolean
    {
        return _isAudioMute;
    }

    public function set isAudioMute(value:Boolean):void
    {
        _isAudioMute = value;
        if(_isAudioMute)
        {
            stopAudio();
        }
    }

    /**
     * @return volume
     */
    public function get audioVolume():Number{ return _audioVolume;}
    /**
     * 设置音效音量大小
     * @param volume
     */
    public function set audioVolume(volume:Number ) : void
    {
        if( volume < 0 )
        {
            volume = 0;
        }
        _audioVolume = volume;
        for each(var audios:Array in m_playingMap)
        {
            for each(var audio:CAudio in audios)
            {
                audio.volume = volume;
            }
        }

    }

    /**
     * 获取背景音乐名称
     */
    public function get musicName():String
    {
        if( _musicSource )
        {
            return _musicSource.name;
        }
        return null;
    }

    public function onPlayCompleted(audio:CAudio):void
    {
        _removePlayingMap(audio, audio.audioPath);//先移出播放列表
        this._recycle(audio);
    }

    /**
     * SAME_SOUND_INTERVAL时间内播放同一音效的数量
     * 防止同一时间播放同一音效过多导致的音量叠加，爆音问题
     * @param audioPath
     * @return index 数量
     */
    private function handleSameTimeSound( audioPath:String ):int
    {
        var audios:Array = m_playingMap.find( audioPath );
        if( !audios )
        {
            return 0;
        }
        var len:int = audios.length;
        var time:int = getTimer();
        var index:int = 0;
        for(var i:int = 0; i < len; ++i){
            var caudio:CAudio = audios[i];
            if(time - caudio.getDelayPlayTime() < SAME_SOUND_INTERVAL){
                index ++;
            }
        }
        return index;
    }

    /**
     * 同一时间播放同一音效，给定一个总音量再平均分配单个音量
     * @param audioPath
     */
    private function resetSoundVolume( audioPath:String ):void
    {
        //同时在播放相同Url音效的播放器个数
        var playingArr:Array = m_playingMap[audioPath];
        var numOfSameUrlPlayer:int = playingArr ? playingArr.length : 0;
        if (numOfSameUrlPlayer > 0)
        {
            //总音量大小
            var volume:Number = 1;
            if(numOfSameUrlPlayer == 1){
                volume = 1;
            }
            else{
                volume = 1.5;
            }
            //单个音量
            var singleVolume:Number = volume / numOfSameUrlPlayer;
            singleVolume = singleVolume < 0.15 ? 0.15 : singleVolume;

            //单个声音音量大小
            for each (var caudio:CAudio in playingArr)
            {
                caudio.volume = singleVolume > _audioVolume ? _audioVolume:singleVolume;
            }
        }
    }

    private function _init():void
    {
        //背景音乐
        _musicTransform = new SoundTransform();
    }

    /**
     * @param url 路径
     * @return CAudioSource
     */
    private function _createAudioSource(url:String):CAudioSource
    {
        var audio:CAudioSource = _createAudioFromCache(url);
        return audio;
    }

    private function _createAudioFromCache(url:String, fnOnLoadFinished : Function = null ):CAudioSource
    {
        var theResource:CResource = _resourceCache.find( url, ".MP3" ) as CResource;
            var audio:CAudioSource;

            var extPath:String = CPath.ext( url).toLowerCase();
            var audioName:String = this._findName(url);
            if(audioName == null)
            {
                audioName = CPath.name( url );
            }

            if(theResource == null)
            {
                if(extPath == ".ogg")
                {
                    //如果是ogg格式
                    audio = new CAudioOGGSource( url, fnOnLoadFinished );
                }
            else
            {
                //默认mp3格式
                if(url == ""){
                    Foundation.Log.logWarningMsg( "audio's url is null");
                }
                audio = new CAudioMP3Source( url, audioName, this, fnOnLoadFinished );
                theResource = new CResource( url, ".MP3", audio, -1);
                _resourceCache.add( url, ".MP3", theResource, true, false );
            }
        }
        else
        {
            audio = theResource.theObject as CAudioSource;
        }
        return audio;
    }

    /**
     * 添加到播放列表
     * @param url
     * @param audio
     */
    private function _addPlayingMap(audio:CAudio):void
    {
        var m_playings:Array = m_playingMap.find( audio.audioPath );
        if(!m_playings)
        {
            m_playings = [];
            m_playingMap.add(audio.audioPath, m_playings);
            m_playings.push(audio);
        }
        else
        {
            if(m_playings.indexOf(audio) == -1)
            {
                m_playings.push(audio);
            }
        }
    }

    /**
     * 移出播放列表
     */
    private function _removePlayingMap(audio:CAudio, audioPath:String):void
    {
        var m_playings:Array = m_playingMap.find( audioPath );
        if(!m_playings)
        {
            return;
        }

        var index:int = m_playings.indexOf(audio);
        if(index != -1)
        {
            m_playings.splice(index,1);
        }
    }

    private function _recycle(audio:CAudio):void
    {
        var theLoaderPool : CResourcePool = m_theResourcePools.getPool( audio.audioPath );
        if(theLoaderPool == null)
        {
            theLoaderPool = new CResourcePool( audio.audioPath, null );
            m_theResourcePools.addPool( audio.audioPath, theLoaderPool );
        }
        else
        {
            theLoaderPool.recycle( audio );
        }
    }

    private function _allocate( id:String ):CAudio
    {
        var theLoaderPool : CResourcePool = m_theResourcePools.getPool( id );
        if(theLoaderPool != null)
        {
            return theLoaderPool.allocate() as CAudio;
        }
        return null;
    }

    private function _onTweenCompleteHandle(soundURL:String, loops:int, fadeInTime:Number):void
    {
        stopMusic();
        _onPlayByLoaded(soundURL,loops,fadeInTime);
    }

    private function _onPlayByLoaded(soundURL:String, loops:int, fadeInTime:Number):void
    {
        _musicSource = _createAudioSource(soundURL);
        if(_musicSource.isLoadStart){
            _onStartTweenPlay( fadeInTime, loops );
        }else{
            _musicSource.addEventListener(CAudioEvent.SOUND_START, function( e:CAudioEvent ):void{
                _onStartTweenPlay(fadeInTime, loops);
            } );
        }
    }

    private function _findPath(audioName:String):String
    {
        for each( var data:Object in m_mapAudioDatas )
        {
            if( data.name == audioName)
            {
                return data.fileName;
            }
        }
        return null;
    }

    private function _findName(fileName:String):String
    {
        for each( var data:Object in m_mapAudioDatas )
        {
            if( data.fileName == fileName)
            {
                return data.name;
            }
        }
        return null;
    }


    public function hasAudioCache(url:String) : Boolean {
        var theResource:CResource = _resourceCache.find( url, ".MP3" ) as CResource;
        return theResource != null;
    }

    private var m_mapAudioDatas:CMap;

    private var m_playingMap:CMap = new CMap();//播放列表
    private var _resourceCache:CResourceCache = CResourceCache.instance();
    private var m_theResourcePools : CResourcePools = new CResourcePools(30);

    private var _isMusicMute:Boolean = false;
    private var _isAudioMute:Boolean = false;

    private var _musicSource:CAudioSource;//背景音乐
    private var _musicTransform:SoundTransform;//背景音乐
    private var _musicChannel:SoundChannel;

    private var _audioVolume:Number = 1.0;
    private var _musicVolue:Number = 1.0;
    private static const SAME_SOUND_INTERVAL:Number = 50;


}
}
