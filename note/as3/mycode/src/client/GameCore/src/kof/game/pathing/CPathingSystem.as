//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/23.
 */
package kof.game.pathing {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.game.pathing.astar.CAStar;
import kof.game.pathing.astar.CAStarBuilding;
import kof.game.scene.CSceneRendering;
import kof.game.scene.ISceneFacade;

public class CPathingSystem extends CAppSystem implements IPathingFacade {
    public function CPathingSystem() {
        super();
    }
    public override function dispose() : void {
        super.dispose();
    }
    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            // ISceneFacade  这块后续不需要, pathingSystem只处理网络
            _aStar = CAStarBuilding.buildAStar(_aStar);
            this.addBean(_aStar);

            var pSceneSystem:ISceneFacade = stage.getSystem(ISceneFacade) as ISceneFacade;
            pSceneSystem.scenegraph.addEventListener(CSceneRendering.SCENE_CFG_COMPLETE, _onSceneReay, false, 0, true);
        }
        return ret;
    }

    private function _onSceneReay(e:Event) : void {
        //
        var pSceneSystem:ISceneFacade = stage.getSystem(ISceneFacade) as ISceneFacade;
        _aStar.initialByGridData(pSceneSystem.scenegraph.terrainData.blockGrids, pSceneSystem.scenegraph.terrainData.numBlocksX);
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
