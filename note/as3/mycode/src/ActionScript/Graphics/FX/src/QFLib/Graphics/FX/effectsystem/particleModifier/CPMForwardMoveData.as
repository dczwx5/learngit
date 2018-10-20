/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValue;
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValueFactory;

    public class CPMForwardMoveData extends CParticleModifierData {
    private var m_velocitySize:CParticleValue;

    public function CPMForwardMoveData(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    public override function dispose():void
    {
        if(m_velocitySize != null)
                CParticleValueFactory.deallocate(m_velocitySize);
        m_velocitySize = null;
        super.dispose();
    }

    public function getVelocitySize():Number
    {
        return m_velocitySize.getValue() as Number;
    }

    public function getVelocitySizeInLife(life:Number):Number
    {
        return m_velocitySize.getValueInLife(life) as Number;
    }

    protected override function _isEqual(theTarget:CParticleModifierData):Boolean
    {
        var theMyTarget:CPMForwardMoveData = theTarget as CPMForwardMoveData;
        return super._isEqual(theTarget) && m_velocitySize.isEqual(theMyTarget.m_velocitySize);
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        if(m_velocitySize != null)CParticleValueFactory.deallocate(m_velocitySize);
        var theVelocitySizeData:Object = theData["velocity_size"];
        m_velocitySize = CParticleValueFactory.allocate(theVelocitySizeData);
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["velocity_size"] = m_velocitySize.saveToJson();
        return theResultData;
    }

}
}
