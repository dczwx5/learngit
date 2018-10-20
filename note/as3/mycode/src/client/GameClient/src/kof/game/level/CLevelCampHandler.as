//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.level {

import QFLib.Foundation.CMap;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.table.CampRefs;

/**
 * 关卡阵营关系控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLevelCampHandler extends CAbstractHandler {

    static public const ATTACKABLE : int = 1;
    static public const NON_ATTACKABLE : int = 0;

    private var m_pAllCamps : CMap;

    /**
     * Creates a new CLevelCampHandler.
     */
    public function CLevelCampHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pAllCamps ) {
            m_pAllCamps.clear();
        }
        m_pAllCamps = null;
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        m_pAllCamps = new CMap();

        var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        if ( pDatabase ) {
            var pTable : IDataTable = pDatabase.getTable( KOFTableConstants.CAMP_REFS );
            if ( pTable ) {
                var rows : Vector.<Object> = pTable.toVector();
                for each ( var row : CampRefs in rows ) {
                    var pListCols : Array = m_pAllCamps.find( row.Category );
                    if ( !pListCols )
                        m_pAllCamps.add( row.Category, (pListCols = []) );
                    pListCols.push( row );
                }
            }
        }

        // print camps relationships.

        for ( var iCategory : int in m_pAllCamps ) {
            //noinspection JSUnfilteredForInLoop
            LOG.logTraceMsg( " ### - Loaded Camps Category " + iCategory.toString() );
        }

        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( m_pAllCamps ) {
            m_pAllCamps.clear();
        }
        return ret;
    }

    public function findCampRefValue( iCategory : int, iMyCampID : int, iTargetCampID : int ) : int {
        var pList : Array = m_pAllCamps.find( iCategory );
        if ( iMyCampID >= 0 && pList && pList.length ) {
            return pList[ iMyCampID ].TargetCamps[ iTargetCampID ];
        }
        return 0;
    }

    public function isAttackable( iCategory : int, iMyCampID : int, iTargetCampID : int ) : Boolean {
        return findCampRefValue( iCategory, iMyCampID, iTargetCampID ) == ATTACKABLE;
    }

    public function isFriendly( iCategory : int, iMyCampID : int, iTargetCampID : int ) : Boolean {
        return findCampRefValue( iCategory, iMyCampID, iTargetCampID ) == NON_ATTACKABLE;
    }

}
}
