/**
 * Created by auto
 */
package core.pathing {
import core.framework.CAppSystem;
import core.pathing.astar.CAStarBuilding;
import core.scene.ISceneFacade;
import laya.events.Event;
import core.pathing.astar.CAStar;

public class CPathingSystem extends CAppSystem implements IPathingFacade {
    public function CPathingSystem() {
        super();
    }

    override protected virtual function onStart() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            // ISceneFacade  这块后续不需要, pathingSystem只处理网络
            _aStar = CAStarBuilding.buildAStar(_aStar);

            //var pSceneSystem:ISceneFacade = stage.getSystem(ISceneFacade) as ISceneFacade;
            //pSceneSystem.scenegraph.addEventListener(CSceneRendering.SCENE_CFG_COMPLETE, _onSceneReay, false, 0, true);
        }
        return ret;
    }

    private function _onSceneReay(e:Event) : void {
        //
        //var pSceneSystem:ISceneFacade = stage.getSystem(ISceneFacade) as ISceneFacade;
        //_aStar.initialByGridData(pSceneSystem.scenegraph.terrainData.blockGrids, 750/64);
    }

    /**
     * @param stGridX
     * @param stGridY
     * @param endGridX
     * @param endGridY
     * @return 返回网格点, 外部将网络转为坐标点
     */
    public function findPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        return _aStar.findPath(stGridX, stGridY, endGridX, endGridY);
    }
    public function findReversePath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        return _aStar.findReversePath(stGridX, stGridY, endGridX, endGridY);
    }

    private var _aStar:CAStar;
}
}
