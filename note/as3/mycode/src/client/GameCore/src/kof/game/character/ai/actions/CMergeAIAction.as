//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/1/7.
 * Time: 15:07
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Foundation.CURLJson;
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAIHandler;
    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.ai.jsonData.CAIJsonFilePath;
    import kof.game.core.CGameObject;
    import kof.table.AI;

    /**
     * 组合行为
     * 负责合并其他AI树
     * */
    public class CMergeAIAction extends CBaseNodeAction {

        private var m_rootNode : CBaseNode = null;
        private var m_pBT : CAIObject = null;
        private var m_templateNameVec : Vector.<String> = new Vector.<String>();
        private var m_bFirstInto : Boolean = true;
        private var m_pAIComponent : CAIComponent = null;
        private var m_pAIHandler : IAIHandler = null;

        private var templeteName : String = "";

        public function CMergeAIAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            this.m_pBT = pBt as CAIObject;
            setName( nodeName );
            if ( nodeIndex != -1 ) {
                setTemplateIndex( nodeIndex );
            }
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            var arr : Array = [];
            var len : int = 0;
            if ( m_pBT.cacheParamsDic[ name + ".templeteName" ] ) {
                this.templeteName = m_pBT.cacheParamsDic[ name + ".templeteName" ];
            }
            arr = templeteName.split( "-" );
            len = arr.length;
            for ( var k : int = 0; k < len; k++ ) {
                var aiName : String = arr[ k ];
                m_templateNameVec.push( aiName );
            }
        }

        override public function _doExecute( inputData : Object ) : int {
            if ( m_bFirstInto ) {
                m_bFirstInto = false;
                var owner : CGameObject = inputData.owner as CGameObject;
                var handler : IAIHandler = inputData.handler as IAIHandler;
                m_pAIHandler = handler;
                var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
                m_pAIComponent = pAIComponent;
                CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
                CAILog.logMsg( "开始合并AI元件模板", pAIComponent.objId );
                var len : int = m_templateNameVec.length;
                for ( var i : int = 0; i < len; i++ ) {
                    var aiFileName : String = m_templateNameVec[ i ];
                    CAILog.logMsg( "加载:" + aiFileName + "模板", pAIComponent.objId );
                    _loadAIJson( aiFileName, i + 1 );
                }
            }
            return CNodeRunningStatusEnum.SUCCESS;
        }

        private function _loadAIJson( fileName : String, index : int ) : void {
            var nameIndex : int = index;
            if ( m_pAIHandler.componentResource && m_pAIHandler.componentResource.theObject.hasOwnProperty( fileName ) ) {
                var jsonObj : Object = m_pAIHandler.componentResource.theObject[ fileName ];
                var rootNode : CBaseNode = m_pBT.createBehaviorTree( jsonObj[ fileName ], nameIndex ,fileName);
                parentNode.addChildNode( rootNode );
                CAILog.logMsg( "AI加载成功，fileName:" + fileName, m_pAIComponent.objId );
            } else {
                CResourceLoaders.instance().startLoadFile( CAIJsonFilePath.AI_COMPONENT_JSON_FILE_PATH + fileName + ".json", _loadJsonData, CJsonLoader.NAME, ELoadingPriority.NORMAL, true );
                function _loadJsonData( loader : CJsonLoader, idError : int ) : void {
                    if ( idError == 0 ) {
                        var jsonObj : Object = loader.createResource().theObject[ fileName ];
                        var rootNode : CBaseNode = m_pBT.createBehaviorTree( jsonObj, nameIndex ,fileName );
                        parentNode.addChildNode( rootNode );
                        CAILog.logMsg( "AI加载成功，fileName:" + fileName, m_pAIComponent.objId );
                    }
                    else {
                        CAILog.logMsg( "AI加载失败，fileName:" + fileName, m_pAIComponent.objId );
                    }
                }
            }
        }
    }
}
