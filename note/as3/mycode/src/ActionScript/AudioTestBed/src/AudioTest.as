package {

import QFLib.Audio.CAudioManager;
import com.sociodox.theminer.TheMiner;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

[SWF(backgroundColor="#ffffff", frameRate="60", width="600", height="500")]
public class AudioTest extends Sprite {

    private var m_soundURLs:Array = ["Kof_select_role","Scene_fuben"];
    private var curIndex:int = 0;

    private var _audioManager:CAudioManager = new CAudioManager();

    public function AudioTest() {

        var playBtn:Sprite = new Sprite();
        playBtn.graphics.beginFill(0x00ff00,1);
        playBtn.graphics.drawRect(50,50,45,25);
        playBtn.graphics.endFill();
        addChild(playBtn);
        playBtn.addEventListener(MouseEvent.CLICK,onPlayClickHandler);
        var textField1:TextField = new TextField();
        textField1.width = 150;
        textField1.x = 100;
        textField1.y = 54;
        textField1.text = "播放/切换~背景音乐";
        addChild(textField1);


        var stopBtn:Sprite = new Sprite();
        stopBtn.graphics.beginFill(0xff0000,1);
        stopBtn.graphics.drawRect(50,100,45,25);
        stopBtn.graphics.endFill();
        addChild(stopBtn);
        stopBtn.addEventListener(MouseEvent.CLICK,onStopClickHandler);
        var textField2:TextField = new TextField();
        textField2.x = 100;
        textField2.y = 104;
        textField2.text = "停止背景音乐";
        addChild(textField2);


        var addBtn:Sprite = new Sprite();
        addBtn.graphics.beginFill(0xffff00,1);
        addBtn.graphics.drawRect(50,150,45,25);
        addBtn.graphics.endFill();
        addChild(addBtn);
        addBtn.addEventListener(MouseEvent.CLICK,onAddVolumeClickHandler);
        var textField3:TextField = new TextField();
        textField3.x = 100;
        textField3.y = 154;
        textField3.text = "背景音量增大";
        addChild(textField3);

        var reduceBtn:Sprite = new Sprite();
        reduceBtn.graphics.beginFill(0x0000ff,1);
        reduceBtn.graphics.drawRect(50,200,45,25);
        reduceBtn.graphics.endFill();
        addChild(reduceBtn);
        reduceBtn.addEventListener(MouseEvent.CLICK,onReduceVolumeClickHandler);
        var textField4:TextField = new TextField();
        textField4.x = 100;
        textField4.y = 204;
        textField4.text = "背景音量减小";
        addChild(textField4);


        var playBtnName:Sprite = new Sprite();
        playBtnName.graphics.beginFill(0x0000ff,1);
        playBtnName.graphics.drawRect(50,250,45,25);
        playBtnName.graphics.endFill();
        addChild(playBtnName);
        playBtnName.addEventListener(MouseEvent.CLICK,onPlayAudioByNameClickHandler);
        var textFieldPn:TextField = new TextField();
        textFieldPn.x = 100;
        textFieldPn.y = 254;
        textFieldPn.text = "播放音效(Name)";
        addChild(textFieldPn);

        var stopBtnName:Sprite = new Sprite();
        stopBtnName.graphics.beginFill(0x0000ff,1);
        stopBtnName.graphics.drawRect(200,250,45,25);
        stopBtnName.graphics.endFill();
        addChild(stopBtnName);
        stopBtnName.addEventListener(MouseEvent.CLICK,onStopAudioByNameClickHandler);
        var textFieldSn:TextField = new TextField();
        textFieldSn.x = 250;
        textFieldSn.y = 254;
        textFieldSn.text = "停止音效(Name)";
        addChild(textFieldSn);


        var addABtn:Sprite = new Sprite();
        addABtn.graphics.beginFill(0xffff00,1);
        addABtn.graphics.drawRect(50,300,45,25);
        addABtn.graphics.endFill();
        addChild(addABtn);
        addABtn.addEventListener(MouseEvent.CLICK,onAddAudioVolumeClickHandler);
        var textFielA:TextField = new TextField();
        textFielA.x = 100;
        textFielA.y = 304;
        textFielA.text = "音效音量增大";
        addChild(textFielA);

        var reduceBtnA:Sprite = new Sprite();
        reduceBtnA.graphics.beginFill(0x0000ff,1);
        reduceBtnA.graphics.drawRect(50,350,45,25);
        reduceBtnA.graphics.endFill();
        addChild(reduceBtnA);
        reduceBtnA.addEventListener(MouseEvent.CLICK,onReduceAudioVolumeClickHandler);
        var textFieldB:TextField = new TextField();
        textFieldB.x = 100;
        textFieldB.y = 354;
        textFieldB.text = "音效音量减小";
        addChild(textFieldB);

        var muteBtnA:Sprite = new Sprite();
        muteBtnA.graphics.beginFill(0x0000ff,1);
        muteBtnA.graphics.drawRect(200,100,45,25);
        muteBtnA.graphics.endFill();
        addChild(muteBtnA);
        muteBtnA.addEventListener(MouseEvent.CLICK,onMuteVolumeClickHandler);
        var textFieldC:TextField = new TextField();
        textFieldC.x = 250;
        textFieldC.y = 104;
        textFieldC.text = "静音";
        addChild(textFieldC);

        var playBtnByPath:Sprite = new Sprite();
        playBtnByPath.graphics.beginFill(0x0000ff,1);
        playBtnByPath.graphics.drawRect(200,150,45,25);
        playBtnByPath.graphics.endFill();
        addChild(playBtnByPath);
        playBtnByPath.addEventListener(MouseEvent.CLICK,onPlayAudioByPathClickHandler);
        var textFieldP:TextField = new TextField();
        textFieldP.x = 250;
        textFieldP.y = 154;
        textFieldP.text = "播放音效(Path)";
        addChild(textFieldP);

        var stopBtnByPath:Sprite = new Sprite();
        stopBtnByPath.graphics.beginFill(0x0000ff,1);
        stopBtnByPath.graphics.drawRect(400,150,45,25);
        stopBtnByPath.graphics.endFill();
        addChild(stopBtnByPath);
        stopBtnByPath.addEventListener(MouseEvent.CLICK,onStopAudioByPathClickHandler);
        var textFieldStop:TextField = new TextField();
        textFieldStop.x = 450;
        textFieldStop.y = 154;
        textFieldStop.text = "停止音效(Path)";
        addChild(textFieldStop);

        var fileName:String = "./test/Audio.json";
        _audioManager.loadFile(fileName);

        this.addChild(new TheMiner());
    }



    private function onAddAudioVolumeClickHandler(event:MouseEvent):void
    {
        var volume:Number = _audioManager.audioVolume;
        volume += 0.1;
        if(volume >= 1)volume = 1.0;
        _audioManager.audioVolume = volume;
    }

    private function onReduceAudioVolumeClickHandler(event:MouseEvent):void
    {
        var volume:Number = _audioManager.audioVolume;
        volume -= 0.1;
        if(volume <= 0)volume = 0.0;
        _audioManager.audioVolume = volume;
    }

    private function onPlayClickHandler(e:MouseEvent):void
    {
//        curIndex = curIndex == 0?1:0;
        _audioManager.playMusic("Scene_fuben", int.MAX_VALUE,0,3.0,3.0,true);
    }

    private function onStopClickHandler(e:MouseEvent):void
    {
        _audioManager.playMusicByPath("./res/sound/kof_select_role.mp3");
//     _audioManager.stopMusic();
    }

    private function onAddVolumeClickHandler(e:MouseEvent):void
    {
        var volume:Number = _audioManager.musicVolume;
        volume += 0.1;
        if(volume >= 1)volume = 1.0;
        _audioManager.musicVolume = volume;
    }

    private function onReduceVolumeClickHandler(e:MouseEvent):void
    {
        var volume:Number = _audioManager.musicVolume;
        volume -= 0.1;
        if(volume <= 0)volume = 0.0;
        _audioManager.musicVolume = volume;
    }

    private function onMuteVolumeClickHandler(e:MouseEvent):void
    {
        _audioManager.stopAll();
    }

    private function onPlayAudioByNameClickHandler(event:MouseEvent):void
    {
        _audioManager.playAudioByName("Hit",0,0);
    }

    private function onStopAudioByNameClickHandler(event:MouseEvent):void
    {
        _audioManager.stopAudioByName("Hit");
    }

    private function onPlayAudioByPathClickHandler(event:MouseEvent):void
    {
        _audioManager.playAudioByPath("./res/sound/10005.mp3",0,0);
    }

    private function onStopAudioByPathClickHandler(event:MouseEvent):void
    {
        _audioManager.stopAudioByPath("./res/sound/10005.mp3");
    }


}
}
