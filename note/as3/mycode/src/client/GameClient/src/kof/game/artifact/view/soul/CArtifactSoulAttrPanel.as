//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-26
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.view.soul {

import QFLib.Math.CMath;

import com.greensock.easing.Back;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.artifact.data.CArtifactSoulData;
import kof.table.ArtifactQuality;
import kof.table.ArtifactSoulInfo;

import morn.core.components.Box;
import morn.core.components.Clip;
import morn.core.components.Label;
import morn.core.components.ProgressBar;

/**
 * 神灵属性面板代理 （三条属性进度条 ），洗炼、突破都兼容使用
 *@author tim
 *@create 2018-05-26 11:47
 **/
public class CArtifactSoulAttrPanel {
        private var _m_pSystem:CAppSystem;
        private var _m_uiView:Box;

        public var clip_property_0:Clip = null;
        public var clip_property_2:Clip = null;
        public var clip_property_1:Clip = null;
        public var clip_result_0:Clip = null;
        public var clip_result_1:Clip = null;
        public var clip_result_2:Clip = null;
        public var bar_pro_vale_2:ProgressBar = null;
        public var bar_pro_vale_1:ProgressBar = null;
        public var bar_pro_vale_0:ProgressBar = null;
        public var txt_property_1:Label = null;
        public var txt_property_0:Label = null;
        public var txt_property_2:Label = null;
        public var txt_new_property_1:Label = null;
        public var txt_new_property_0:Label = null;
        public var txt_new_property_2:Label = null;

        private var _m_bIsShowNewProp:Boolean;//是否显示洗练后的属性+-值
        private var _m_bIsShowNextQualityScale:Boolean;//是否用下一级品质的属性百分比来显示比例（突破预览界面用）

        public function CArtifactSoulAttrPanel( system:CAppSystem, uiView:Box, isShowNewProp:Boolean, isShowNextQualityScale:Boolean) {
            this._m_pSystem = system;
            this._m_uiView = uiView;
            this._m_bIsShowNewProp = isShowNewProp;
            this._m_bIsShowNextQualityScale = isShowNextQualityScale;
            _configChildren();
        }

        private function _configChildren() : void {
            for (var i:int = 0; i < 3; i++)
            {
                this["clip_property_" + i] = _m_uiView.getChildByName("clip_property_" + i);
                this["bar_pro_vale_" + i] = _m_uiView.getChildByName("bar_pro_vale_" + i);
                this["txt_property_" + i] = _m_uiView.getChildByName("txt_property_" + i);
                this["txt_new_property_" + i] = _m_uiView.getChildByName("txt_new_property_" + i);
                this["clip_result_" + i] = _m_uiView.getChildByName("clip_result_" + i);
            }
        }


        public function update(m_data:CArtifactSoulData):void {
            var artifactSoulInfoTable:IDataTable = (_m_pSystem.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTSOULINFO);
            var soulInfo:ArtifactSoulInfo = (artifactSoulInfoTable.findByPrimaryKey(m_data.artifactSoulID) as ArtifactSoulInfo);
            var pTable:IDataTable = (_m_pSystem.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
            var propertyValue:Array = m_data.propertyValue.concat();
            var scaleValue:Array = m_data.scaleValue.concat();
            if (_m_bIsShowNewProp) {
                for (var j:int = 0; j < 3; j++) {
                    propertyValue[j] += m_data.newPropertyValue[j];
                    scaleValue[j] += m_data.newScaleValue[j];
                }
            } else if (_m_bIsShowNextQualityScale) {
                scaleValue = m_data.scaleValueOfNextQuality;
            }

            var attrIconClipIndex:Array = [2, 0, 1];
            for (var i:int = 0; i<3; i++) {
                if (m_data.propertyValue && m_data.isLock == 0) {
                    this["txt_property_"+i].text = pTable.findByPrimaryKey( soulInfo["propertyID"+(i+1)]).name+"+"+ propertyValue[i];
                    this["bar_pro_vale_"+i].value = (scaleValue[i]/100);
                    this["bar_pro_vale_"+i].label = "("+scaleValue[i]+"%)";
                } else {
                    this["txt_property_"+i].text = pTable.findByPrimaryKey( soulInfo["propertyID"+(i+1)] ).name+"+"+0;
                    this["bar_pro_vale_"+i].value = 0;
                    this["bar_pro_vale_"+i].label = "";
                }
                this["clip_property_"+i].index = attrIconClipIndex[i];

                if (_m_bIsShowNewProp && m_data.newPropertyValue) {
                    var isIncrease:Boolean = m_data.newScaleValue[i] >= 0;
                    this["txt_new_property_"+i].text = ((isIncrease ? "+" : "") + m_data.newPropertyValue[i]) + "("+CMath.abs(m_data.newScaleValue[i])+"%)";
                    this["txt_new_property_"+i].textField.textColor = isIncrease ? 0xa3f02a : 0xff8282;
                    this["clip_result_" + i ].index = isIncrease ? 0 : 1;
                    this["clip_result_" + i ].visible = m_data.newPropertyValue[i] != 0;
                } else {
                    if (this["txt_new_property_"+i] != null) {
                        this["txt_new_property_"+i].text = "";
                    }
                }
            }
        }

        public function set visible(value:Boolean):void {
            _m_uiView.visible = value;
        }
    }
}
