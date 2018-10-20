//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.validation {

    import kof.framework.CAppSystem;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.tx.data.CTXData;
import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.table.BundleEnable;

    /**
     * 玩家身位条件验证
     *
     * @author Jeremy (jeremy@qifun.com)
     */
    public class CSwitchingAccountTypeIDValidator implements ISwitchingValidation {

        /** @private */
        private var m_pSystemRef : CAppSystem;

        /** Creates a new CSwitchingAccountTypeIDValidator */
        public function CSwitchingAccountTypeIDValidator( pSystemRef : CAppSystem ) {
            super();
            m_pSystemRef = pSystemRef;
        }

        public function dispose() : void {
            m_pSystemRef = null;
        }

        public function evaluate( ... args ) : Boolean {
            var pData : BundleEnable = args[ 0 ] as BundleEnable;
            if ( pData ) {
                var tagName : String = pData.TagID;
                var playerSystem:CPlayerSystem = m_pSystemRef.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var playerManager : CPlayerManager = playerSystem.getBean( CPlayerManager ) as CPlayerManager;
                var platformData:CPlatformBaseData = playerSystem.platform.data;

                if ( platformData.platform != EPlatformType.PLATFORM_DEFAULT ) {
//                    var platformName : String = playerManager.playerData.systemData.channelInfo.pf;
                    var txData:CTXData = platformData as CTXData;
                    if ( tagName == "QQ_BLUE_DIAMOND" || tagName == "QQ_HALL" ) {
                        if ( platformData.platform == EPlatformType.PLATFORM_TX ) {
                            if ( false == txData.isQGame ) {
                                return false;
                            }
                        } else {
                            return false;
                        }
                    }
                    if ( tagName == "QQ_YELLOW_DIAMOND" ) {
                        if ( platformData.platform == EPlatformType.PLATFORM_TX ) {
                            if ( txData.isQZone == false ) {
                                return false;
                            }
                        } else {
                            return false;
                        }
                    }
                } else {
                    if ( tagName == "QQ_BLUE_DIAMOND" || tagName == "QQ_HALL" || tagName == "QQ_YELLOW_DIAMOND" ) {
                        return false;
                    }
                }
            }
            return true;
        }

        public function getLocaleDesc( configData : Object ) : String {
            return null;
        }

    }
}
