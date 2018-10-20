package {

    import Scenes.CSceneView;

    import flash.display.Sprite;
import flash.text.TextField;

[SWF(width=800,height=600)]
public class Main extends Sprite {
    public function Main() {
        var scene:CSceneView = new CSceneView();
        addChild(scene);
    }
}
}
