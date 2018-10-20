/**
 * Created by auto on 2016/6/1.
 */
package preview.ui {
import flash.geom.Rectangle;

import preview.ui.compoent.CBaseLayer;
import preview.ui.compoent.CFrameRectSprite;
import preview.ui.compoent.CRectSprite;

public class CTrunkLayer extends CBaseLayer {
    public function CTrunkLayer() {
        this.mouseChildren = false;
        this.mouseEnabled = false;
    }

    protected override function _onAdd() : void {
        super._onAdd();

        _lockTrunkArea = new CFrameRectSprite(0x00ff00, 0, 0, 0x0000ff, 0.05, 0.05, 0.1);
        this.addChild(_lockTrunkArea);

        zoneList = new Array(10);
        for (var i:int = 0; i < zoneList.length; i++) {
            var zone:CRectSprite = new CRectSprite(0xff0000, 0, 0, 0.1);
            this.addChild(zone);
            zoneList[i] = zone;
        }

    }
    protected override function _onRemove() : void {
        super._onRemove();
        _lockTrunkArea.parent.removeChild(_lockTrunkArea);
        for (var i:int = 0; i < zoneList.length; i++) {
            zoneList[i].parent.removeChild(zoneList[i]);
        }
    }

    public function updateFromData(data:Object) : void {
        _lockTrunkArea.clear();
        var i:int = 0;
        for (i = 0; i < zoneList.length; i++) {
            zoneList[i].clear();
        }
        var lockReckData:Object = data["lock"];
        if (lockReckData) {
            var lockRect:Rectangle = new Rectangle(lockReckData["x"], lockReckData["y"], lockReckData["width"], lockReckData["height"]);
            _lockTrunkArea.setSize(lockRect.width, lockRect.height);
            _lockTrunkArea.move(lockRect.x, lockRect.y);
        }

        var zoneDataList:Array = data["zone"];
        if (zoneDataList) {
            i = 0;
            for each (var zoneRectData:Object in zoneDataList) {
                if (zoneRectData) {
                    var zoneRect:Rectangle = new Rectangle(zoneRectData["x"], zoneRectData["y"], zoneRectData["width"], zoneRectData["height"]);
                    zoneList[i].setSize(zoneRect.width, zoneRect.height);
                    zoneList[i].move(zoneRect.x, zoneRect.y);
                    i++;
                }
            }

        }

    }

    private var _lockTrunkArea:CFrameRectSprite;
    private var zoneList:Array;
}
}
