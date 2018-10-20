//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/30.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import kof.game.character.property.CCharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.core.CGameObject;
import kof.message.Fight.HealResponse;

public class CHealStrategy extends CBaseStrategy {
    public function CHealStrategy() {
        super();
    }

    override public function doResponseAction() : void {
        var healMsg : HealResponse = healResponse;
        var healTargetInfo : Array;

        var target : CGameObject;
        var effectCnt : int;
        var effectValue : int;
        var pSceneMediator : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
        var targetFloatSprite : CFightFloatSprite;
        var targetProperty : CCharacterProperty;
        if ( pSceneMediator ) {
            healTargetInfo = healMsg.targets;

            for each( var healInfo : Object in healTargetInfo ) {
                target = pSceneMediator.findGameObj( healInfo.type, healInfo.ID );
                if ( !target ) continue;
                targetFloatSprite = target.getComponentByClass( CFightFloatSprite, true ) as CFightFloatSprite;
                targetProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                effectCnt = healInfo.cnt;
                for ( var i : int = 0; i < effectCnt; i++ ) {
                    effectValue = healInfo.hasOwnProperty( "healHP" ) ? healInfo.healHP : 0;
                    if ( effectValue != 0 ) {
//                        targetProperty.HP = _getRetWithMaxLimit( effectValue, targetProperty.HP, targetProperty.MaxHP );
                        if ( effectValue < 0 )
                            targetFloatSprite.createBubbleNumber( effectValue );
                        else
                            targetFloatSprite.createGreenNumText( effectValue );
                    }


                    effectValue = healInfo.hasOwnProperty( "healAP" ) ? healInfo.healAP : 0;
                    if ( effectValue != 0 ) {
//                        targetProperty.AttackPower = _getRetWithMaxLimit( effectValue, targetProperty.AttackPower, targetProperty.MaxAttackPower );
                        if ( effectValue < 0 )
                            targetFloatSprite.createBubbleNumber( effectValue );
                        else
                            targetFloatSprite.createGreenNumText( effectValue );
                    }

                    effectValue = healInfo.hasOwnProperty( "healDP" ) ? healInfo.healAP : 0;
                    if ( effectValue != 0 ) {
//                        targetProperty.DefensePower = _getRetWithMaxLimit( effectValue, targetProperty.DefensePower, targetProperty.MaxDefensePower );
                        if ( effectValue < 0 )
                            targetFloatSprite.createBubbleNumber( effectValue );
                        else
                            targetFloatSprite.createGreenNumText( effectValue );
                    }

                    effectValue = healInfo.hasOwnProperty( "healRP" ) ? healInfo.healAP : 0;
                    if ( effectValue != 0 ) {
//                        targetProperty.RagePower = _getRetWithMaxLimit( effectValue, targetProperty.RagePower, targetProperty.MaxRagePower );
                        if ( effectValue < 0 )
                            targetFloatSprite.createBubbleNumber( effectValue );
                        else
                            targetFloatSprite.createGreenNumText( effectValue );
                    }

                }
            }
        }
    }

    [inline]
    final private function _getRetWithMaxLimit( value : int, source : int, max : int ) : int {
        var ret : int = value + source;
        if ( ret < 0 ) return ret = 0;
        return ret > max ? max : ret;
    }

    private function get healResponse() : HealResponse {
        return action.actionData as HealResponse;
    }
}
}
