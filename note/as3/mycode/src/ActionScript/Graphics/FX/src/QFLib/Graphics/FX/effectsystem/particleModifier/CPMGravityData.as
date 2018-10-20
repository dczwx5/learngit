/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValue;
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValueFactory;

    public class CPMGravityData extends CParticleModifierData {

    private var m_gravitySize:CParticleValue;

    public function CPMGravityData(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    public override function dispose():void
    {
        if(m_gravitySize != null)
                CParticleValueFactory.deallocate(m_gravitySize);
        m_gravitySize = null;
        super.dispose();
    }

    public function getGravitySize():Number { return m_gravitySize.getValue() as Number; }
    public function getGravitySizeInLife(life:Number):Number { return m_gravitySize.getValueInLife(life) as Number; }

    protected override function _isEqual(theTarget:CParticleModifierData):Boolean
    {
        var theMyTarget:CPMGravityData = theTarget as CPMGravityData;
        return super._isEqual(theTarget) && m_gravitySize.isEqual(theMyTarget.m_gravitySize);
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        if(m_gravitySize != null)CParticleValueFactory.deallocate(m_gravitySize);
        var theGravitySizeData:Object = theData["gravity_size"];
        m_gravitySize = CParticleValueFactory.allocate(theGravitySizeData);
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["gravity_size"] = m_gravitySize.saveToJson();
        return theResultData;
    }
}
}
