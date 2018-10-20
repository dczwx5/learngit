package QFLib.Graphics.FX.effectsystem
{

    import QFLib.ResourceLoader.ELoadingPriority;

    public class BaseEffectContainer extends BaseEffect
    {
        public override function loadFromObject ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL, onEffectLoadFinished : Function = null ) : void
        {
            super.loadFromObject ( url, data, iLoadingPriority, onEffectLoadFinished );

            if(_needTrack && checkObject(data, "life"))
                _life = data.life;

            if ( checkObject ( data, "emitter" ) )
                _loadFromJson ( url, data.emitter, iLoadingPriority );
        }

        protected virtual function _loadFromJson ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL ) : void { }
    }
}
